import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiConstants {
  // 禁止实例化
  ApiConstants._();
  
  // 基础URL配置
  static const String _devBaseUrl = 'https://dev-api.novelapp.com';
  static const String _prodBaseUrl = 'https://api.novelapp.com';
  
  // 根据环境选择基础URL
  static String get baseUrl => kDebugMode ? _devBaseUrl : _prodBaseUrl;
  
  // API版本
  static const String apiVersion = 'v1';
  
  // 完整API路径
  static String get apiPath => '$baseUrl/api/$apiVersion';
  
  // 应用信息
  static const String appVersion = '1.0.0';
  
  static String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  static String get osVersion {
    return Platform.operatingSystemVersion;
  }
  
  // ==================== 认证相关API ====================
  
  // 用户认证
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  static const String changePassword = '/auth/change-password';
  static const String validateToken = '/auth/validate';
  
  // 第三方登录
  static const String socialLogin = '/auth/social';
  static const String bindSocial = '/auth/bind-social';
  static const String unbindSocial = '/auth/unbind-social';
  
  // ==================== 用户相关API ====================
  
  // 用户信息
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String userAvatar = '/user/avatar';
  static const String userPreferences = '/user/preferences';
  static const String userStats = '/user/stats';
  
  // 用户设置
  static const String userSettings = '/user/settings';
  static const String updateSettings = '/user/settings';
  static const String privacySettings = '/user/privacy';
  
  // ==================== 小说相关API ====================
  
  // 小说基础
  static const String novels = '/novels';
  static const String novelDetail = '/novels/{id}';
  static const String novelChapters = '/novels/{id}/chapters';
  static const String chapterContent = '/chapters/{id}/content';
  static const String novelSearch = '/novels/search';
  static const String novelCategories = '/novels/categories';
  static const String novelTags = '/novels/tags';
  
  // 小说推荐和排行
  static const String novelRankings = '/novels/rankings';
  static const String novelRecommendations = '/novels/recommendations';
  static const String personalRecommendations = '/novels/recommendations/personal';
  static const String similarNovels = '/novels/{id}/similar';
  static const String hotNovels = '/novels/hot';
  static const String newNovels = '/novels/new';
  static const String completedNovels = '/novels/completed';
  
  // 小说统计
  static const String novelViews = '/novels/{id}/views';
  static const String novelRating = '/novels/{id}/rating';
  static const String novelComments = '/novels/{id}/comments';
  
  // ==================== 章节相关API ====================
  
  // 章节操作
  static const String chapterDetail = '/chapters/{id}';
  static const String chapterList = '/novels/{novelId}/chapters';
  static const String nextChapter = '/chapters/{id}/next';
  static const String previousChapter = '/chapters/{id}/previous';
  
  // ==================== 书架相关API ====================
  
  // 书架管理
  static const String bookshelf = '/bookshelf';
  static const String addToBookshelf = '/bookshelf/add';
  static const String removeFromBookshelf = '/bookshelf/remove';
  static const String bookshelfSync = '/bookshelf/sync';
  static const String bookshelfSort = '/bookshelf/sort';
  
  // 收藏夹
  static const String collections = '/collections';
  static const String createCollection = '/collections';
  static const String updateCollection = '/collections/{id}';
  static const String deleteCollection = '/collections/{id}';
  static const String addToCollection = '/collections/{id}/add';
  static const String removeFromCollection = '/collections/{id}/remove';
  
  // ==================== 阅读相关API ====================
  
  // 阅读进度
  static const String readingProgress = '/reading/progress';
  static const String updateProgress = '/reading/progress';
  static const String syncProgress = '/reading/progress/sync';
  static const String readingHistory = '/reading/history';
  
  // 书签
  static const String bookmarks = '/reading/bookmarks';
  static const String addBookmark = '/reading/bookmarks/add';
  static const String removeBookmark = '/reading/bookmarks/remove';
  static const String updateBookmark = '/reading/bookmarks/{id}';
  
  // 阅读设置
  static const String readerSettings = '/reading/settings';
  static const String updateReaderSettings = '/reading/settings';
  
  // ==================== 评论相关API ====================
  
  // 评论管理
  static const String comments = '/comments';
  static const String addComment = '/comments/add';
  static const String deleteComment = '/comments/{id}';
  static const String likeComment = '/comments/{id}/like';
  static const String unlikeComment = '/comments/{id}/unlike';
  static const String reportComment = '/comments/{id}/report';
  
  // 评论回复
  static const String commentReplies = '/comments/{id}/replies';
  static const String addReply = '/comments/{id}/replies/add';
  
  // ==================== 推送相关API ====================
  
  // 设备注册
  static const String registerDevice = '/push/register';
  static const String unregisterDevice = '/push/unregister';
  static const String updateDevice = '/push/device';
  
  // 推送设置
  static const String pushSettings = '/push/settings';
  static const String updatePushSettings = '/push/settings';
  static const String subscribeTopic = '/push/subscribe';
  static const String unsubscribeTopic = '/push/unsubscribe';
  
  // 通知消息
  static const String notifications = '/notifications';
  static const String markAsRead = '/notifications/{id}/read';
  static const String markAllAsRead = '/notifications/read-all';
  static const String deleteNotification = '/notifications/{id}';
  
  // ==================== 文件上传API ====================
  
  // 文件上传
  static const String uploadImage = '/upload/image';
  static const String uploadFile = '/upload/file';
  static const String uploadAvatar = '/upload/avatar';
  
  // ==================== 统计分析API ====================
  
  // 应用统计
  static const String analytics = '/analytics';
  static const String userBehavior = '/analytics/behavior';
  static const String readingStats = '/analytics/reading';
  static const String crashReport = '/analytics/crash';
  
  // 阅读统计
  static const String dailyStats = '/analytics/daily';
  static const String weeklyStats = '/analytics/weekly';
  static const String monthlyStats = '/analytics/monthly';
  
  // ==================== 系统相关API ====================
  
  // 系统信息
  static const String appUpdate = '/system/update';
  static const String systemNotice = '/system/notice';
  static const String systemConfig = '/system/config';
  static const String serverStatus = '/system/status';
  
  // 用户反馈
  static const String feedback = '/system/feedback';
  static const String reportBug = '/system/bug-report';
  static const String featureRequest = '/system/feature-request';
  
  // 关于页面
  static const String about = '/system/about';
  static const String privacyPolicy = '/system/privacy';
  static const String termsOfService = '/system/terms';
  
  // ==================== 请求头常量 ====================
  
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'NovelApp/1.0.0',
  };
  
  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
  };
  
  // ==================== 请求参数常量 ====================
  
  // 分页参数
  static const String pageParam = 'page';
  static const String pageSizeParam = 'page_size';
  static const String offsetParam = 'offset';
  static const String limitParam = 'limit';
  
  // 排序参数
  static const String sortParam = 'sort';
  static const String orderParam = 'order';
  
  // 过滤参数
  static const String categoryParam = 'category';
  static const String tagParam = 'tag';
  static const String statusParam = 'status';
  static const String keywordParam = 'keyword';
  
  // ==================== 排序选项 ====================
  
  // 排序字段
  static const String sortByTime = 'created_at';
  static const String sortByUpdateTime = 'updated_at';
  static const String sortByPopularity = 'popularity';
  static const String sortByRating = 'rating';
  static const String sortByWordCount = 'word_count';
  static const String sortByChapterCount = 'chapter_count';
  
  // 排序方向
  static const String orderAsc = 'asc';
  static const String orderDesc = 'desc';
  
  // ==================== 响应状态码 ====================
  
  static const int statusSuccess = 200;
  static const int statusCreated = 201;
  static const int statusAccepted = 202;
  static const int statusNoContent = 204;
  
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusMethodNotAllowed = 405;
  static const int statusConflict = 409;
  static const int statusTooManyRequests = 429;
  
  static const int statusServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
  static const int statusGatewayTimeout = 504;

  // ==================== 链接超时=====================
  static const int connectTimeout = 60;
  static const int receiveTimeout = 60;
  
  // ==================== 错误代码 ====================
  
  // 认证错误
  static const String errorCodeInvalidCredentials = 'INVALID_CREDENTIALS';
  static const String errorCodeTokenExpired = 'TOKEN_EXPIRED';
  static const String errorCodeTokenInvalid = 'TOKEN_INVALID';
  static const String errorCodeAccountLocked = 'ACCOUNT_LOCKED';
  static const String errorCodeAccountDisabled = 'ACCOUNT_DISABLED';
  
  // 注册错误
  static const String errorCodeEmailExists = 'EMAIL_EXISTS';
  static const String errorCodeUsernameExists = 'USERNAME_EXISTS';
  static const String errorCodeInvalidEmail = 'INVALID_EMAIL';
  static const String errorCodeWeakPassword = 'WEAK_PASSWORD';
  
  // 资源错误
  static const String errorCodeUserNotFound = 'USER_NOT_FOUND';
  static const String errorCodeBookNotFound = 'BOOK_NOT_FOUND';
  static const String errorCodeChapterNotFound = 'CHAPTER_NOT_FOUND';
  static const String errorCodeResourceNotFound = 'RESOURCE_NOT_FOUND';
  
  // 权限错误
  static const String errorCodeNoPermission = 'NO_PERMISSION';
  static const String errorCodeVipRequired = 'VIP_REQUIRED';
  static const String errorCodeChapterLocked = 'CHAPTER_LOCKED';
  
  // 系统错误
  static const String errorCodeNetworkError = 'NETWORK_ERROR';
  static const String errorCodeServerError = 'SERVER_ERROR';
  static const String errorCodeDatabaseError = 'DATABASE_ERROR';
  static const String errorCodeServiceUnavailable = 'SERVICE_UNAVAILABLE';
  
  // ==================== 缓存键 ====================
  
  static const String cacheKeyCategories = 'cache_categories';
  static const String cacheKeyTags = 'cache_tags';
  static const String cacheKeyRankings = 'cache_rankings';
  static const String cacheKeyRecommendations = 'cache_recommendations';
  static const String cacheKeyHotNovels = 'cache_hot_novels';
  static const String cacheKeyNewNovels = 'cache_new_novels';
  static const String cacheKeyUserProfile = 'cache_user_profile';
  
  // ==================== 辅助方法 ====================
  
  // 构建完整URL
  static String buildUrl(String endpoint, [Map<String, String>? pathParams]) {
    String url = apiPath + endpoint;
    
    if (pathParams != null) {
      pathParams.forEach((key, value) {
        url = url.replaceAll('{$key}', value);
      });
    }
    
    return url;
  }
  
  // 构建查询参数
  static String buildQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) return '';
    
    final queryParts = params.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .toList();
    
    return queryParts.isNotEmpty ? '?${queryParts.join('&')}' : '';
  }
  
  // 获取用户代理字符串
  static String getUserAgent() {
    return 'NovelApp/$appVersion ($platform; ${Platform.operatingSystemVersion})';
  }
  
  // 检查是否为成功状态码
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  // 检查是否为客户端错误
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }
  
  // 检查是否为服务器错误
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }
}