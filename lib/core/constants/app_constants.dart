class AppConstants {
  // 禁止实例化
  AppConstants._();
  
  // 应用信息
  static const String appName = '小说阅读器';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String appDescription = '跨平台小说阅读应用';
  static const String appPackageName = 'com.novelapp.reader';
  
  // 开发者信息
  static const String developerName = '小说开发团队';
  static const String developerEmail = 'support@novelapp.com';
  static const String officialWebsite = 'https://www.novelapp.com';
  static const String privacyPolicyUrl = 'https://www.novelapp.com/privacy';
  static const String termsOfServiceUrl = 'https://www.novelapp.com/terms';
  
  // 分页配置
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  static const int loadMoreThreshold = 5; // 滚动到倒数第几个时开始加载更多
  
  // 缓存配置
  static const int maxCacheSize = 500; // MB
  static const int defaultCacheSize = 200; // MB
  static const int cacheExpiredDays = 7; // 天
  static const int maxCachedChapters = 50; // 最大缓存章节数
  
  // 阅读器配置
  static const double minFontSize = 12.0;
  static const double maxFontSize = 30.0;
  static const double defaultFontSize = 16.0;
  static const double fontSizeStep = 2.0;
  
  static const double minLineSpacing = 1.0;
  static const double maxLineSpacing = 3.0;
  static const double defaultLineSpacing = 1.5;
  static const double lineSpacingStep = 0.1;
  
  static const double minPageMargin = 16.0;
  static const double maxPageMargin = 48.0;
  static const double defaultPageMargin = 24.0;
  static const double pageMarginStep = 4.0;
  
  static const double minBrightness = 0.1;
  static const double maxBrightness = 1.0;
  static const double defaultBrightness = 0.5;
  
  // 网络配置
  static const int connectTimeout = 30; // 秒
  static const int receiveTimeout = 30; // 秒
  static const int maxRetryCount = 3;
  static const int retryDelay = 1000; // 毫秒
  
  // 图片配置
  static const int maxImageCacheSize = 100; // MB
  static const int imageQuality = 80; // 压缩质量 0-100
  static const int maxImageWidth = 800; // 最大图片宽度
  static const int maxImageHeight = 1200; // 最大图片高度
  
  // 文件配置
  static const List<String> supportedImageFormats = <String>['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> supportedDocumentFormats = <String>['txt', 'epub', 'pdf'];
  static const int maxFileSize = 50; // MB
  
  // 推送配置
  static const String fcmSenderId = '123456789';
  static const String firebaseAppId = 'your-firebase-app-id';
  static const List<String> pushTopics = <String>['all', 'updates', 'recommendations'];
  
  // 广告配置（可选）
  static const String adMobAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx';
  static const String bannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
  static const String interstitialAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
  static const String rewardedAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';
  
  // 社交分享配置
  static const Map<String, String> socialPlatforms = <String, String>{
    'weixin': 'WeChat',
    'weibo': 'Weibo',
    'qq': 'QQ',
    'douban': 'Douban',
  };
  
  // 正则表达式
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  
  static final RegExp phoneRegex = RegExp(
    r'^1[3-9]\d{9}$',
  );
  
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{6,20}$',
  );
  
  static final RegExp usernameRegex = RegExp(
    r'^[a-zA-Z0-9_\u4e00-\u9fa5]{2,20}$',
  );
  
  // 动画时长
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  static const Duration pageTransitionDuration = Duration(milliseconds: 250);
  
  // 防抖时长
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration searchDebounceDelay = Duration(milliseconds: 800);
  static const Duration scrollDebounceDelay = Duration(milliseconds: 100);
  
  // 自动保存间隔
  static const Duration autoSaveInterval = Duration(seconds: 30);
  static const Duration progressSyncInterval = Duration(minutes: 5);
  
  // 错误消息
  static const String networkErrorMessage = '网络连接失败，请检查网络设置';
  static const String serverErrorMessage = '服务器繁忙，请稍后重试';
  static const String unknownErrorMessage = '未知错误，请联系客服';
  static const String noDataMessage = '暂无数据';
  static const String loadingMessage = '加载中...';
  static const String loadingMoreMessage = '加载更多...';
  static const String noMoreDataMessage = '没有更多数据了';
  static const String refreshingMessage = '刷新中...';
  
  // 成功消息
  static const String loginSuccessMessage = '登录成功';
  static const String registerSuccessMessage = '注册成功';
  static const String saveSuccessMessage = '保存成功';
  static const String deleteSuccessMessage = '删除成功';
  static const String updateSuccessMessage = '更新成功';
  
  // 确认消息
  static const String exitConfirmMessage = '确定要退出应用吗？';
  static const String deleteConfirmMessage = '确定要删除吗？';
  static const String clearCacheConfirmMessage = '确定要清空缓存吗？';
  static const String resetSettingsConfirmMessage = '确定要重置设置吗？';
  
  // 小说分类
  static const List<String> novelCategories = <String>[
    '都市言情',
    '古代言情',
    '玄幻奇幻',
    '武侠仙侠',
    '科幻未来',
    '军事历史',
    '游戏竞技',
    '悬疑推理',
    '青春校园',
    '职场商战',
  ];
  
  // 小说标签
  static const List<String> novelTags = <String>[
    '完结',
    '连载',
    '热门',
    '新书',
    '精品',
    '独家',
    '免费',
    'VIP',
    '男频',
    '女频',
  ];
  
  // 排序方式
  static const Map<String, String> sortOptions = <String, String>{
    'update_time': '最近更新',
    'create_time': '最新发布',
    'popularity': '人气最高',
    'rating': '评分最高',
    'word_count': '字数最多',
    'chapter_count': '章节最多',
  };
  
  // 阅读统计
  static const Map<String, String> readingStats = <String, String>{
    'total_time': '总阅读时长',
    'books_read': '已读书籍',
    'chapters_read': '已读章节',
    'words_read': '已读字数',
    'average_speed': '平均阅读速度',
  };
}

// 图片资源常量
class ImageAssets {
  // 禁止实例化
  ImageAssets._();
  
  static const String _basePath = 'assets/images/';
  
  // 启动页
  static const String splashLogo = '${_basePath}splash_logo.png';
  static const String splashBackground = '${_basePath}splash_bg.png';
  
  // 占位图
  static const String placeholderBook = '${_basePath}placeholder_book.png';
  static const String placeholderAvatar = '${_basePath}placeholder_avatar.png';
  static const String placeholderImage = '${_basePath}placeholder_image.png';
  static const String placeholderBanner = '${_basePath}placeholder_banner.png';
  
  // 引导页
  static const String onboarding1 = '${_basePath}onboarding_1.png';
  static const String onboarding2 = '${_basePath}onboarding_2.png';
  static const String onboarding3 = '${_basePath}onboarding_3.png';
  
  // 空状态
  static const String emptyBooks = '${_basePath}empty_books.png';
  static const String emptySearch = '${_basePath}empty_search.png';
  static const String emptyHistory = '${_basePath}empty_history.png';
  static const String emptyBookmarks = '${_basePath}empty_bookmarks.png';
  
  // 错误状态
  static const String errorNetwork = '${_basePath}error_network.png';
  static const String errorServer = '${_basePath}error_server.png';
  static const String error404 = '${_basePath}error_404.png';
  static const String errorGeneral = '${_basePath}error_general.png';
  
  // 功能图标
  static const String iconReading = '${_basePath}icon_reading.png';
  static const String iconBookshelf = '${_basePath}icon_bookshelf.png';
  static const String iconSettings = '${_basePath}icon_settings.png';
  static const String iconTheme = '${_basePath}icon_theme.png';
}

// 图标资源常量
class IconAssets {
  // 禁止实例化
  IconAssets._();
  
  static const String _basePath = 'assets/icons/';
  
  // 底部导航
  static const String homeInactive = '${_basePath}home_inactive.svg';
  static const String homeActive = '${_basePath}home_active.svg';
  static const String bookshelfInactive = '${_basePath}bookshelf_inactive.svg';
  static const String bookshelfActive = '${_basePath}bookshelf_active.svg';
  static const String profileInactive = '${_basePath}profile_inactive.svg';
  static const String profileActive = '${_basePath}profile_active.svg';
  
  // 阅读器
  static const String readerSettings = '${_basePath}reader_settings.svg';
  static const String readerBookmark = '${_basePath}reader_bookmark.svg';
  static const String readerProgress = '${_basePath}reader_progress.svg';
  static const String readerBrightness = '${_basePath}reader_brightness.svg';
  static const String readerFont = '${_basePath}reader_font.svg';
  static const String readerTheme = '${_basePath}reader_theme.svg';
  
  // 功能图标
  static const String search = '${_basePath}search.svg';
  static const String filter = '${_basePath}filter.svg';
  static const String sort = '${_basePath}sort.svg';
  static const String more = '${_basePath}more.svg';
  static const String share = '${_basePath}share.svg';
  static const String download = '${_basePath}download.svg';
  static const String notification = '${_basePath}notification.svg';
  static const String star = '${_basePath}star.svg';
  static const String heart = '${_basePath}heart.svg';
  
  // 社交平台
  static const String wechat = '${_basePath}wechat.svg';
  static const String weibo = '${_basePath}weibo.svg';
  static const String qq = '${_basePath}qq.svg';
  static const String douban = '${_basePath}douban.svg';
}