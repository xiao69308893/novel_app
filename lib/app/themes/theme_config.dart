import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';

class ThemeConfig {
  // 禁止实例化
  ThemeConfig._();
  
  // 日间主题
  static ThemeData get lightTheme {
    const ColorScheme colorScheme = ColorScheme.light(
      primary: AppTheme.primaryColor,
      primaryContainer: AppTheme.primaryVariant,
      secondaryContainer: AppTheme.secondaryVariant,
      onSecondary: Colors.white,
      onSurface: AppTheme.textPrimaryColor,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      
      // 字体配置
      fontFamily: 'SourceHanSans',
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimaryColor,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          fontFamily: 'SourceHanSans',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      
      // 文本主题
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeHeadline,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeTitle,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: AppTheme.fontSizeRegular,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AppTheme.textHintColor,
          fontSize: AppTheme.fontSizeSmall,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: AppTheme.textSecondaryColor,
          fontSize: AppTheme.fontSizeRegular,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppTheme.textHintColor,
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      
      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          ),
          elevation: 2,
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          minimumSize: const Size(double.infinity, AppTheme.buttonHeight),
          side: const BorderSide(color: AppTheme.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          ),
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.primaryColor,
          textStyle: const TextStyle(
            fontSize: AppTheme.fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        hintStyle: const TextStyle(color: AppTheme.textHintColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingRegular,
          vertical: AppTheme.spacingRegular,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: AppTheme.surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingSmall),
      ),
      
      // 分隔线主题
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade300,
        thickness: 1,
        space: 1,
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.surfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textHintColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        elevation: 8,
      ),
      
      // Chip主题
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        labelStyle: const TextStyle(
          color: AppTheme.textPrimaryColor,
          fontSize: AppTheme.fontSizeSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
      ),
    );
  }
  
  // 夜间主题
  static ThemeData get darkTheme {
    const ColorScheme colorScheme = ColorScheme.dark(
      primary: AppTheme.primaryColor,
      primaryContainer: AppTheme.primaryVariant,
      secondaryContainer: AppTheme.secondaryVariant,
      surface: AppTheme.darkSurfaceColor,
      error: AppTheme.errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      
      // 字体配置
      fontFamily: 'SourceHanSans',
      
      // AppBar主题
      appBarTheme: AppBarTheme(
        backgroundColor: AppTheme.darkSurfaceColor,
        foregroundColor: AppTheme.darkTextPrimaryColor,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          fontFamily: 'SourceHanSans',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      
      // 文本主题 (使用夜间模式颜色)
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeHeadline,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeTitle,
          fontWeight: FontWeight.bold,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeXXLarge,
          fontWeight: FontWeight.w600,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeXLarge,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeLarge,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: AppTheme.darkTextSecondaryColor,
          fontSize: AppTheme.fontSizeRegular,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          color: AppTheme.darkTextHintColor,
          fontSize: AppTheme.fontSizeSmall,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          color: AppTheme.darkTextSecondaryColor,
          fontSize: AppTheme.fontSizeRegular,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          color: AppTheme.darkTextHintColor,
          fontSize: AppTheme.fontSizeSmall,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
      
      // 卡片主题
      cardTheme: CardThemeData(
        color: AppTheme.darkSurfaceColor,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        margin: const EdgeInsets.all(AppTheme.spacingSmall),
      ),
      
      // 分隔线主题
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
      
      // 底部导航栏主题
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppTheme.darkSurfaceColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.darkTextHintColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // 对话框主题
      dialogTheme: DialogThemeData(
        backgroundColor: AppTheme.darkSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        elevation: 8,
      ),
      
      // Chip主题
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.1),
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.3),
        labelStyle: const TextStyle(
          color: AppTheme.darkTextPrimaryColor,
          fontSize: AppTheme.fontSizeSmall,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
      ),
    );
  }
}