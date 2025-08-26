import 'package:flutter/material.dart';
import '../../features/reader/presentation/widgets/reader_page_wrapper.dart';

/// 阅读器路由配置
class ReaderRoutes {
  static const String reader = '/reader';
  
  static Map<String, WidgetBuilder> get routes => <String, WidgetBuilder>{
      reader: (BuildContext context) {
        final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        return ReaderPageWrapper(
          novelId: args?['novelId'] as String? ?? '',
          chapterId: args?['chapterId'] as String?,
          chapterNumber: args?['chapterNumber'] as int?,
        );
      },
    };
}