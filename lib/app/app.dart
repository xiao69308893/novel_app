import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';
import 'themes/theme_config.dart';
import '../core/utils/logger.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/auth/data/repositories/auth_repository.dart';

class NovelApp extends StatelessWidget {
  const NovelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // 设计稿尺寸
      minTextAdapt: true, // 文本适配
      splitScreenMode: true, // 分屏模式支持
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // 认证状态管理
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                authRepository: AuthRepository(),
              ),
            ),
            // 可以在这里添加其他的全局BLoC
          ],
          child: MaterialApp(
            title: '小说阅读器',
            debugShowCheckedModeBanner: false,
            
            // 主题配置
            theme: ThemeConfig.lightTheme,
            darkTheme: ThemeConfig.darkTheme,
            themeMode: ThemeMode.system,
            
            // 路由配置
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            
            // 导航观察器
            navigatorObservers: [
              _NavigatorObserver(),
            ],
            
            // 本地化配置
            locale: const Locale('zh', 'CN'),
            supportedLocales: const [
              Locale('zh', 'CN'), // 中文
              Locale('en', 'US'), // 英文
            ],
            
            // 错误页面构建器
            builder: (context, child) {
              // 设置文本缩放因子范围
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaleFactor: MediaQuery.of(context)
                      .textScaleFactor
                      .clamp(0.8, 1.2), // 限制文本缩放范围
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}

// 导航观察器 - 用于路由监听和日志记录
class _NavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    Logger.info('导航推入: ${route.settings.name}');
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    Logger.info('导航弹出: ${route.settings.name}');
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    Logger.info('导航替换: ${oldRoute?.settings.name} -> ${newRoute?.settings.name}');
  }
}