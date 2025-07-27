import 'package:dio/dio.dart';
import 'package:http_certificate_pinning/http_certificate_pinning.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../utils/logger.dart';
import 'network_interceptor.dart';
import 'api_response.dart';

class ApiClient {
  // 单例模式
  static ApiClient? _instance;
  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  late Dio _dio;
  late String _baseUrl;

  // 私有构造函数
  ApiClient._internal() {
    _initializeDio();
  }

  // 初始化Dio配置
  void _initializeDio() {
    _baseUrl = ApiConstants.apiPath;
    
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(seconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(seconds: ApiConstants.connectTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': ApiConstants.getUserAgent(),
        'X-App-Version': ApiConstants.appVersion,
        'X-Platform': ApiConstants.platform,
      },
      responseType: ResponseType.json,
      followRedirects: true,
      maxRedirects: 3,
    ));

    // 添加拦截器
    _setupInterceptors();
    
    Logger.info('API客户端初始化完成: $_baseUrl');
  }

  // 设置拦截器
  void _setupInterceptors() {
    // 网络请求拦截器（认证、日志等）
    _dio.interceptors.add(NetworkInterceptor());

    // 日志拦截器（仅在调试模式下）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => Logger.debug('DIO', obj.toString()),
      ));
    }

    // 重试拦截器
    _dio.interceptors.add(RetryInterceptor());

    // 证书锁定（生产环境）
    if (kReleaseMode) {
      _dio.interceptors.add(
        CertificatePinningInterceptor(
          allowedSHAFingerprints: ['YOUR_CERT_FINGERPRINT'],
        ),
      );
    }
  }

  // ==================== GET请求 ====================

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'GET',
        '$_baseUrl$path',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      Logger.error('GET请求异常: $path', e);
      return ApiResponse.error('未知错误: $e');
    }
  }

  // ==================== POST请求 ====================

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'POST',
        '$_baseUrl$path',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      Logger.error('POST请求异常: $path', e);
      return ApiResponse.error('未知错误: $e');
    }
  }

  // ==================== PUT请求 ====================

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'PUT',
        '$_baseUrl$path',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      Logger.error('PUT请求异常: $path', e);
      return ApiResponse.error('未知错误: $e');
    }
  }

  // ==================== DELETE请求 ====================

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'DELETE',
        '$_baseUrl$path',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      Logger.error('DELETE请求异常: $path', e);
      return ApiResponse.error('未知错误: $e');
    }
  }

  // ==================== 文件上传 ====================

  Future<ApiResponse<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options ?? Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'UPLOAD',
        '$_baseUrl$path',
        statusCode: response.statusCode,
        duration: stopwatch.elapsed,
      );
      
      return _handleResponse<T>(response);
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      Logger.error('文件上传异常: $path', e);
      return ApiResponse.error('上传失败: $e');
    }
  }

  // ==================== 文件下载 ====================

  Future<ApiResponse<String>> download(
    String url,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      stopwatch.stop();
      
      Logger.network(
        'DOWNLOAD',
        url,
        duration: stopwatch.elapsed,
      );
      
      return ApiResponse.success(savePath, '文件下载成功');
    } on DioException catch (e) {
      return _handleError<String>(e);
    } catch (e) {
      Logger.error('文件下载异常: $url', e);
      return ApiResponse.error('下载失败: $e');
    }
  }

  // ==================== 响应处理 ====================

  ApiResponse<T> _handleResponse<T>(Response response) {
    final statusCode = response.statusCode ?? 0;
    
    if (ApiConstants.isSuccessStatusCode(statusCode)) {
      // 检查响应数据格式
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        
        // 标准API响应格式
        if (data.containsKey('success') || data.containsKey('code')) {
          return ApiResponse.fromJson(data, (json) => json as T);
        }
      }
      
      // 直接返回响应数据
      return ApiResponse.success(response.data as T, '请求成功');
    } else {
      return ApiResponse.error(_getErrorMessage(statusCode), code: statusCode);
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    String message;
    int? code;
    
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = '连接超时，请检查网络';
        code = -1001;
        break;
      case DioExceptionType.sendTimeout:
        message = '发送超时，请重试';
        code = -1002;
        break;
      case DioExceptionType.receiveTimeout:
        message = '响应超时，请重试';
        code = -1003;
        break;
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        message = _getErrorMessage(statusCode);
        code = statusCode;
        
        // 尝试解析错误响应
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          message = (data['message'] ?? data['error'] ?? message).toString();
        }
        break;
      case DioExceptionType.cancel:
        message = '请求已取消';
        code = -1004;
        break;
      case DioExceptionType.badCertificate:
        message = '证书验证失败';
        code = -1005;
        break;
      case DioExceptionType.connectionError:
        message = '网络连接失败，请检查网络设置';
        code = -1006;
        break;
      case DioExceptionType.unknown:
      default:
        message = '网络请求失败，请重试';
        code = -1000;
        break;
    }
    
    Logger.error('网络请求错误', error);
    return ApiResponse.error(message, code: code);
  }

  // 根据状态码获取错误信息
  String _getErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return '请求参数错误';
      case 401:
        return '未授权，请重新登录';
      case 403:
        return '访问被拒绝';
      case 404:
        return '请求的资源不存在';
      case 405:
        return '请求方法不被允许';
      case 408:
        return '请求超时';
      case 409:
        return '请求冲突';
      case 422:
        return '请求参数验证失败';
      case 429:
        return '请求过于频繁，请稍后重试';
      case 500:
        return '服务器内部错误';
      case 502:
        return '网关错误';
      case 503:
        return '服务不可用';
      case 504:
        return '网关超时';
      default:
        return '请求失败($statusCode)';
    }
  }

  // ==================== 认证管理 ====================

  // 设置认证令牌
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    Logger.debug('AUTH', '设置认证令牌');
  }

  // 清除认证令牌
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    Logger.debug('AUTH', '清除认证令牌');
  }

  // ==================== 配置管理 ====================

  // 更新基础URL
  void updateBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
    _dio.options.baseUrl = baseUrl;
    Logger.info('更新基础URL: $baseUrl');
  }

  // 设置超时时间
  void setTimeout({
    Duration? connectTimeout,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) {
    if (connectTimeout != null) {
      _dio.options.connectTimeout = connectTimeout;
    }
    if (receiveTimeout != null) {
      _dio.options.receiveTimeout = receiveTimeout;
    }
    if (sendTimeout != null) {
      _dio.options.sendTimeout = sendTimeout;
    }
    Logger.debug('CONFIG', '更新超时配置');
  }

  // 添加全局头部
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
    Logger.debug('CONFIG', '添加全局头部: $key = $value');
  }

  // 移除全局头部
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
    Logger.debug('CONFIG', '移除全局头部: $key');
  }

  // 获取当前配置
  Map<String, dynamic> getConfig() {
    return {
      'baseUrl': _dio.options.baseUrl,
      'connectTimeout': _dio.options.connectTimeout?.inMilliseconds,
      'receiveTimeout': _dio.options.receiveTimeout?.inMilliseconds,
      'sendTimeout': _dio.options.sendTimeout?.inMilliseconds,
      'headers': _dio.options.headers,
    };
  }

  // 取消所有请求
  void cancelAllRequests([String? reason]) {
    _dio.close(force: true); // 强制关闭所有请求连接
    Logger.warning('取消所有网络请求: ${reason ?? '用户操作'}');
  }
}

// 重试拦截器
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryCount = extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      Logger.warning('网络请求重试 ${retryCount + 1}/$maxRetries: ${err.requestOptions.path}');
      
      // 等待后重试
      await Future.delayed(retryDelay);
      
      // 更新重试次数
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.type == DioExceptionType.badResponse && 
            err.response?.statusCode != null &&
            err.response!.statusCode! >= 500);
  }
}