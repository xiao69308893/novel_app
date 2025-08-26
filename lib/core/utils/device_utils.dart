import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'logger.dart';

class DeviceUtils {
  // 禁止实例化
  DeviceUtils._();

  static DeviceInfoPlugin? _deviceInfo;
  static PackageInfo? _packageInfo;

  // 初始化设备信息
  static Future<void> init() async {
    try {
      _deviceInfo = DeviceInfoPlugin();
      _packageInfo = await PackageInfo.fromPlatform();
      Logger.info('设备工具初始化完成');
    } catch (e) {
      Logger.error('设备工具初始化失败', e);
    }
  }

  // ==================== 设备基础信息 ====================

  // 获取设备类型
  static String get platform {
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isFuchsia) return 'Fuchsia';
    return 'Unknown';
  }

  // 是否为移动端
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  // 是否为桌面端
  static bool get isDesktop => 
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  // 是否为Web端
  static bool get isWeb => kIsWeb;

  // 是否为调试模式
  static bool get isDebug => kDebugMode;

  // 是否为发布模式
  static bool get isRelease => kReleaseMode;

  // 是否为Profile模式
  static bool get isProfile => kProfileMode;

  // ==================== Android设备信息 ====================

  // 获取Android设备信息
  static Future<AndroidDeviceInfo?> getAndroidInfo() async {
    if (!Platform.isAndroid) return null;
    
    try {
      return await _deviceInfo!.androidInfo;
    } catch (e) {
      Logger.error('获取Android设备信息失败', e);
      return null;
    }
  }

  // 获取Android设备ID
  static Future<String?> getAndroidId() async {
    final AndroidDeviceInfo? info = await getAndroidInfo();
    return info?.id;
  }

  // 获取Android设备型号
  static Future<String?> getAndroidModel() async {
    final AndroidDeviceInfo? info = await getAndroidInfo();
    return info?.model;
  }

  // 获取Android设备品牌
  static Future<String?> getAndroidBrand() async {
    final AndroidDeviceInfo? info = await getAndroidInfo();
    return info?.brand;
  }

  // 获取Android系统版本
  static Future<String?> getAndroidVersion() async {
    final AndroidDeviceInfo? info = await getAndroidInfo();
    return info?.version.release;
  }

  // 获取Android SDK版本
  static Future<int?> getAndroidSdkInt() async {
    final AndroidDeviceInfo? info = await getAndroidInfo();
    return info?.version.sdkInt;
  }

  // ==================== iOS设备信息 ====================

  // 获取iOS设备信息
  static Future<IosDeviceInfo?> getIosInfo() async {
    if (!Platform.isIOS) return null;
    
    try {
      return await _deviceInfo!.iosInfo;
    } catch (e) {
      Logger.error('获取iOS设备信息失败', e);
      return null;
    }
  }

  // 获取iOS设备ID
  static Future<String?> getIosId() async {
    final IosDeviceInfo? info = await getIosInfo();
    return info?.identifierForVendor;
  }

  // 获取iOS设备型号
  static Future<String?> getIosModel() async {
    final IosDeviceInfo? info = await getIosInfo();
    return info?.model;
  }

  // 获取iOS设备名称
  static Future<String?> getIosName() async {
    final IosDeviceInfo? info = await getIosInfo();
    return info?.name;
  }

  // 获取iOS系统版本
  static Future<String?> getIosVersion() async {
    final IosDeviceInfo? info = await getIosInfo();
    return info?.systemVersion;
  }

  // ==================== 应用信息 ====================

  // 获取应用名称
  static String get appName => _packageInfo?.appName ?? 'Unknown';

  // 获取应用包名
  static String get packageName => _packageInfo?.packageName ?? 'Unknown';

  // 获取应用版本号
  static String get version => _packageInfo?.version ?? '1.0.0';

  // 获取应用构建号
  static String get buildNumber => _packageInfo?.buildNumber ?? '1';

  // 获取应用完整版本信息
  static String get fullVersion => '$version+$buildNumber';

  // ==================== 设备能力检测 ====================

  // 检查是否支持生物识别
  static Future<bool> supportsBiometric() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        return info?.version.sdkInt != null && info!.version.sdkInt >= 23;
      } else if (Platform.isIOS) {
        // iOS 8.0+ 支持 Touch ID，iOS 11.0+ 支持 Face ID
        return true;
      }
      return false;
    } catch (e) {
      Logger.error('检查生物识别支持失败', e);
      return false;
    }
  }

  // 检查是否支持相机
  static Future<bool> supportsCamera() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        return info?.systemFeatures.contains('android.hardware.camera') ?? false;
      } else if (Platform.isIOS) {
        return true; // iOS设备通常都有相机
      }
      return false;
    } catch (e) {
      Logger.error('检查相机支持失败', e);
      return false;
    }
  }

  // 检查是否支持NFC
  static Future<bool> supportsNFC() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        return info?.systemFeatures.contains('android.hardware.nfc') ?? false;
      } else if (Platform.isIOS) {
        // iOS 11+ 支持 Core NFC
        final IosDeviceInfo? info = await getIosInfo();
        if (info?.systemVersion != null) {
          final double? version = double.tryParse(info!.systemVersion.split('.').first);
          return version != null && version >= 11;
        }
      }
      return false;
    } catch (e) {
      Logger.error('检查NFC支持失败', e);
      return false;
    }
  }

  // ==================== 系统功能 ====================

  // 设置系统UI样式
  static void setSystemUIOverlay({
    Color? statusBarColor,
    Brightness? statusBarBrightness,
    Brightness? statusBarIconBrightness,
    Color? systemNavigationBarColor,
    Brightness? systemNavigationBarIconBrightness,
  }) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: statusBarColor,
        statusBarBrightness: statusBarBrightness,
        statusBarIconBrightness: statusBarIconBrightness,
        systemNavigationBarColor: systemNavigationBarColor,
        systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      ),
    );
  }

  // 隐藏状态栏
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: <SystemUiOverlay>[]);
  }

  // 显示状态栏
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, 
        overlays: SystemUiOverlay.values);
  }

  // 设置屏幕方向
  static void setOrientation(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  // 锁定竖屏
  static void lockPortrait() {
    setOrientation(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  // 锁定横屏
  static void lockLandscape() {
    setOrientation(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // 解锁屏幕方向
  static void unlockOrientation() {
    setOrientation(DeviceOrientation.values);
  }

  // ==================== 振动和反馈 ====================

  // 轻微振动
  static Future<void> lightVibration() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      Logger.error('轻微振动失败', e);
    }
  }

  // 中等振动
  static Future<void> mediumVibration() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      Logger.error('中等振动失败', e);
    }
  }

  // 重度振动
  static Future<void> heavyVibration() async {
    try {
      await HapticFeedback.heavyImpact();
    } catch (e) {
      Logger.error('重度振动失败', e);
    }
  }

  // 选择反馈
  static Future<void> selectionClick() async {
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      Logger.error('选择反馈失败', e);
    }
  }

  // ==================== 设备状态 ====================

  // 获取设备唯一标识符
  static Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final String? id = await getAndroidId();
        return id ?? 'unknown_android_device';
      } else if (Platform.isIOS) {
        final String? id = await getIosId();
        return id ?? 'unknown_ios_device';
      }
      return 'unknown_device';
    } catch (e) {
      Logger.error('获取设备ID失败', e);
      return 'error_device_id';
    }
  }

  // 获取设备信息摘要
  static Future<Map<String, dynamic>> getDeviceSummary() async {
    final Map<String, dynamic> summary = <String, dynamic>{
      'platform': platform,
      'appName': appName,
      'appVersion': version,
      'buildNumber': buildNumber,
      'isMobile': isMobile,
      'isDesktop': isDesktop,
      'isWeb': isWeb,
      'isDebug': isDebug,
    };

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        if (info != null) {
          summary.addAll(<String, dynamic>{
            'deviceId': info.id,
            'model': info.model,
            'brand': info.brand,
            'manufacturer': info.manufacturer,
            'systemVersion': info.version.release,
            'sdkVersion': info.version.sdkInt,
          });
        }
      } else if (Platform.isIOS) {
        final IosDeviceInfo? info = await getIosInfo();
        if (info != null) {
          summary.addAll(<String, dynamic>{
            'deviceId': info.identifierForVendor,
            'model': info.model,
            'name': info.name,
            'systemVersion': info.systemVersion,
            'localizedModel': info.localizedModel,
          });
        }
      }
    } catch (e) {
      Logger.error('获取设备信息摘要失败', e);
    }

    return summary;
  }

  // 检查设备是否为平板
  static Future<bool> isTablet() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        // 通过屏幕配置判断是否为平板
        return info?.systemFeatures.contains('android.hardware.type.tablet') ?? false;
      } else if (Platform.isIOS) {
        final IosDeviceInfo? info = await getIosInfo();
        return info?.model.toLowerCase().contains('ipad') ?? false;
      }
      return false;
    } catch (e) {
      Logger.error('判断是否为平板失败', e);
      return false;
    }
  }

  // 获取设备性能等级（简单估算）
  static Future<DevicePerformanceLevel> getPerformanceLevel() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo? info = await getAndroidInfo();
        if (info != null) {
          final int sdkInt = info.version.sdkInt;
          if (sdkInt >= 30) return DevicePerformanceLevel.high;
          if (sdkInt >= 26) return DevicePerformanceLevel.medium;
          return DevicePerformanceLevel.low;
        }
      } else if (Platform.isIOS) {
        final IosDeviceInfo? info = await getIosInfo();
        if (info != null) {
          final double? version = double.tryParse(info.systemVersion.split('.').first);
          if (version != null) {
            if (version >= 14) return DevicePerformanceLevel.high;
            if (version >= 12) return DevicePerformanceLevel.medium;
          }
        }
      }
      return DevicePerformanceLevel.medium;
    } catch (e) {
      Logger.error('获取设备性能等级失败', e);
      return DevicePerformanceLevel.medium;
    }
  }
}

// 设备性能等级枚举
enum DevicePerformanceLevel {
  low('低'),
  medium('中'),
  high('高');

  const DevicePerformanceLevel(this.displayName);
  
  final String displayName;
}