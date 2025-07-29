import 'dart:convert';
import '../../../../core/storage/cache_manager.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../bookself/domain/entities/reading_history.dart';

/// 书架本地数据源接口
abstract class BookshelfLocalDataSource {
  /// 缓存收藏小说列表
  Future<void> cacheFavoriteNovels(List<NovelModel> novels);
  
  /// 获取缓存的收藏小说列表
  Future<List<NovelModel>?> getCachedFavoriteNovels();
  
  /// 缓存收藏状态
  Future<void> cacheFavoriteStatus(String novelId, bool isFavorite);
  
  /// 获取缓存的收藏状态
  Future<bool?> getCachedFavoriteStatus(String novelId);
  
  /// 批量更新收藏状态
  Future<void> batchUpdateFavoriteStatus(Map<String, bool> statusMap);
  
  /// 缓存最近阅读小说列表
  Future<void> cacheRecentlyReadNovels(List<NovelModel> novels);
  
  /// 获取缓存的最近阅读小说列表
  Future<List<NovelModel>?> getCachedRecentlyReadNovels();
  
  /// 缓存推荐小说列表
  Future<void> cacheRecommendedNovels(List<NovelModel> novels);
  
  /// 获取缓存的推荐小说列表
  Future<List<NovelModel>?> getCachedRecommendedNovels();
  
  /// 缓存用户资料
  Future<void> cacheUserProfile(UserModel user);
  
  /// 获取缓存的用户资料
  Future<UserModel?> getCachedUserProfile();
  
  /// 清理指定类型的缓存
  Future<void> clearCache(String cacheType);
  
  /// 清理所有缓存
  Future<void> clearAllCache();
  
  /// 缓存签到状态
  Future<void> cacheCheckinStatus(Map<String, dynamic> status);
  
  /// 获取缓存的签到状态
  Future<bool?> getCachedCheckinStatus();
  
  /// 缓存阅读历史
  Future<void> cacheReadingHistory(List<ReadingHistory> history);
  
  /// 获取缓存的阅读历史
  Future<List<ReadingHistory>?> getCachedReadingHistory();
  
  /// 添加阅读历史记录
  Future<void> addReadingHistoryRecord({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  });
  
  /// 缓存用户统计
  Future<void> cacheUserStats(UserStats stats);
  
  /// 获取缓存的用户统计
  Future<UserStats?> getCachedUserStats();
  
  /// 缓存用户设置
  Future<void> cacheUserSettings(UserSettings settings);
  
  /// 获取缓存的用户设置
  Future<UserSettings?> getCachedUserSettings();
}

/// 书架本地数据源实现
class BookshelfLocalDataSourceImpl implements BookshelfLocalDataSource {
  final CacheManager cacheManager;
  
  static const String _favoritesKey = 'favorite_novels';
  static const String _favoriteStatusPrefix = 'favorite_status_';
  static const String _recentlyReadKey = 'recently_read_novels';
  static const String _recommendedKey = 'recommended_novels';
  static const String _userProfileKey = 'user_profile';
  static const String _checkinStatusKey = 'checkin_status';
  static const String _readingHistoryKey = 'reading_history';
  static const String _userStatsKey = 'user_stats';
  static const String _userSettingsKey = 'user_settings';

  const BookshelfLocalDataSourceImpl({
    required this.cacheManager,
  });

  @override
  Future<void> cacheFavoriteNovels(List<NovelModel> novels) async {
    try {
      final data = json.encode(novels.map((novel) => novel.toJson()).toList());
      await cacheManager.put(_favoritesKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存收藏列表失败: ${e.toString()}');
    }
  }

  @override
  Future<List<NovelModel>?> getCachedFavoriteNovels() async {
    try {
      final data = await cacheManager.get<String>(_favoritesKey, type: CacheType.disk);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList.map((json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheFavoriteStatus(String novelId, bool isFavorite) async {
    try {
      final key = '$_favoriteStatusPrefix$novelId';
      await cacheManager.put(key, isFavorite, type: CacheType.memory);
    } catch (e) {
      throw CacheException(message: '缓存收藏状态失败: ${e.toString()}');
    }
  }

  @override
  Future<bool?> getCachedFavoriteStatus(String novelId) async {
    try {
      final key = '$_favoriteStatusPrefix$novelId';
      return await cacheManager.get<bool>(key, type: CacheType.memory);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> batchUpdateFavoriteStatus(Map<String, bool> statusMap) async {
    try {
      for (final entry in statusMap.entries) {
        await cacheFavoriteStatus(entry.key, entry.value);
      }
    } catch (e) {
      throw CacheException(message: '批量更新收藏状态失败: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheRecentlyReadNovels(List<NovelModel> novels) async {
    try {
      final data = json.encode(novels.map((novel) => novel.toJson()).toList());
      await cacheManager.put(_recentlyReadKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存最近阅读列表失败: ${e.toString()}');
    }
  }

  @override
  Future<List<NovelModel>?> getCachedRecentlyReadNovels() async {
    try {
      final data = await cacheManager.get<String>(_recentlyReadKey, type: CacheType.disk);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList.map((json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheRecommendedNovels(List<NovelModel> novels) async {
    try {
      final data = json.encode(novels.map((novel) => novel.toJson()).toList());
      await cacheManager.put(_recommendedKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存推荐列表失败: ${e.toString()}');
    }
  }

  @override
  Future<List<NovelModel>?> getCachedRecommendedNovels() async {
    try {
      final data = await cacheManager.get<String>(_recommendedKey, type: CacheType.disk);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList.map((json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserProfile(UserModel user) async {
    try {
      final data = json.encode(user.toJson());
      await cacheManager.put(_userProfileKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存用户资料失败: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCachedUserProfile() async {
    try {
      final data = await cacheManager.get<String>(_userProfileKey, type: CacheType.disk);
      if (data != null) {
        final jsonData = json.decode(data) as Map<String, dynamic>;
        return UserModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearCache(String cacheType) async {
    try {
      switch (cacheType) {
        case 'favorites':
          await cacheManager.remove(_favoritesKey, type: CacheType.disk);
          break;
        case 'recently_read':
          await cacheManager.remove(_recentlyReadKey, type: CacheType.disk);
          break;
        case 'recommended':
          await cacheManager.remove(_recommendedKey, type: CacheType.disk);
          break;
        case 'user_profile':
          await cacheManager.remove(_userProfileKey, type: CacheType.disk);
          break;
        case 'checkin':
          await cacheManager.remove(_checkinStatusKey, type: CacheType.disk);
          break;
        case 'history':
          await cacheManager.remove(_readingHistoryKey, type: CacheType.disk);
          break;
        case 'stats':
          await cacheManager.remove(_userStatsKey, type: CacheType.disk);
          break;
        case 'settings':
          await cacheManager.remove(_userSettingsKey, type: CacheType.disk);
          break;
      }
    } catch (e) {
      throw CacheException(message: '清理缓存失败: ${e.toString()}');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await cacheManager.remove(_favoritesKey, type: CacheType.disk);
      await cacheManager.remove(_recentlyReadKey, type: CacheType.disk);
      await cacheManager.remove(_recommendedKey, type: CacheType.disk);
      await cacheManager.remove(_userProfileKey, type: CacheType.disk);
      await cacheManager.remove(_checkinStatusKey, type: CacheType.disk);
      await cacheManager.remove(_readingHistoryKey, type: CacheType.disk);
      await cacheManager.remove(_userStatsKey, type: CacheType.disk);
      await cacheManager.remove(_userSettingsKey, type: CacheType.disk);
      
      // 清理所有收藏状态缓存 - 这需要特殊处理，因为我们无法直接获取所有键
      // 暂时跳过这个功能，或者需要实现一个获取所有键的方法
    } catch (e) {
      throw CacheException(message: '清理所有缓存失败: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheCheckinStatus(Map<String, dynamic> status) async {
    try {
      final data = json.encode(status);
      await cacheManager.put(_checkinStatusKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存签到状态失败: ${e.toString()}');
    }
  }

  @override
  Future<bool?> getCachedCheckinStatus() async {
    try {
      final data = await cacheManager.get<String>(_checkinStatusKey, type: CacheType.disk);
      if (data != null) {
        final jsonData = json.decode(data) as Map<String, dynamic>;
        return jsonData['checked_in'] as bool?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheReadingHistory(List<ReadingHistory> history) async {
    try {
      final data = json.encode(history.map((h) => h.toJson()).toList());
      await cacheManager.put(_readingHistoryKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存阅读历史失败: ${e.toString()}');
    }
  }

  @override
  Future<List<ReadingHistory>?> getCachedReadingHistory() async {
    try {
      final data = await cacheManager.get<String>(_readingHistoryKey, type: CacheType.disk);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
        return jsonList.map((json) => ReadingHistory.fromJson(json as Map<String, dynamic>)).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addReadingHistoryRecord({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  }) async {
    try {
      // 获取现有历史记录
      final existingHistory = await getCachedReadingHistory() ?? [];
      
      // 创建简单的小说模型（只包含基本信息）
      final novel = NovelSimpleModel(
        id: novelId,
        title: '', // 这里需要从其他地方获取小说标题
        authorName: '',
        coverUrl: '',
        categoryName: '',
        status: NovelStatus.serializing,
        wordCount: 0,
        chapterCount: 0,
        lastUpdateTime: DateTime.now(),
        isFinished: false,
        isVip: false,
        isHot: false,
      );
      
      // 创建新的历史记录
      final newRecord = ReadingHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: '', // 这里需要从用户会话中获取用户ID
        novel: novel,
        readingTime: readingTime,
        lastReadAt: DateTime.now(),
      );
      
      // 检查是否已存在相同小说的记录，如果存在则更新
      final existingIndex = existingHistory.indexWhere((h) => h.novel.id == novelId);
      if (existingIndex != -1) {
        existingHistory[existingIndex] = newRecord;
      } else {
        existingHistory.insert(0, newRecord);
      }
      
      // 限制历史记录数量（保留最近100条）
      if (existingHistory.length > 100) {
        existingHistory.removeRange(100, existingHistory.length);
      }
      
      // 保存更新后的历史记录
      await cacheReadingHistory(existingHistory);
    } catch (e) {
      throw CacheException(message: '添加阅读历史记录失败: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUserStats(UserStats stats) async {
    try {
      final data = json.encode(stats.toJson());
      await cacheManager.put(_userStatsKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存用户统计失败: ${e.toString()}');
    }
  }

  @override
  Future<UserStats?> getCachedUserStats() async {
    try {
      final data = await cacheManager.get<String>(_userStatsKey, type: CacheType.disk);
      if (data != null) {
        final jsonData = json.decode(data) as Map<String, dynamic>;
        return UserStats.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheUserSettings(UserSettings settings) async {
    try {
      final data = json.encode(settings.toJson());
      await cacheManager.put(_userSettingsKey, data, type: CacheType.disk);
    } catch (e) {
      throw CacheException(message: '缓存用户设置失败: ${e.toString()}');
    }
  }

  @override
  Future<UserSettings?> getCachedUserSettings() async {
    try {
      final data = await cacheManager.get<String>(_userSettingsKey, type: CacheType.disk);
      if (data != null) {
        final jsonData = json.decode(data) as Map<String, dynamic>;
        return UserSettings.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}