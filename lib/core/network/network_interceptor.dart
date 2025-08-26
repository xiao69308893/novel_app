import 'package:dio/dio.dart';
import '../utils/logger.dart';
import '../utils/preferences_helper.dart';
import '../constants/api_constants.dart';

class NetworkInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 添加用户令牌
    final String? token = PreferencesHelper.getString(PreferenceKeys.userToken);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // 添加设备信息
    options.headers.addAll(<String, dynamic>{
      'X-Device-ID': await _getDeviceId(),
      'X-App-Version': ApiConstants.appVersion,
      'X-Platform': ApiConstants.platform,
      'X-OS-Version': ApiConstants.osVersion,
      'X-Request-ID': _generateRequestId(),
      'X-Timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    });

    // 记录请求日志
    Logger.network(
      options.method,
      options.uri.toString(),
      headers: options.headers,
      body: options.data,
    );

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 记录响应日志
    Logger.network(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      response: response.data?.toString(),
    );

    // 检查业务状态码
    if (response.data is Map<String, dynamic>) {
      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      final code = data['code'] ?? data['status_code'];
      
      // 处理特殊业务状态码
      if (code != null) {
        switch (code) {
          case 401:
          case '401':
            // token过期，清除本地认证信息
            _handleTokenExpired();
            break;
          case 403:
          case '403':
            // 权限不足
            Logger.warning('权限不足: ${response.requestOptions.path}');
            break;
        }
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 记录错误日志
    Logger.error(
      '网络请求错误: ${err.requestOptions.method} ${err.requestOptions.path}',
      err,
      err.stackTrace,
    );

    // 处理特定错误
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        Logger.warning('网络超时: ${err.requestOptions.path}');
        break;
      case DioExceptionType.badResponse:
        if (err.response?.statusCode == 401) {
          _handleTokenExpired();
        }
        break;
      case DioExceptionType.connectionError:
        Logger.warning('网络连接失败: ${err.requestOptions.path}');
        break;
      default:
        break;
    }

    handler.next(err);
  }

  // 获取设备ID
  Future<String> _getDeviceId() async {
    String? deviceId = PreferencesHelper.getString('device_id');
    if (deviceId == null || deviceId.isEmpty) {
      // 这里应该使用真实的设备ID生成逻辑
      deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await PreferencesHelper.setString('device_id', deviceId);
    }
    return deviceId;
  }

  // 生成请求ID
  String _generateRequestId() => 'req_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

  // 处理token过期
  void _handleTokenExpired() {
    Logger.warning('用户token已过期，清除本地认证信息');
    
    // 清除本地存储的认证信息
    PreferencesHelper.remove(PreferenceKeys.userToken);
    PreferencesHelper.remove(PreferenceKeys.refreshToken);
    PreferencesHelper.remove(PreferenceKeys.userInfo);
    
    // 这里可以发送事件通知UI跳转到登录页
    // 或者触发自动刷新token的逻辑
  }
}

// 认证拦截器 - 专门处理认证相关的逻辑
class AuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 检查是否需要认证
    if (_requiresAuth(options.path)) {
      final String? token = PreferencesHelper.getString(PreferenceKeys.userToken);
      
      if (token == null || token.isEmpty) {
        // 没有token，拒绝请求
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.cancel,
            message: '用户未登录',
          ),
        );
        return;
      }
      
      // 检查token是否即将过期
      if (await _isTokenExpiringSoon()) {
        try {
          await _refreshToken();
        } catch (e) {
          Logger.error('刷新token失败', e);
          handler.reject(
            DioException(
              requestOptions: options,
              type: DioExceptionType.cancel,
              message: 'token刷新失败',
            ),
          );
          return;
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果是401错误，尝试刷新token
    if (err.response?.statusCode == 401 && _requiresAuth(err.requestOptions.path)) {
      try {
        await _refreshToken();
        
        // 重新发送原始请求
        final Response response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        Logger.error('刷新token后重试请求失败', e);
      }
    }

    handler.next(err);
  }

  // 检查路径是否需要认证
  bool _requiresAuth(String path) {
    final List<String> authRequiredPaths = <String>[
      '/user/',
      '/bookshelf/',
      '/reading/',
      '/comments/',
      '/notifications/',
    ];
    
    return authRequiredPaths.any((String authPath) => path.startsWith(authPath));
  }

  // 检查token是否即将过期
  Future<bool> _isTokenExpiringSoon() async {
    final int tokenTime = PreferencesHelper.getInt('token_time');
    if (tokenTime == 0) return false;
    
    final int currentTime = DateTime.now().millisecondsSinceEpoch;
    const int tokenValidDuration = 7 * 24 * 60 * 60 * 1000; // 7天
    const int refreshThreshold = 24 * 60 * 60 * 1000; // 提前1天刷新
    
    return (currentTime - tokenTime) > (tokenValidDuration - refreshThreshold);
  }

  // 刷新token
  Future<void> _refreshToken() async {
    final String? refreshToken = PreferencesHelper.getString(PreferenceKeys.refreshToken);
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('没有刷新token');
    }

    try {
      final Dio dio = Dio();
      final Response response = await dio.post(
        '${ApiConstants.apiPath}${ApiConstants.refreshToken}',
        data: <String, String>{'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = response.data as Map<String, dynamic>;
        final String? newToken = data['access_token'] as String?;
        final String? newRefreshToken = data['refresh_token'] as String?;

        if (newToken != null) {
          await PreferencesHelper.setString(PreferenceKeys.userToken, newToken);
          await PreferencesHelper.setInt('token_time', DateTime.now().millisecondsSinceEpoch);
          
          if (newRefreshToken != null) {
            await PreferencesHelper.setString(PreferenceKeys.refreshToken, newRefreshToken);
          }
          
          Logger.info('token刷新成功');
        }
      } else {
        throw Exception('刷新token失败');
      }
    } catch (e) {
      Logger.error('刷新token异常', e);
      rethrow;
    }
  }
}

// 缓存拦截器 - 处理HTTP缓存
class CacheInterceptor extends Interceptor {
  final Map<String, CacheItem> _cache = <String, CacheItem>{};
  final Duration defaultCacheDuration = const Duration(minutes: 5);
  final int maxCacheSize = 100;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 只缓存GET请求
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    final String cacheKey = _getCacheKey(options);
    final CacheItem? cacheItem = _cache[cacheKey];

    // 检查缓存是否存在且未过期
    if (cacheItem != null && !cacheItem.isExpired) {
      Logger.debug('CACHE', '使用缓存: ${options.path}');
      
      final Response<Object> response = Response(
        requestOptions: options,
        data: cacheItem.data,
        statusCode: 200,
        headers: Headers.fromMap(<String, List<String>>{'x-cache': <String>['HIT']}),
      );
      
      handler.resolve(response);
      return;
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 只缓存成功的GET请求
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final String cacheKey = _getCacheKey(response.requestOptions);
      
      // 清理过期缓存
      _cleanExpiredCache();
      
      // 如果缓存已满，删除最旧的条目
      if (_cache.length >= maxCacheSize) {
        final String oldestKey = _cache.entries
            .reduce((MapEntry<String, CacheItem> a, MapEntry<String, CacheItem> b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
            .key;
        _cache.remove(oldestKey);
      }
      
      // 添加到缓存
      _cache[cacheKey] = CacheItem(
        data: response.data,
        timestamp: DateTime.now(),
        duration: _getCacheDuration(response.requestOptions.path),
      );
      
      Logger.debug('CACHE', '添加缓存: ${response.requestOptions.path}');
    }

    handler.next(response);
  }

  // 生成缓存键
  String _getCacheKey(RequestOptions options) => '${options.method}_${options.uri.toString()}';

  // 获取缓存时长
  Duration _getCacheDuration(String path) {
    // 根据不同的API路径设置不同的缓存时长
    if (path.contains('/novels/categories') || path.contains('/novels/tags')) {
      return const Duration(hours: 1); // 分类和标签缓存1小时
    } else if (path.contains('/novels/rankings')) {
      return const Duration(minutes: 15); // 排行榜缓存15分钟
    } else if (path.contains('/novels/recommendations')) {
      return const Duration(minutes: 30); // 推荐缓存30分钟
    }
    return defaultCacheDuration;
  }

  // 清理过期缓存
  void _cleanExpiredCache() {
    _cache.removeWhere((String key, CacheItem item) => item.isExpired);
  }

  // 清空所有缓存
  void clearCache() {
    _cache.clear();
    Logger.debug('CACHE', '清空所有缓存');
  }

  // 删除指定路径的缓存
  void removeCache(String path) {
    _cache.removeWhere((String key, CacheItem item) => key.contains(path));
    Logger.debug('CACHE', '删除路径缓存: $path');
  }
}

// 缓存项
class CacheItem {

  CacheItem({
    required this.data,
    required this.timestamp,
    required this.duration,
  });
  final dynamic data;
  final DateTime timestamp;
  final Duration duration;

  bool get isExpired => DateTime.now().isAfter(timestamp.add(duration));
}