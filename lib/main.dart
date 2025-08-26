import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'core/utils/logger.dart';
import 'core/utils/preferences_helper.dart';
import 'core/storage/database_helper.dart';
import 'core/storage/cache_manager.dart';
import 'core/network/api_client.dart';
import 'core/network/network_info.dart';
import 'features/bookself/bookshelf_module.dart';
import 'features/auth/auth_module.dart';
import 'app/app.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化日志系统
  Logger.init();

  // 初始化SharedPreferences
  await PreferencesHelper.init();
  Logger.info('本地存储初始化完成');

  // 初始化本地存储
  if (!kIsWeb) {
    // 只在非Web环境中初始化数据库
    try {
      await DatabaseHelper.instance.database;
      Logger.info('数据库初始化成功');
    } catch (e) {
      Logger.error('数据库初始化失败', e);
    }
  } else {
    Logger.info('Web环境：跳过数据库初始化');
  }
  
  // CacheManager会在获取instance时自动初始化
  CacheManager.instance;

  // 初始化依赖注入
  await _initializeDependencies();

  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter错误', details.exception, details.stack);
  };

  runApp(const NovelApp());
}

/// 初始化依赖注入
Future<void> _initializeDependencies() async {
  final GetIt getIt = GetIt.instance;

  // 注册核心服务
  getIt.registerLazySingleton(() => ApiClient.instance);
  getIt.registerLazySingleton(() => CacheManager.instance);
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(connectivity: Connectivity()));

  // 初始化模块
  await AuthModule.init();
  BookshelfModule.init();

  Logger.info('依赖注入初始化完成');
}