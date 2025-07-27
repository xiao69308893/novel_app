class AppRoutes {
  // 禁止实例化
  AppRoutes._();
  
  // 基础路由
  static const String splash = '/';
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  
  // 认证相关路由
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // 小说相关路由
  static const String bookDetail = '/book/detail';
  static const String bookSearch = '/book/search';
  static const String bookCategory = '/book/category';
  static const String bookRanking = '/book/ranking';
  
  // 阅读器路由
  static const String reader = '/reader';
  static const String readerSettings = '/reader/settings';
  static const String readerBookmarks = '/reader/bookmarks';
  
  // 书架路由
  static const String bookshelf = '/bookshelf';
  static const String collection = '/collection';
  static const String readingHistory = '/reading-history';
  
  // 用户相关路由
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String feedback = '/feedback';
  
  // 其他功能路由
  static const String notification = '/notification';
  static const String update = '/update';
  static const String webview = '/webview';
  
  // 获取所有路由列表
  static List<String> get allRoutes => [
        splash,
        home,
        onboarding,
        login,
        register,
        forgotPassword,
        resetPassword,
        verifyEmail,
        bookDetail,
        bookSearch,
        bookCategory,
        bookRanking,
        reader,
        readerSettings,
        readerBookmarks,
        bookshelf,
        collection,
        readingHistory,
        profile,
        settings,
        about,
        feedback,
        notification,
        update,
        webview,
      ];

  // 需要认证的路由
  static List<String> get authenticatedRoutes => [
        home,
        bookshelf,
        collection,
        readingHistory,
        profile,
        settings,
        reader,
        readerSettings,
        readerBookmarks,
      ];

  // 认证相关路由
  static List<String> get authRoutes => [
        login,
        register,
        forgotPassword,
        resetPassword,
        verifyEmail,
      ];
}