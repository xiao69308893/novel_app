import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../utils/preferences_helper.dart';
import 'app_error.dart';

/// 错误处理器接口
abstract class ErrorHandler {
  /// 处理错误
  Future<void> handleError(dynamic error, [StackTrace? stackTrace]);
  
  /// 显示错误信息
  void showError(BuildContext context, AppError error);
  
  /// 记录错误
  void logError(AppError error);
}

/// 错误处理策略
enum ErrorHandlingStrategy {
  showDialog,    // 显示对话框
  showSnackBar,  // 显示SnackBar
  showToast,     // 显示Toast
  silent,        // 静默处理
  redirect,      // 重定向
}

/// 默认错误处理器实现
class DefaultErrorHandler implements ErrorHandler {
  // 单例模式
  static DefaultErrorHandler? _instance;
  static DefaultErrorHandler get instance {
    _instance ??= DefaultErrorHandler._internal();
    return _instance!;
  }

  // 错误统计
  final Map<String, int> _errorCounts = {};
  final List<AppError> _recentErrors = [];
  final int _maxRecentErrors = 50;

  // 私有构造函数
  DefaultErrorHandler._internal();

  @override
  Future<void> handleError(dynamic error, [StackTrace? stackTrace]) async {
    final appError = convertToAppError(error, stackTrace);
    
    // 记录错误
    logError(appError);
    
    // 更新错误统计
    _updateErrorStats(appError);
    
    // 根据错误类型执行特定处理
    await _processSpecificError(appError);
  }

  @override
  void showError(BuildContext context, AppError error) {
    final strategy = _getErrorHandlingStrategy(error);
    
    switch (strategy) {
      case ErrorHandlingStrategy.showDialog:
        _showErrorDialog(context, error);
        break;
      case ErrorHandlingStrategy.showSnackBar:
        _showErrorSnackBar(context, error);
        break;
      case ErrorHandlingStrategy.showToast:
        _showErrorToast(context, error);
        break;
      case ErrorHandlingStrategy.redirect:
        _handleErrorRedirect(context, error);
        break;
      case ErrorHandlingStrategy.silent:
        // 静默处理，不显示UI
        break;
    }
  }

  @override
  void logError(AppError error) {
    // 记录到日志
    Logger.error(
      '应用错误: ${error.type.name}',
      error.originalError ?? error,
      error.stackTrace,
    );
    
    // 添加到最近错误列表
    _recentErrors.add(error);
    if (_recentErrors.length > _maxRecentErrors) {
      _recentErrors.removeAt(0);
    }
    
    // 如果是严重错误，额外记录
    if (error.severity == ErrorSeverity.critical) {
      Logger.fatal('严重错误', error.originalError ?? error, error.stackTrace);
      _reportCriticalError(error);
    }
  }

  /// 将通用错误转换为AppError
  static AppError convertToAppError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    if (error is DioException) {
      return _convertDioError(error, stackTrace);
    }

    if (error is SocketException) {
      return NoInternetError(
        message: '网络连接失败：${error.message}',
      );
    }

    if (error is TimeoutException) {
      return TimeoutError(
        message: '操作超时：${error.message}',
        timeoutDuration: error.duration?.inMilliseconds ?? 0,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return DataError.parsing(
        message: '数据格式错误：${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is ArgumentError) {
      return DataError.validation(
        message: '参数错误：${error.message}',
      );
    }

    if (error is FileSystemException) {
      return StorageError(
        message: '文件系统错误：${error.message}',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // 默认未知错误
    return SystemError(
      message: error?.toString() ?? '未知错误',
      code: 'UNKNOWN_ERROR',
      originalError: error,
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
    );
  }

  /// 转换Dio错误
  static AppError _convertDioError(DioException dioError, [StackTrace? stackTrace]) {
    switch (dioError.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutError(
          message: '连接超时，请检查网络',
          timeoutDuration: 30000,
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutError(
          message: '发送超时，请重试',
          timeoutDuration: 30000,
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.receiveTimeout:
        return TimeoutError(
          message: '响应超时，请重试',
          timeoutDuration: 30000,
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badResponse:
        return NetworkError.fromStatusCode(
          dioError.response?.statusCode ?? 0,
          url: dioError.requestOptions.uri.toString(),
          method: dioError.requestOptions.method,
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.cancel:
        return UserCancelledError(
          message: '请求已取消',
          operation: '网络请求',
        );

      case DioExceptionType.connectionError:
        if (dioError.message?.contains('Failed host lookup') == true) {
          return NoInternetError();
        }
        return NetworkError(
          message: '网络连接失败：${dioError.message}',
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkError(
          message: '证书验证失败',
          code: 'CERTIFICATE_ERROR',
          originalError: dioError,
          stackTrace: stackTrace,
        );

      case DioExceptionType.unknown:
      default:
        return NetworkError(
          message: '网络请求失败：${dioError.message}',
          originalError: dioError,
          stackTrace: stackTrace,
        );
    }
  }

  /// 获取错误处理策略
  ErrorHandlingStrategy _getErrorHandlingStrategy(AppError error) {
    switch (error.type) {
      case AppErrorType.unauthorized:
      case AppErrorType.tokenExpired:
        return ErrorHandlingStrategy.redirect;
      
      case AppErrorType.userCancelled:
        return ErrorHandlingStrategy.silent;
      
      case AppErrorType.validation:
        return ErrorHandlingStrategy.showSnackBar;
      
      case AppErrorType.noInternet:
      case AppErrorType.network:
        return ErrorHandlingStrategy.showSnackBar;
      
      case AppErrorType.business:
        return ErrorHandlingStrategy.showDialog;
      
      default:
        if (error.severity == ErrorSeverity.critical) {
          return ErrorHandlingStrategy.showDialog;
        } else if (error.severity == ErrorSeverity.low) {
          return ErrorHandlingStrategy.showToast;
        } else {
          return ErrorHandlingStrategy.showSnackBar;
        }
    }
  }

  /// 显示错误对话框
  void _showErrorDialog(BuildContext context, AppError error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                _getErrorIcon(error.type),
                color: _getErrorColor(error.severity),
              ),
              const SizedBox(width: 8),
              Text(_getErrorTitle(error.type)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(error.message),
              if (error.code != null) ...[
                const SizedBox(height: 8),
                Text(
                  '错误代码: ${error.code}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          actions: [
            if (error.isRetriable)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleErrorRetry(context, error);
                },
                child: const Text('重试'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 显示错误SnackBar
  void _showErrorSnackBar(BuildContext context, AppError error) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error.message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: _getErrorColor(error.severity),
        duration: _getSnackBarDuration(error.severity),
        action: error.isRetriable
            ? SnackBarAction(
                label: '重试',
                textColor: Colors.white,
                onPressed: () => _handleErrorRetry(context, error),
              )
            : null,
      ),
    );
  }

  /// 显示错误Toast（这里简化为SnackBar）
  void _showErrorToast(BuildContext context, AppError error) {
    final messenger = ScaffoldMessenger.of(context);
    
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(error.message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _getErrorColor(error.severity),
      ),
    );
  }

  /// 处理错误重定向
  void _handleErrorRedirect(BuildContext context, AppError error) {
    switch (error.type) {
      case AppErrorType.unauthorized:
      case AppErrorType.tokenExpired:
        // 清除认证信息并跳转到登录页
        _clearAuthAndNavigateToLogin(context);
        break;
      case AppErrorType.forbidden:
        // 跳转到无权限页面
        Navigator.pushReplacementNamed(context, '/no-permission');
        break;
      default:
        // 默认显示SnackBar
        _showErrorSnackBar(context, error);
        break;
    }
  }

  /// 处理错误重试
  void _handleErrorRetry(BuildContext context, AppError error) {
    // 这里可以实现具体的重试逻辑
    // 例如重新发起网络请求等
    Logger.info('用户触发错误重试: ${error.type.name}');
  }

  /// 清除认证信息并跳转到登录页
  void _clearAuthAndNavigateToLogin(BuildContext context) {
    // 清除认证信息
    PreferencesHelper.remove(PreferenceKeys.userToken);
    PreferencesHelper.remove(PreferenceKeys.refreshToken);
    PreferencesHelper.remove(PreferenceKeys.userInfo);
    
    // 跳转到登录页
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/auth/login',
      (route) => false,
    );
  }

  /// 处理特定错误
  Future<void> _processSpecificError(AppError error) async {
    switch (error.type) {
      case AppErrorType.database:
        // 数据库错误可能需要重新初始化
        Logger.warning('数据库错误，可能需要重新初始化');
        break;
      case AppErrorType.storage:
        // 存储错误可能需要清理缓存
        Logger.warning('存储错误，建议清理缓存');
        break;
      case AppErrorType.noInternet:
        // 网络错误可能需要检查网络状态
        Logger.warning('网络不可用，建议检查网络设置');
        break;
      default:
        break;
    }
  }

  /// 更新错误统计
  void _updateErrorStats(AppError error) {
    final key = '${error.type.name}_${error.code ?? 'unknown'}';
    _errorCounts[key] = (_errorCounts[key] ?? 0) + 1;
    
    // 保存错误统计到本地
    _saveErrorStats();
  }

  /// 保存错误统计
  void _saveErrorStats() {
    final stats = {
      'error_counts': _errorCounts,
      'last_updated': DateTime.now().toIso8601String(),
    };
    PreferencesHelper.setObject('error_stats', stats);
  }

  /// 加载错误统计
  void _loadErrorStats() {
    final stats = PreferencesHelper.getObject('error_stats');
    if (stats != null && stats['error_counts'] != null) {
      _errorCounts.clear();
      final counts = stats['error_counts'] as Map<String, dynamic>;
      counts.forEach((key, value) {
        _errorCounts[key] = value as int;
      });
    }
  }

  /// 报告严重错误
  void _reportCriticalError(AppError error) {
    // 这里可以实现向错误收集服务报告错误的逻辑
    // 例如：Firebase Crashlytics、Sentry等
    Logger.fatal('严重错误需要上报', error.toMap());
  }

  /// 获取错误图标
  IconData _getErrorIcon(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
      case AppErrorType.noInternet:
        return Icons.wifi_off;
      case AppErrorType.timeout:
        return Icons.access_time;
      case AppErrorType.unauthorized:
      case AppErrorType.forbidden:
        return Icons.lock;
      case AppErrorType.notFound:
        return Icons.search_off;
      case AppErrorType.validation:
        return Icons.error_outline;
      case AppErrorType.permission:
        return Icons.security;
      default:
        return Icons.error;
    }
  }

  /// 获取错误颜色
  Color _getErrorColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.orange;
      case ErrorSeverity.medium:
        return Colors.deepOrange;
      case ErrorSeverity.high:
        return Colors.red;
      case ErrorSeverity.critical:
        return Colors.red[900]!;
    }
  }

  /// 获取错误标题
  String _getErrorTitle(AppErrorType type) {
    switch (type) {
      case AppErrorType.network:
        return '网络错误';
      case AppErrorType.timeout:
        return '请求超时';
      case AppErrorType.noInternet:
        return '网络不可用';
      case AppErrorType.unauthorized:
        return '认证失败';
      case AppErrorType.forbidden:
        return '权限不足';
      case AppErrorType.notFound:
        return '资源不存在';
      case AppErrorType.validation:
        return '数据验证失败';
      case AppErrorType.business:
        return '业务错误';
      case AppErrorType.storage:
        return '存储错误';
      case AppErrorType.database:
        return '数据库错误';
      case AppErrorType.permission:
        return '权限错误';
      default:
        return '系统错误';
    }
  }

  /// 获取SnackBar显示时长
  Duration _getSnackBarDuration(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return const Duration(seconds: 2);
      case ErrorSeverity.medium:
        return const Duration(seconds: 3);
      case ErrorSeverity.high:
        return const Duration(seconds: 4);
      case ErrorSeverity.critical:
        return const Duration(seconds: 5);
    }
  }

  /// 获取错误统计信息
  Map<String, dynamic> getErrorStats() {
    return {
      'error_counts': Map.from(_errorCounts),
      'recent_errors_count': _recentErrors.length,
      'total_errors': _errorCounts.values.fold<int>(0, (sum, count) => sum + count),
    };
  }

  /// 获取最近的错误
  List<AppError> getRecentErrors({int? limit}) {
    if (limit != null && limit < _recentErrors.length) {
      return _recentErrors.sublist(_recentErrors.length - limit);
    }
    return List.from(_recentErrors);
  }

  /// 清除错误统计
  void clearErrorStats() {
    _errorCounts.clear();
    _recentErrors.clear();
    PreferencesHelper.remove('error_stats');
    Logger.info('错误统计已清除');
  }

  /// 初始化错误处理器
  void initialize() {
    _loadErrorStats();
    
    // 设置Flutter错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      handleError(details.exception, details.stack);
    };
    
    Logger.info('错误处理器初始化完成');
  }
}

/// 错误处理器工具类
class ErrorHandlerUtils {
  /// 包装异步操作，自动处理错误
  static Future<T?> wrapAsync<T>(
    Future<T> Function() operation, {
    ErrorHandler? errorHandler,
    bool silent = false,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      if (!silent) {
        final handler = errorHandler ?? DefaultErrorHandler.instance;
        await handler.handleError(error, stackTrace);
      }
      return null;
    }
  }

  /// 包装同步操作，自动处理错误
  static T? wrapSync<T>(
    T Function() operation, {
    ErrorHandler? errorHandler,
    bool silent = false,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      if (!silent) {
        final handler = errorHandler ?? DefaultErrorHandler.instance;
        handler.handleError(error, stackTrace);
      }
      return null;
    }
  }

  /// 检查网络连接状态
  static Future<bool> isNetworkAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}