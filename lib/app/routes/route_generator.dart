import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../../features/home/domain/usecases/get_home_data_usecase.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/data/datasources/home_remote_datasource.dart';
import '../../features/home/data/datasources/home_local_datasource.dart';
import '../../features/book/presentation/pages/book_detail_page.dart';
import '../../features/book/presentation/pages/book_search_page.dart';
import '../../features/bookself/presentation/pages/bookshelf_page.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/placeholder_page.dart';
import '../../core/utils/logger.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/bookself/presentation/blocs/bookshelf/bookshelf_bloc.dart';

class RouteGenerator {
  // 禁止实例化
  RouteGenerator._();
  
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    
    Logger.info('生成路由: ${settings.name}, 参数: $args');
    
    switch (settings.name) {
      // 基础路由
      case AppRoutes.splash:
        return _buildRoute(const SplashPage(), settings);
        
      case AppRoutes.home:
        return _buildRoute(
          BlocProvider(
            create: (context) => _createHomeCubit(),
            child: const HomePage(),
          ),
          settings,
        );
        
      // 认证相关路由
      case AppRoutes.login:
        return _buildRoute(const LoginPage(), settings);
        
      case AppRoutes.register:
        return _buildRoute(const RegisterPage(), settings);
        
      case AppRoutes.forgotPassword:
        return _buildRoute(const ForgotPasswordPage(), settings);
        
      // 小说相关路由
      case AppRoutes.bookDetail:
        if (args != null && args.containsKey('bookId')) {
          return _buildRoute(
            BookDetailPage(bookId: args['bookId'] as String),
            settings,
          );
        }
        return _buildErrorRoute(settings, '缺少书籍ID参数');
        
      // 书籍搜索页面
      case AppRoutes.bookSearch:
        return _buildRoute(
          BookSearchPage(initialKeyword: args?['keyword'] as String?),
          settings,
        );
        
      // 书架页面
      case AppRoutes.bookshelf:
        return _buildRoute(
          BlocProvider(
            create: (context) => GetIt.instance<BookshelfBloc>(),
            child: const BookshelfPage(),
          ),
          settings,
        );
        
      // TODO: 实现书籍分类页面
      // case AppRoutes.bookCategory:
      //   return _buildRoute(const BookCategoryPage(), settings);
        
      // TODO: 实现书籍排行榜页面
      // case AppRoutes.bookRanking:
      //   return _buildRoute(const BookRankingPage(), settings);
        
      // TODO: 实现阅读历史页面
      // case AppRoutes.readingHistory:
      //   return _buildRoute(const ReadingHistoryPage(), settings);
        
      // TODO: 实现阅读器页面
      // case AppRoutes.reader:
      //   if (args != null && 
      //       args.containsKey('bookId') && 
      //       args.containsKey('chapterId')) {
      //     return _buildRoute(
      //       ReaderPage(
      //         bookId: args['bookId'] as String,
      //         chapterId: args['chapterId'] as String,
      //         chapterNumber: args['chapterNumber'] as int?,
      //       ),
      //       settings,
      //     );
      //   }
      //   return _buildErrorRoute(settings, '缺少阅读器参数');
        
      // TODO: 实现用户资料页面
      // case AppRoutes.profile:
      //   return _buildRoute(const ProfilePage(), settings);
        
      // Profile相关路由 (临时使用占位页面)
      case '/profile/edit':
        return _buildRoute(
          const PlaceholderPage(
            title: '编辑资料',
            icon: Icons.person_outline,
          ),
          settings,
        );
        
      case '/profile/settings':
        return _buildRoute(
          const PlaceholderPage(
            title: '设置',
            icon: Icons.settings,
          ),
          settings,
        );
        
      case '/profile/bookmarks':
        return _buildRoute(
          const PlaceholderPage(
            title: '我的书签',
            icon: Icons.bookmark_outline,
          ),
          settings,
        );
        
      case '/profile/cache':
        return _buildRoute(
          const PlaceholderPage(
            title: '缓存管理',
            icon: Icons.storage,
          ),
          settings,
        );
        
      case '/profile/stats':
        return _buildRoute(
          const PlaceholderPage(
            title: '阅读统计',
            icon: Icons.assessment,
          ),
          settings,
        );
        
      case '/profile/help':
        return _buildRoute(
          const PlaceholderPage(
            title: '帮助与反馈',
            icon: Icons.help_outline,
          ),
          settings,
        );
        
      case '/profile/about':
        return _buildRoute(
          const PlaceholderPage(
            title: '关于',
            icon: Icons.info_outline,
          ),
          settings,
        );
        
      // 其他缺失路由的占位页面
      case AppRoutes.bookCategory:
        return _buildRoute(
          const PlaceholderPage(
            title: '图书分类',
            icon: Icons.category,
          ),
          settings,
        );
        
      case AppRoutes.bookRanking:
        return _buildRoute(
          const PlaceholderPage(
            title: '排行榜',
            icon: Icons.trending_up,
          ),
          settings,
        );
        
      case AppRoutes.readingHistory:
        return _buildRoute(
          const PlaceholderPage(
            title: '阅读历史',
            icon: Icons.history,
          ),
          settings,
        );
        
      case AppRoutes.reader:
        return _buildRoute(
          const PlaceholderPage(
            title: '阅读器',
            icon: Icons.book,
            message: '阅读器功能正在开发中',
          ),
          settings,
        );
        
      case AppRoutes.settings:
        return _buildRoute(
          const PlaceholderPage(
            title: '设置',
            icon: Icons.settings,
          ),
          settings,
        );
        
      case AppRoutes.feedback:
        return _buildRoute(
          const PlaceholderPage(
            title: '意见反馈',
            icon: Icons.feedback,
          ),
          settings,
        );
        
      // 权限相关路由
      case '/no-permission':
        return _buildRoute(
          const PlaceholderPage(
            title: '权限不足',
            icon: Icons.lock,
            message: '您没有权限访问此页面',
          ),
          settings,
        );
        
      // 默认错误路由
      default:
        return _buildErrorRoute(settings, '页面不存在');
    }
  }
  
  // 构建普通路由
  static Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(animation, child, settings.name);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }
  
  // 构建页面切换动画
  static Widget _buildTransition(
    Animation<double> animation,
    Widget child,
    String? routeName,
  ) {
    // 根据路由类型选择不同的动画
    switch (routeName) {
      case AppRoutes.splash:
        // 启动页面淡入动画
        return FadeTransition(opacity: animation, child: child);
        
      case AppRoutes.login:
      case AppRoutes.register:
        // 认证页面从下往上滑入
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
        
      case AppRoutes.reader:
        // 阅读器页面淡入
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: child,
        );
        
      default:
        // 默认左右滑动动画
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: child,
        );
    }
  }
  
  // 构建错误路由
  static Route<dynamic> _buildErrorRoute(
    RouteSettings settings,
    String message,
  ) {
    Logger.error('路由错误: ${settings.name} - $message');
    
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('页面未找到'),
        ),
        body: Center(
          child: AppErrorWidget(
            message: message,
            description: '路由: ${settings.name}',
            onRetry: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              }
            },
            retryText: '返回',
          ),
        ),
      ),
    );
  }
  
  // 检查路由是否需要认证
  static bool requiresAuth(String? routeName) {
    if (routeName == null) return false;
    return AppRoutes.authenticatedRoutes.contains(routeName);
  }
  
  // 检查是否为认证相关路由
  static bool isAuthRoute(String? routeName) {
    if (routeName == null) return false;
    return AppRoutes.authRoutes.contains(routeName);
  }

  // 创建 HomeCubit 实例
  static HomeCubit _createHomeCubit() {
    // 创建依赖项
    final apiClient = ApiClient.instance;
    final remoteDataSource = HomeRemoteDataSourceImpl(apiClient: apiClient);
    final localDataSource = HomeLocalDataSourceImpl();
    final networkInfo = NetworkInfoImpl(connectivity: Connectivity());
    
    // 创建仓储
    final repository = HomeRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      networkInfo: networkInfo,
    );
    
    // 创建用例
    final getHomeDataUseCase = GetHomeDataUseCase(repository);
    
    // 创建并返回 HomeCubit
    return HomeCubit(getHomeDataUseCase: getHomeDataUseCase);
  }
}

// 临时的网络信息实现
class _MockNetworkInfo {
  Future<bool> get isConnected async => true;
}