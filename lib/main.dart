import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.dart';
import 'core/utils/logger.dart';
import 'core/utils/preferences_helper.dart';

void main() async {
  // 确保Flutter绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日志系统
  await Logger.init();
  
  // 初始化本地存储
  await PreferencesHelper.init();
  
  // 设置系统UI样式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 设置错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    Logger.error('Flutter错误', details.exception, details.stack);
  };
  
  runApp(const NovelApp());
}