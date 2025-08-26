import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'logger.dart';

class PreferencesHelper {
  // 私有构造函数
  PreferencesHelper._internal();
  
  static SharedPreferences? _prefs;
  
  // 初始化
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      Logger.info('本地存储初始化成功');
    } catch (e) {
      Logger.error('本地存储初始化失败', e);
      rethrow;
    }
  }
  
  // 确保已初始化
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesHelper未初始化，请先调用init()方法');
    }
    return _prefs!;
  }
  
  // ==================== 基础数据类型操作 ====================
  
  // 存储字符串
  static Future<bool> setString(String key, String value) async {
    try {
      final bool result = await prefs.setString(key, value);
      Logger.debug('STORAGE', '存储字符串: $key = $value');
      return result;
    } catch (e) {
      Logger.error('存储字符串失败: $key', e);
      return false;
    }
  }
  
  // 获取字符串
  static String? getString(String key, [String? defaultValue]) {
    try {
      final String? value = prefs.getString(key) ?? defaultValue;
      Logger.debug('STORAGE', '获取字符串: $key = $value');
      return value;
    } catch (e) {
      Logger.error('获取字符串失败: $key', e);
      return defaultValue;
    }
  }
  
  // 存储整数
  static Future<bool> setInt(String key, int value) async {
    try {
      final bool result = await prefs.setInt(key, value);
      Logger.debug('STORAGE', '存储整数: $key = $value');
      return result;
    } catch (e) {
      Logger.error('存储整数失败: $key', e);
      return false;
    }
  }
  
  // 获取整数
  static int getInt(String key, [int defaultValue = 0]) {
    try {
      final int value = prefs.getInt(key) ?? defaultValue;
      Logger.debug('STORAGE', '获取整数: $key = $value');
      return value;
    } catch (e) {
      Logger.error('获取整数失败: $key', e);
      return defaultValue;
    }
  }
  
  // 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    try {
      final bool result = await prefs.setBool(key, value);
      Logger.debug('STORAGE', '存储布尔值: $key = $value');
      return result;
    } catch (e) {
      Logger.error('存储布尔值失败: $key', e);
      return false;
    }
  }
  
  // 获取布尔值
  static bool getBool(String key, [bool defaultValue = false]) {
    try {
      final bool value = prefs.getBool(key) ?? defaultValue;
      Logger.debug('STORAGE', '获取布尔值: $key = $value');
      return value;
    } catch (e) {
      Logger.error('获取布尔值失败: $key', e);
      return defaultValue;
    }
  }
  
  // 存储双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    try {
      final bool result = await prefs.setDouble(key, value);
      Logger.debug('STORAGE', '存储浮点数: $key = $value');
      return result;
    } catch (e) {
      Logger.error('存储浮点数失败: $key', e);
      return false;
    }
  }
  
  // 获取双精度浮点数
  static double getDouble(String key, [double defaultValue = 0.0]) {
    try {
      final double value = prefs.getDouble(key) ?? defaultValue;
      Logger.debug('STORAGE', '获取浮点数: $key = $value');
      return value;
    } catch (e) {
      Logger.error('获取浮点数失败: $key', e);
      return defaultValue;
    }
  }
  
  // 存储字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    try {
      final bool result = await prefs.setStringList(key, value);
      Logger.debug('STORAGE', '存储字符串列表: $key = $value');
      return result;
    } catch (e) {
      Logger.error('存储字符串列表失败: $key', e);
      return false;
    }
  }
  
  // 获取字符串列表
  static List<String> getStringList(String key, [List<String>? defaultValue]) {
    try {
      final List<String> value = prefs.getStringList(key) ?? defaultValue ?? <String>[];
      Logger.debug('STORAGE', '获取字符串列表: $key = $value');
      return value;
    } catch (e) {
      Logger.error('获取字符串列表失败: $key', e);
      return defaultValue ?? <String>[];
    }
  }
  
  // ==================== 复杂数据类型操作 ====================
  
  // 存储JSON对象
  static Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final String jsonString = json.encode(value);
      final bool result = await setString(key, jsonString);
      Logger.debug('STORAGE', '存储JSON对象: $key');
      return result;
    } catch (e) {
      Logger.error('存储JSON对象失败: $key', e);
      return false;
    }
  }
  
  // 获取JSON对象
  static Map<String, dynamic>? getObject(String key) {
    try {
      final String? jsonString = getString(key);
      if (jsonString != null) {
        final Map<String, dynamic> value = json.decode(jsonString) as Map<String, dynamic>;
        Logger.debug('STORAGE', '获取JSON对象: $key');
        return value;
      }
      return null;
    } catch (e) {
      Logger.error('获取JSON对象失败: $key', e);
      return null;
    }
  }
  
  // 存储JSON数组
  static Future<bool> setArray(String key, List<Map<String, dynamic>> value) async {
    try {
      final String jsonString = json.encode(value);
      final bool result = await setString(key, jsonString);
      Logger.debug('STORAGE', '存储JSON数组: $key');
      return result;
    } catch (e) {
      Logger.error('存储JSON数组失败: $key', e);
      return false;
    }
  }
  
  // 获取JSON数组
  static List<Map<String, dynamic>> getArray(String key) {
    try {
      final String? jsonString = getString(key);
      if (jsonString != null) {
        final List<Map<String, dynamic>> value = (json.decode(jsonString) as List)
            .cast<Map<String, dynamic>>();
        Logger.debug('STORAGE', '获取JSON数组: $key');
        return value;
      }
      return <Map<String, dynamic>>[];
    } catch (e) {
      Logger.error('获取JSON数组失败: $key', e);
      return <Map<String, dynamic>>[];
    }
  }
  
  // ==================== 高级操作 ====================
  
  // 删除键值
  static Future<bool> remove(String key) async {
    try {
      final bool result = await prefs.remove(key);
      Logger.debug('STORAGE', '删除键值: $key');
      return result;
    } catch (e) {
      Logger.error('删除键值失败: $key', e);
      return false;
    }
  }
  
  // 清空所有数据
  static Future<bool> clear() async {
    try {
      final bool result = await prefs.clear();
      Logger.warning('清空所有本地存储数据');
      return result;
    } catch (e) {
      Logger.error('清空数据失败', e);
      return false;
    }
  }
  
  // 检查键是否存在
  static bool containsKey(String key) {
    try {
      final bool exists = prefs.containsKey(key);
      Logger.debug('STORAGE', '检查键存在性: $key = $exists');
      return exists;
    } catch (e) {
      Logger.error('检查键存在性失败: $key', e);
      return false;
    }
  }
  
  // 获取所有键
  static Set<String> getKeys() {
    try {
      final Set<String> keys = prefs.getKeys();
      Logger.debug('STORAGE', '获取所有键: ${keys.length}个');
      return keys;
    } catch (e) {
      Logger.error('获取所有键失败', e);
      return <String>{};
    }
  }
  
  // 获取存储大小（近似值）
  static int getStorageSize() {
    try {
      int totalSize = 0;
      final Set<String> keys = getKeys();
      
      for (final String key in keys) {
        final Object? value = prefs.get(key);
        if (value != null) {
          totalSize += key.length;
          totalSize += value.toString().length;
        }
      }
      
      Logger.debug('STORAGE', '存储大小: $totalSize字节');
      return totalSize;
    } catch (e) {
      Logger.error('计算存储大小失败', e);
      return 0;
    }
  }
  
  // 批量操作
  static Future<bool> batchSet(Map<String, dynamic> data) async {
    try {
      bool allSuccess = true;
      
      for (final MapEntry<String, dynamic> entry in data.entries) {
        final String key = entry.key;
        final value = entry.value;
        
        bool success = false;
        if (value is String) {
          success = await setString(key, value);
        } else if (value is int) {
          success = await setInt(key, value);
        } else if (value is bool) {
          success = await setBool(key, value);
        } else if (value is double) {
          success = await setDouble(key, value);
        } else if (value is List<String>) {
          success = await setStringList(key, value);
        } else if (value is Map<String, dynamic>) {
          success = await setObject(key, value);
        } else {
          success = await setString(key, value.toString());
        }
        
        if (!success) {
          allSuccess = false;
        }
      }
      
      Logger.debug('STORAGE', '批量设置: ${data.length}个项目, 成功: $allSuccess');
      return allSuccess;
    } catch (e) {
      Logger.error('批量设置失败', e);
      return false;
    }
  }
  
  // 批量删除
  static Future<bool> batchRemove(List<String> keys) async {
    try {
      bool allSuccess = true;
      
      for (final String key in keys) {
        final bool success = await remove(key);
        if (!success) {
          allSuccess = false;
        }
      }
      
      Logger.debug('STORAGE', '批量删除: ${keys.length}个键, 成功: $allSuccess');
      return allSuccess;
    } catch (e) {
      Logger.error('批量删除失败', e);
      return false;
    }
  }
  
  // 导出数据
  static Map<String, dynamic> exportData() {
    try {
      final Map<String, dynamic> data = <String, dynamic>{};
      final Set<String> keys = getKeys();
      
      for (final String key in keys) {
        final Object? value = prefs.get(key);
        if (value != null) {
          data[key] = value;
        }
      }
      
      Logger.info('导出数据: ${data.length}个项目');
      return data;
    } catch (e) {
      Logger.error('导出数据失败', e);
      return <String, dynamic>{};
    }
  }
}

// 存储键常量
class PreferenceKeys {
  // 禁止实例化
  PreferenceKeys._();
  
  // ==================== 用户相关 ====================
  static const String userToken = 'user_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userInfo = 'user_info';
  static const String userPreferences = 'user_preferences';
  static const String isFirstLaunch = 'is_first_launch';
  static const String lastLoginTime = 'last_login_time';
  
  // ==================== 应用设置 ====================
  static const String themeMode = 'theme_mode';
  static const String locale = 'locale';
  static const String isNotificationEnabled = 'is_notification_enabled';
  static const String isSoundEnabled = 'is_sound_enabled';
  static const String isVibrationEnabled = 'is_vibration_enabled';
  static const String autoUpdateEnabled = 'auto_update_enabled';
  
  // ==================== 阅读器设置 ====================
  static const String readerTheme = 'reader_theme';
  static const String fontSize = 'font_size';
  static const String lineSpacing = 'line_spacing';
  static const String pageMargin = 'page_margin';
  static const String turnPageMode = 'turn_page_mode';
  static const String brightnessValue = 'brightness_value';
  static const String keepScreenOn = 'keep_screen_on';
  static const String showStatusBar = 'show_status_bar';
  static const String fullScreen = 'full_screen';
  static const String volumeKeyTurnPage = 'volume_key_turn_page';
  
  // ==================== 书架相关 ====================
  static const String bookshelfBooks = 'bookshelf_books';
  static const String bookshelfSortType = 'bookshelf_sort_type';
  static const String bookshelfViewType = 'bookshelf_view_type';
  static const String readingHistory = 'reading_history';
  static const String recentBooks = 'recent_books';
  static const String favoriteBooks = 'favorite_books';
  
  // ==================== 阅读进度 ====================
  static const String readingProgress = 'reading_progress_';
  static const String bookmarks = 'bookmarks_';
  static const String readingStats = 'reading_stats';
  static const String lastReadBook = 'last_read_book';
  static const String lastReadChapter = 'last_read_chapter';
  
  // ==================== 缓存设置 ====================
  static const String cacheSize = 'cache_size';
  static const String maxCacheSize = 'max_cache_size';
  static const String autoCacheChapters = 'auto_cache_chapters';
  static const String cacheOnWifiOnly = 'cache_on_wifi_only';
  static const String clearCacheOnExit = 'clear_cache_on_exit';
  
  // ==================== 搜索历史 ====================
  static const String searchHistory = 'search_history';
  static const String maxSearchHistory = 'max_search_history';
  static const String clearSearchHistoryOnExit = 'clear_search_history_on_exit';
  
  // ==================== 推送设置 ====================
  static const String pushToken = 'push_token';
  static const String pushSettings = 'push_settings';
  static const String lastPushTime = 'last_push_time';
  
  // ==================== 统计数据 ====================
  static const String appLaunchCount = 'app_launch_count';
  static const String totalReadingTime = 'total_reading_time';
  static const String totalWordsRead = 'total_words_read';
  static const String totalBooksRead = 'total_books_read';
  
  // 构建带前缀的键
  static String withPrefix(String prefix, String key) => '${prefix}_$key';
  
  // 构建用户相关的键
  static String userKey(String userId, String key) => 'user_${userId}_$key';
  
  // 构建书籍相关的键
  static String bookKey(String bookId, String key) => 'book_${bookId}_$key';
}