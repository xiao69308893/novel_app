import 'package:flutter/material.dart';
import 'app_routes.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/book/presentation/pages/book_detail_page.dart';
import '../../features/book/presentation/pages/book_search_page.dart';
import '../../features/reader/presentation/pages/reader_page.dart';
import '../../features/bookshelf/presentation/pages/bookshelf_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/error_widget.dart';
import '../../core/utils/logger.dart';

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
        return _buildRoute(const HomePage(), settings);
        
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
        
      case AppRoutes.bookSearch:
        return _buildRoute(
          BookSearchPage(keyword: args?['keyword'] as String?),
          settings,
        );
        
      // 阅读器路由
      case AppRoutes.reader:
        if (args != null && 
            args.containsKey('bookId') && 
            args.containsKey('chapterId')) {
          return _buildRoute(
            ReaderPage(
              bookId: args['bookId'] as String,
              chapterId: args['chapterId'] as String,
              chapterNumber: args['chapterNumber'] as int?,
            ),
            settings,
          );
        }
        return _buildErrorRoute(settings, '缺少阅读器参数');
        
      // 书架路由
      case AppRoutes.bookshelf:
        return _buildRoute(const BookshelfPage(), settings);
        
      // 用户相关路由
      case AppRoutes.profile:
        return _buildRoute(const ProfilePage(), settings);
        
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
}