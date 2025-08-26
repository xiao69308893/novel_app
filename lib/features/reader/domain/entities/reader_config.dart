import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// 阅读器主题枚举
enum ReaderTheme {
  light('light', '明亮主题', Colors.white, Colors.black),
  dark('dark', '暗黑主题', Color(0xFF1A1A1A), Colors.white),
  sepia('sepia', '护眼主题', Color(0xFFF5F5DC), Color(0xFF5D4037));

  const ReaderTheme(this.value, this.displayName, this.backgroundColor, this.textColor);
  
  final String value;
  final String displayName;
  final Color backgroundColor;
  final Color textColor;
}

/// 翻页模式枚举
enum PageMode {
  slide('slide', '滑动翻页'),
  curl('curl', '仿真翻页'),
  fade('fade', '淡入淡出'),
  scroll('scroll', '滚动阅读');

  const PageMode(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// 阅读器配置实体
class ReaderConfig extends Equatable {

  const ReaderConfig({
    this.fontSize = 18.0,
    this.lineHeight = 1.5,
    this.pageMargin = const EdgeInsets.all(20.0),
    this.theme = ReaderTheme.light,
    this.pageMode = PageMode.slide,
    this.volumeKeyTurnPage = false,
    this.keepScreenOn = true,
    this.showStatusBar = true,
    this.fullScreenMode = false,
    this.autoPageInterval = 3,
    this.fontFamily = 'System',
  });

  /// 从Map创建
  factory ReaderConfig.fromMap(Map<String, dynamic> map) => ReaderConfig(
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.5,
      pageMargin: EdgeInsets.only(
        left: (map['pageMarginLeft'] as num?)?.toDouble() ?? 20.0,
        top: (map['pageMarginTop'] as num?)?.toDouble() ?? 20.0,
        right: (map['pageMarginRight'] as num?)?.toDouble() ?? 20.0,
        bottom: (map['pageMarginBottom'] as num?)?.toDouble() ?? 20.0,
      ),
      theme: ReaderTheme.values.firstWhere(
        (ReaderTheme theme) => theme.value == map['theme'],
        orElse: () => ReaderTheme.light,
      ),
      pageMode: PageMode.values.firstWhere(
        (PageMode mode) => mode.value == map['pageMode'],
        orElse: () => PageMode.slide,
      ),
      volumeKeyTurnPage: (map['volumeKeyTurnPage'] as bool?) ?? false,
      keepScreenOn: (map['keepScreenOn'] as bool?) ?? true,
      showStatusBar: (map['showStatusBar'] as bool?) ?? true,
      fullScreenMode: (map['fullScreenMode'] as bool?) ?? false,
      autoPageInterval: (map['autoPageInterval'] as int?) ?? 3,
      fontFamily: (map['fontFamily'] as String?) ?? 'System',
    );
  /// 字体大小
  final double fontSize;
  
  /// 行高
  final double lineHeight;
  
  /// 页边距
  final EdgeInsets pageMargin;
  
  /// 阅读主题
  final ReaderTheme theme;
  
  /// 翻页模式
  final PageMode pageMode;
  
  /// 音量键翻页
  final bool volumeKeyTurnPage;
  
  /// 屏幕常亮
  final bool keepScreenOn;
  
  /// 显示状态栏
  final bool showStatusBar;
  
  /// 全屏模式
  final bool fullScreenMode;
  
  /// 自动翻页间隔（秒）
  final int autoPageInterval;
  
  /// 字体名称
  final String fontFamily;

  /// 获取文本样式
  TextStyle get textStyle => TextStyle(
    fontSize: fontSize,
    height: lineHeight,
    color: theme.textColor,
    fontFamily: fontFamily,
  );

  /// 复制并修改配置
  ReaderConfig copyWith({
    double? fontSize,
    double? lineHeight,
    EdgeInsets? pageMargin,
    ReaderTheme? theme,
    PageMode? pageMode,
    bool? volumeKeyTurnPage,
    bool? keepScreenOn,
    bool? showStatusBar,
    bool? fullScreenMode,
    int? autoPageInterval,
    String? fontFamily,
  }) => ReaderConfig(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      pageMargin: pageMargin ?? this.pageMargin,
      theme: theme ?? this.theme,
      pageMode: pageMode ?? this.pageMode,
      volumeKeyTurnPage: volumeKeyTurnPage ?? this.volumeKeyTurnPage,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      fullScreenMode: fullScreenMode ?? this.fullScreenMode,
      autoPageInterval: autoPageInterval ?? this.autoPageInterval,
      fontFamily: fontFamily ?? this.fontFamily,
    );

  /// 转换为Map
  Map<String, dynamic> toMap() => <String, dynamic>{
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'pageMarginLeft': pageMargin.left,
      'pageMarginTop': pageMargin.top,
      'pageMarginRight': pageMargin.right,
      'pageMarginBottom': pageMargin.bottom,
      'theme': theme.value,
      'pageMode': pageMode.value,
      'volumeKeyTurnPage': volumeKeyTurnPage,
      'keepScreenOn': keepScreenOn,
      'showStatusBar': showStatusBar,
      'fullScreenMode': fullScreenMode,
      'autoPageInterval': autoPageInterval,
      'fontFamily': fontFamily,
    };

  @override
  List<Object?> get props => <Object?>[
    fontSize,
    lineHeight,
    pageMargin,
    theme,
    pageMode,
    volumeKeyTurnPage,
    keepScreenOn,
    showStatusBar,
    fullScreenMode,
    autoPageInterval,
    fontFamily,
  ];
}