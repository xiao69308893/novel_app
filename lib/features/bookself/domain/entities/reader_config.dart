import 'package:equatable/equatable.dart';

/// 阅读器配置
class ReaderConfig extends Equatable {

  const ReaderConfig({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.fontFamily = 'System',
    this.backgroundColor = '#FFFFFF',
    this.textColor = '#000000',
    this.pageMargin = 16.0,
    this.isDarkMode = false,
    this.brightness = 1.0,
    this.autoTurnPage = false,
    this.turnPageInterval = 5,
    this.showProgress = true,
    this.showTime = true,
    this.showBattery = true,
  });

  factory ReaderConfig.fromJson(Map<String, dynamic> json) => ReaderConfig(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 16.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.5,
      fontFamily: json['fontFamily'] as String? ?? 'System',
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      textColor: json['textColor'] as String? ?? '#000000',
      pageMargin: (json['pageMargin'] as num?)?.toDouble() ?? 16.0,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 1.0,
      autoTurnPage: json['autoTurnPage'] as bool? ?? false,
      turnPageInterval: json['turnPageInterval'] as int? ?? 5,
      showProgress: json['showProgress'] as bool? ?? true,
      showTime: json['showTime'] as bool? ?? true,
      showBattery: json['showBattery'] as bool? ?? true,
    );
  /// 字体大小
  final double fontSize;
  
  /// 行间距
  final double lineHeight;
  
  /// 字体家族
  final String fontFamily;
  
  /// 背景颜色
  final String backgroundColor;
  
  /// 文字颜色
  final String textColor;
  
  /// 页面边距
  final double pageMargin;
  
  /// 是否夜间模式
  final bool isDarkMode;
  
  /// 屏幕亮度
  final double brightness;
  
  /// 是否自动翻页
  final bool autoTurnPage;
  
  /// 翻页间隔（秒）
  final int turnPageInterval;
  
  /// 是否显示进度条
  final bool showProgress;
  
  /// 是否显示时间
  final bool showTime;
  
  /// 是否显示电量
  final bool showBattery;

  @override
  List<Object?> get props => <Object?>[
        fontSize,
        lineHeight,
        fontFamily,
        backgroundColor,
        textColor,
        pageMargin,
        isDarkMode,
        brightness,
        autoTurnPage,
        turnPageInterval,
        showProgress,
        showTime,
        showBattery,
      ];

  ReaderConfig copyWith({
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    String? backgroundColor,
    String? textColor,
    double? pageMargin,
    bool? isDarkMode,
    double? brightness,
    bool? autoTurnPage,
    int? turnPageInterval,
    bool? showProgress,
    bool? showTime,
    bool? showBattery,
  }) => ReaderConfig(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      pageMargin: pageMargin ?? this.pageMargin,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      brightness: brightness ?? this.brightness,
      autoTurnPage: autoTurnPage ?? this.autoTurnPage,
      turnPageInterval: turnPageInterval ?? this.turnPageInterval,
      showProgress: showProgress ?? this.showProgress,
      showTime: showTime ?? this.showTime,
      showBattery: showBattery ?? this.showBattery,
    );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'fontSize': fontSize,
      'lineHeight': lineHeight,
      'fontFamily': fontFamily,
      'backgroundColor': backgroundColor,
      'textColor': textColor,
      'pageMargin': pageMargin,
      'isDarkMode': isDarkMode,
      'brightness': brightness,
      'autoTurnPage': autoTurnPage,
      'turnPageInterval': turnPageInterval,
      'showProgress': showProgress,
      'showTime': showTime,
      'showBattery': showBattery,
    };
}