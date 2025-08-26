import 'package:flutter/material.dart';

class AppTheme {
  // 禁止实例化
  AppTheme._();
  
  // 主色系
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color secondaryVariant = Color(0xFF018786);
  
  // 背景色
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFB00020);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  
  // 文本颜色 - 日间模式
  static const Color textPrimaryColor = Color(0xFF212121);
  static const Color textSecondaryColor = Color(0xFF757575);
  static const Color textHintColor = Color(0xFFBDBDBD);
  static const Color textDisabledColor = Color(0xFF9E9E9E);
  
  // 夜间模式颜色
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  static const Color darkTextSecondaryColor = Color(0xFFB3B3B3);
  static const Color darkTextHintColor = Color(0xFF666666);
  
  // 字体大小
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeXXLarge = 24.0;
  static const double fontSizeTitle = 28.0;
  static const double fontSizeHeadline = 32.0;
  
  // 间距
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingRegular = 16.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double spacingXLarge = 40.0;
  static const double spacingXXLarge = 48.0;
  
  // 圆角
  static const double radiusXSmall = 2.0;
  static const double radiusSmall = 4.0;
  static const double radiusRegular = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  static const double radiusCircular = 50.0;
  
  // 阴影
  static List<BoxShadow> get shadowSmall => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
      
  static List<BoxShadow> get shadowMedium => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
      
  static List<BoxShadow> get shadowLarge => <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
  
  // 动画时长
  static const Duration animationDurationFast = Duration(milliseconds: 150);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // 防抖时长
  static const Duration debounceDelay = Duration(milliseconds: 500);
  static const Duration searchDebounceDelay = Duration(milliseconds: 800);
  
  // 通用尺寸
  static const double appBarHeight = 56.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 52.0;
  static const double listItemHeight = 72.0;
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 16.0;
  static const double iconSizeLarge = 32.0;
  
  // 书籍封面尺寸比例
  static const double bookCoverRatio = 0.75; // 宽高比 3:4
  
  // 阅读器相关常量
  static const double readerMinFontSize = 12.0;
  static const double readerMaxFontSize = 30.0;
  static const double readerDefaultFontSize = 16.0;
  
  static const double readerMinLineSpacing = 1.0;
  static const double readerMaxLineSpacing = 3.0;
  static const double readerDefaultLineSpacing = 1.5;
  
  static const double readerMinPageMargin = 16.0;
  static const double readerMaxPageMargin = 48.0;
  static const double readerDefaultPageMargin = 24.0;
}

// 阅读器主题枚举
enum ReaderTheme {
  light('日间模式', Color(0xFF212121), Color(0xFFF5F5F5)),
  dark('夜间模式', Color(0xFFE0E0E0), Color(0xFF121212)),
  sepia('护眼模式', Color(0xFF5D4E37), Color(0xFFF7F4E7)),
  paper('纸质模式', Color(0xFF2F2F2F), Color(0xFFFEFEF8)),
  green('绿色模式', Color(0xFF1B5E20), Color(0xFFE8F5E8)),
  blue('蓝色模式', Color(0xFF0D47A1), Color(0xFFE3F2FD));
  
  const ReaderTheme(this.name, this.textColor, this.backgroundColor);
  
  final String name;
  final Color textColor;
  final Color backgroundColor;
  
  // 获取对应的状态栏样式
  Brightness get statusBarBrightness {
    switch (this) {
      case ReaderTheme.dark:
        return Brightness.light;
      default:
        return Brightness.dark;
    }
  }
  
  // 获取对应的导航栏样式
  Color get navigationBarColor => backgroundColor;
}

// 翻页模式枚举
enum PageTurnMode {
  slide('左右滑动', Icons.swipe_left),
  cover('覆盖翻页', Icons.flip_to_front),
  curl('仿真翻页', Icons.auto_awesome),
  scroll('上下滚动', Icons.swap_vert),
  click('点击翻页', Icons.touch_app);
  
  const PageTurnMode(this.name, this.icon);
  
  final String name;
  final IconData icon;
}