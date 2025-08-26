import '../constants/api_constants.dart';

/// 错误类型枚举
enum AppErrorType {
  // 网络错误
  network,
  timeout,
  noInternet,
  
  // 认证错误
  unauthorized,
  forbidden,
  tokenExpired,
  
  // 数据错误
  notFound,
  validation,
  parsing,
  
  // 系统错误
  unknown,
  platform,
  permission,
  
  // 业务错误
  business,
  userCancelled,
  
  // 本地错误
  storage,
  database,
  cache,
}

/// 错误严重级别
enum ErrorSeverity {
  low,     // 低级别，不影响核心功能
  medium,  // 中级别，影响部分功能
  high,    // 高级别，影响主要功能
  critical, // 严重级别，影响核心功能
}

/// 应用基础错误类
abstract class AppError implements Exception {

  const AppError({
    required this.type,
    required this.message,
    required this.timestamp, this.code,
    this.originalError,
    this.stackTrace,
    this.severity = ErrorSeverity.medium,
    this.data,
  });

  /// 创建未知错误
  factory AppError.unknown(String message, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) => _UnknownError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      data: data,
    );
  /// 错误类型
  final AppErrorType type;
  
  /// 错误消息
  final String message;
  
  /// 错误代码
  final String? code;
  
  /// 原始错误
  final dynamic originalError;
  
  /// 堆栈信息
  final StackTrace? stackTrace;
  
  /// 错误严重级别
  final ErrorSeverity severity;
  
  /// 错误时间戳
  final DateTime timestamp;
  
  /// 额外数据
  final Map<String, dynamic>? data;

  /// 是否为网络相关错误
  bool get isNetworkError => type == AppErrorType.network || 
                            type == AppErrorType.timeout ||
                            type == AppErrorType.noInternet;

  /// 是否为认证相关错误
  bool get isAuthError => type == AppErrorType.unauthorized ||
                         type == AppErrorType.forbidden ||
                         type == AppErrorType.tokenExpired;

  /// 是否为数据相关错误
  bool get isDataError => type == AppErrorType.notFound ||
                         type == AppErrorType.validation ||
                         type == AppErrorType.parsing;

  /// 是否可重试
  bool get isRetriable => type == AppErrorType.network ||
                         type == AppErrorType.timeout ||
                         type == AppErrorType.unknown;

  /// 是否需要用户操作
  bool get requiresUserAction => type == AppErrorType.unauthorized ||
                                type == AppErrorType.forbidden ||
                                type == AppErrorType.permission ||
                                type == AppErrorType.noInternet;

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
      'type': type.name,
      'message': message,
      'code': code,
      'severity': severity.name,
      'timestamp': timestamp.toIso8601String(),
      'data': data,
      'original_error': originalError?.toString(),
    };

  @override
  String toString() => 'AppError{type: $type, message: $message, code: $code}';
}

/// 未知错误实现类
class _UnknownError extends AppError {
  _UnknownError({
    required super.message,
    super.originalError,
    super.stackTrace,
    super.data,
  }) : super(
         type: AppErrorType.unknown,
         code: 'UNKNOWN_ERROR',
         severity: ErrorSeverity.medium,
         timestamp: DateTime.now(),
       );
}

/// 网络错误
class NetworkError extends AppError {

  NetworkError({
    required super.message,
    super.code,
    this.statusCode,
    this.url,
    this.method,
    super.originalError,
    super.stackTrace,
    super.severity,
    super.data,
  }) : super(
         type: AppErrorType.network,
         timestamp: DateTime.now(),
       );

  /// 从HTTP状态码创建网络错误
  factory NetworkError.fromStatusCode(
    int statusCode, {
    String? message,
    String? url,
    String? method,
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    String errorMessage;
    String errorCode;
    ErrorSeverity severity;

    switch (statusCode) {
      case 400:
        errorMessage = message ?? '请求参数错误';
        errorCode = ApiConstants.errorCodeInvalidCredentials;
        severity = ErrorSeverity.medium;
        break;
      case 401:
        errorMessage = message ?? '未授权，请重新登录';
        errorCode = ApiConstants.errorCodeTokenExpired;
        severity = ErrorSeverity.high;
        break;
      case 403:
        errorMessage = message ?? '访问被拒绝';
        errorCode = ApiConstants.errorCodeNoPermission;
        severity = ErrorSeverity.medium;
        break;
      case 404:
        errorMessage = message ?? '请求的资源不存在';
        errorCode = ApiConstants.errorCodeResourceNotFound;
        severity = ErrorSeverity.low;
        break;
      case 429:
        errorMessage = message ?? '请求过于频繁，请稍后重试';
        errorCode = 'TOO_MANY_REQUESTS';
        severity = ErrorSeverity.medium;
        break;
      case 500:
        errorMessage = message ?? '服务器内部错误';
        errorCode = ApiConstants.errorCodeServerError;
        severity = ErrorSeverity.high;
        break;
      case 503:
        errorMessage = message ?? '服务不可用';
        errorCode = ApiConstants.errorCodeServiceUnavailable;
        severity = ErrorSeverity.high;
        break;
      default:
        errorMessage = message ?? '网络请求失败($statusCode)';
        errorCode = ApiConstants.errorCodeNetworkError;
        severity = ErrorSeverity.medium;
        break;
    }

    return NetworkError(
      message: errorMessage,
      code: errorCode,
      statusCode: statusCode,
      url: url,
      method: method,
      originalError: originalError,
      stackTrace: stackTrace,
      severity: severity,
    );
  }
  /// HTTP状态码
  final int? statusCode;
  
  /// 请求URL
  final String? url;
  
  /// 请求方法
  final String? method;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();
    map.addAll(<String, dynamic>{
      'status_code': statusCode,
      'url': url,
      'method': method,
    });
    return map;
  }
}

/// 超时错误
class TimeoutError extends AppError {

  TimeoutError({
    required super.message,
    required this.timeoutDuration,
    super.code,
    super.originalError,
    super.stackTrace,
    super.data,
  }) : super(
         type: AppErrorType.timeout,
         severity: ErrorSeverity.medium,
         timestamp: DateTime.now(),
       );
  /// 超时时长（毫秒）
  final int timeoutDuration;

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = super.toMap();
    map['timeout_duration'] = timeoutDuration;
    return map;
  }
}

/// 认证错误
class AuthError extends AppError {
  AuthError({
    required super.message,
    super.code,
    super.type = AppErrorType.unauthorized,
    super.originalError,
    super.stackTrace,
    super.severity = ErrorSeverity.high,
    super.data,
  }) : super(
         timestamp: DateTime.now(),
       );

  /// Token过期错误
  factory AuthError.tokenExpired({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AuthError(
      type: AppErrorType.tokenExpired,
      message: message ?? '登录已过期，请重新登录',
      code: ApiConstants.errorCodeTokenExpired,
      originalError: originalError,
      stackTrace: stackTrace,
    );

  /// 无权限错误
  factory AuthError.forbidden({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => AuthError(
      type: AppErrorType.forbidden,
      message: message ?? '没有访问权限',
      code: ApiConstants.errorCodeNoPermission,
      originalError: originalError,
      stackTrace: stackTrace,
    );
}

/// 数据错误
class DataError extends AppError {
  DataError({
    required super.message,
    super.type = AppErrorType.parsing,
    super.code,
    super.originalError,
    super.stackTrace,
    super.severity,
    super.data,
  }) : super(
         timestamp: DateTime.now(),
       );

  /// 数据解析错误
  factory DataError.parsing({
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => DataError(
      message: message ?? '数据解析失败',
      code: 'PARSING_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
    );

  /// 数据验证错误
  factory DataError.validation({
    required String message,
    String? code,
    Map<String, dynamic>? data,
  }) => DataError(
      type: AppErrorType.validation,
      message: message,
      code: code ?? 'VALIDATION_ERROR',
      data: data,
      severity: ErrorSeverity.low,
    );

  /// 资源未找到错误
  factory DataError.notFound({
    String? message,
    String? resourceType,
    String? resourceId,
  }) => DataError(
      type: AppErrorType.notFound,
      message: message ?? '请求的资源不存在',
      code: ApiConstants.errorCodeResourceNotFound,
      data: <String, dynamic>{
        'resource_type': resourceType,
        'resource_id': resourceId,
      },
      severity: ErrorSeverity.low,
    );
}

/// 系统错误
class SystemError extends AppError {
  SystemError({
    required super.message,
    super.type = AppErrorType.platform,
    super.code,
    super.originalError,
    super.stackTrace,
    super.severity = ErrorSeverity.high,
    super.data,
  }) : super(
         timestamp: DateTime.now(),
       );

  /// 权限错误
  factory SystemError.permission({
    required String message,
    String? permission,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => SystemError(
      type: AppErrorType.permission,
      message: message,
      code: 'PERMISSION_DENIED',
      originalError: originalError,
      stackTrace: stackTrace,
      data: <String, dynamic>{'permission': permission},
    );

  /// 平台错误
  factory SystemError.platform({
    required String message,
    String? platform,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => SystemError(
      message: message,
      code: 'PLATFORM_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      data: <String, dynamic>{'platform': platform},
    );
}

/// 业务错误
class BusinessError extends AppError {
  BusinessError({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    super.severity,
    super.data,
  }) : super(
         type: AppErrorType.business,
         timestamp: DateTime.now(),
       );

  /// VIP权限错误
  factory BusinessError.vipRequired({
    String? message,
    String? resourceType,
  }) => BusinessError(
      message: message ?? '该功能需要VIP权限',
      code: ApiConstants.errorCodeVipRequired,
      data: <String, dynamic>{'resource_type': resourceType},
    );

  /// 章节锁定错误
  factory BusinessError.chapterLocked({
    String? message,
    String? chapterId,
  }) => BusinessError(
      message: message ?? '该章节已锁定',
      code: ApiConstants.errorCodeChapterLocked,
      data: <String, dynamic>{'chapter_id': chapterId},
      severity: ErrorSeverity.low,
    );
}

/// 存储错误
class StorageError extends AppError {
  StorageError({
    required super.message,
    super.type = AppErrorType.storage,
    super.code,
    super.originalError,
    super.stackTrace,
    super.severity,
    super.data,
  }) : super(
         timestamp: DateTime.now(),
       );

  /// 数据库错误
  factory StorageError.database({
    required String message,
    String? operation,
    String? table,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => StorageError(
      type: AppErrorType.database,
      message: message,
      code: ApiConstants.errorCodeDatabaseError,
      originalError: originalError,
      stackTrace: stackTrace,
      data: <String, dynamic>{
        'operation': operation,
        'table': table,
      },
    );

  /// 缓存错误
  factory StorageError.cache({
    required String message,
    String? cacheKey,
    dynamic originalError,
    StackTrace? stackTrace,
  }) => StorageError(
      type: AppErrorType.cache,
      message: message,
      code: 'CACHE_ERROR',
      originalError: originalError,
      stackTrace: stackTrace,
      data: <String, dynamic>{'cache_key': cacheKey},
      severity: ErrorSeverity.low,
    );
}

/// 用户取消错误
class UserCancelledError extends AppError {
  UserCancelledError({
    String? message,
    String? operation,
  }) : super(
         type: AppErrorType.userCancelled,
         message: message ?? '用户取消操作',
         code: 'USER_CANCELLED',
         severity: ErrorSeverity.low,
         timestamp: DateTime.now(),
         data: operation != null ? <String, dynamic>{'operation': operation} : null,
       );
}

/// 无网络连接错误
class NoInternetError extends AppError {
  NoInternetError({
    String? message,
  }) : super(
         type: AppErrorType.noInternet,
         message: message ?? '网络连接不可用，请检查网络设置',
         code: 'NO_INTERNET',
         severity: ErrorSeverity.high,
         timestamp: DateTime.now(),
       );
}