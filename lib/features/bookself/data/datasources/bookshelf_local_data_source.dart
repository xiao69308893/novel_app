import 'dart:convert';
import 'dart:io';
import '../../../core/cache/cache_manager.dart';
import '../../../core/error/exceptions.dart';
import '../../../shared/models/chapter_model.dart';
import '../../domain/entities/reader_config.dart';
import 'reader_remote_data_source.dart';

/// 阅读器本地数据源接口
abstract class ReaderLocalDataSource {
  /// 缓存章节内容
  Future<void> cacheChapter({
    required String novelId,
    required ChapterModel chapter,
  });

  /// 获取缓存的章节内容
  Future<ChapterModel?> getCachedChapter({
    required String novelId,
    required String chapterId,
  });

  /// 检查章节是否已缓存
  Future<bool> isChapterCached({
    required String novelId,
    required String chapterId,
  });

  /// 删除章节缓存
  Future<void> deleteCachedChapter({
    required String novelId,
    required String chapterId,
  });

  /// 获取已缓存的章节列表
  Future<List<String>> getCachedChapterIds({
    required String novelId,
  });

  /// 清理小说的所有缓存
  Future<void> clearNovelCache({
    required String novelId,
  });

  /// 保存阅读进度到本地
  Future<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  });

  /// 获取本地阅读进度
  Future<ReadingProgressModel?> getLocalReadingProgress({
    required String novelId,
  });

  /// 删除阅读进度
  Future<void> deleteReadingProgress({
    required String novelId,
  });

  /// 保存书签到本地
  Future<void> saveBookmark({
    required BookmarkModel bookmark,
  });

  /// 删除本地书签
  Future<void> deleteLocalBookmark({
    required String bookmarkId,
  });

  /// 获取本地书签列表
  Future<List<BookmarkModel>> getLocalBookmarks({
    required String novelId,
    String? chapterId,
  });

  /// 清理所有书签
  Future<void> clearBookmarks({
    required String novelId,
  });

  /// 保存阅读器配置
  Future<void> saveReaderConfig({
    required ReaderConfig config,
  });

  /// 获取阅读器配置
  Future<ReaderConfig?> getReaderConfig();

  /// 保存章节列表缓存
  Future<void> cacheChapterList({
    required String novelId,
    required List<ChapterSimpleModel> chapters,
  });

  /// 获取缓存的章节列表
  Future<List<ChapterSimpleModel>?> getCachedChapterList({
    required String novelId,
  });

  /// 获取缓存大小
  Future<int> getCacheSize();

  /// 清理所有缓存
  Future<void> clearAllCache();

  /// 获取缓存统计信息
  Future<CacheStatsModel> getCacheStats();
}

/// 阅读器本地数据源实现
class ReaderLocalDataSourceImpl implements ReaderLocalDataSource {
  final CacheManager cacheManager;
  
  static const String _chapterCachePrefix = 'chapter_';
  static const String _progressCacheKey = 'reading_progress_';
  static const String _bookmarkCacheKey = 'bookmarks_';
  static const String _configCacheKey = 'reader_config';
  static const String _chapterListCacheKey = 'chapter_list_';

  const ReaderLocalDataSourceImpl({
    required this.cacheManager,
  });

  @override
  Future<void> cacheChapter({
    required String novelId,
    required ChapterModel chapter,
  }) async {
    try {
      final key = _getChapterCacheKey(novelId, chapter.id);
      final data = json.encode(chapter.toJson());
      
      await cacheManager.setString(key, data);
      
      // 更新章节缓存索引
      await _updateChapterCacheIndex(novelId, chapter.id, add: true);
    } catch (e) {
      throw CacheException(message: '缓存章节失败: ${e.toString()}');
    }
  }

  @override
  Future<ChapterModel?> getCachedChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final key = _getChapterCacheKey(novelId, chapterId);
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final json = jsonDecode(data);
        return ChapterModel.fromJson(json);
      }
      
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存章节失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> isChapterCached({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final key = _getChapterCacheKey(novelId, chapterId);
      return await cacheManager.containsKey(key);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> deleteCachedChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final key = _getChapterCacheKey(novelId, chapterId);
      await cacheManager.remove(key);
      
      // 更新章节缓存索引
      await _updateChapterCacheIndex(novelId, chapterId, add: false);
    } catch (e) {
      throw CacheException(message: '删除缓存章节失败: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCachedChapterIds({
    required String novelId,
  }) async {
    try {
      final indexKey = '${_chapterCachePrefix}index_$novelId';
      final data = await cacheManager.getString(indexKey);
      
      if (data != null) {
        final List<dynamic> ids = json.decode(data);
        return ids.cast<String>();
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearNovelCache({
    required String novelId,
  }) async {
    try {
      // 删除所有相关的章节缓存
      final cachedIds = await getCachedChapterIds(novelId: novelId);
      for (final chapterId in cachedIds) {
        await deleteCachedChapter(novelId: novelId, chapterId: chapterId);
      }
      
      // 删除章节列表缓存
      final chapterListKey = '$_chapterListCacheKey$novelId';
      await cacheManager.remove(chapterListKey);
      
      // 删除阅读进度
      await deleteReadingProgress(novelId: novelId);
      
      // 删除书签
      await clearBookmarks(novelId: novelId);
      
      // 删除索引
      final indexKey = '${_chapterCachePrefix}index_$novelId';
      await cacheManager.remove(indexKey);
    } catch (e) {
      throw CacheException(message: '清理小说缓存失败: ${e.toString()}');
    }
  }

  @override
  Future<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  }) async {
    try {
      final key = '$_progressCacheKey$novelId';
      final progressData = ReadingProgressModel(
        id: novelId,
        userId: 'local',
        novelId: novelId,
        chapterId: chapterId,
        position: position,
        progress: progress,
        updatedAt: DateTime.now(),
      );
      
      final data = json.encode(progressData.toJson());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '保存阅读进度失败: ${e.toString()}');
    }
  }

  @override
  Future<ReadingProgressModel?> getLocalReadingProgress({
    required String novelId,
  }) async {
    try {
      final key = '$_progressCacheKey$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final json = jsonDecode(data);
        return ReadingProgressModel.fromJson(json);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteReadingProgress({
    required String novelId,
  }) async {
    try {
      final key = '$_progressCacheKey$novelId';
      await cacheManager.remove(key);
    } catch (e) {
      throw CacheException(message: '删除阅读进度失败: ${e.toString()}');
    }
  }

  @override
  Future<void> saveBookmark({
    required BookmarkModel bookmark,
  }) async {
    try {
      final key = '$_bookmarkCacheKey${bookmark.novelId}';
      
      // 获取现有书签列表
      final existingBookmarks = await getLocalBookmarks(
        novelId: bookmark.novelId,
      );
      
      // 检查是否已存在相同的书签
      final existingIndex = existingBookmarks.indexWhere(
        (b) => b.id == bookmark.id,
      );
      
      if (existingIndex != -1) {
        // 更新现有书签
        existingBookmarks[existingIndex] = bookmark;
      } else {
        // 添加新书签
        existingBookmarks.add(bookmark);
      }
      
      // 按创建时间排序
      existingBookmarks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      final data = json.encode(
        existingBookmarks.map((b) => b.toJson()).toList(),
      );
      
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '保存书签失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteLocalBookmark({
    required String bookmarkId,
  }) async {
    try {
      // 需要找到包含该书签的小说ID
      // 这里简化处理，实际应该优化存储结构
      final allKeys = await cacheManager.getKeys();
      
      for (final key in allKeys) {
        if (key.startsWith(_bookmarkCacheKey)) {
          final data = await cacheManager.getString(key);
          if (data != null) {
            final List<dynamic> bookmarksJson = json.decode(data);
            final bookmarks = bookmarksJson
                .map((json) => BookmarkModel.fromJson(json))
                .toList();
            
            final updatedBookmarks = bookmarks
                .where((b) => b.id != bookmarkId)
                .toList();
            
            if (updatedBookmarks.length != bookmarks.length) {
              // 找到了要删除的书签
              final updatedData = json.encode(
                updatedBookmarks.map((b) => b.toJson()).toList(),
              );
              await cacheManager.setString(key, updatedData);
              break;
            }
          }
        }
      }
    } catch (e) {
      throw CacheException(message: '删除书签失败: ${e.toString()}');
    }
  }

  @override
  Future<List<BookmarkModel>> getLocalBookmarks({
    required String novelId,
    String? chapterId,
  }) async {
    try {
      final key = '$_bookmarkCacheKey$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final List<dynamic> bookmarksJson = json.decode(data);
        final bookmarks = bookmarksJson
            .map((json) => BookmarkModel.fromJson(json))
            .toList();
        
        if (chapterId != null) {
          return bookmarks
              .where((b) => b.chapterId == chapterId)
              .toList();
        }
        
        return bookmarks;
      }
      
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> clearBookmarks({
    required String novelId,
  }) async {
    try {
      final key = '$_bookmarkCacheKey$novelId';
      await cacheManager.remove(key);
    } catch (e) {
      throw CacheException(message: '清理书签失败: ${e.toString()}');
    }
  }

  @override
  Future<void> saveReaderConfig({
    required ReaderConfig config,
  }) async {
    try {
      final data = json.encode(config.toJson());
      await cacheManager.setString(_configCacheKey, data);
    } catch (e) {
      throw CacheException(message: '保存阅读器配置失败: ${e.toString()}');
    }
  }

  @override
  Future<ReaderConfig?> getReaderConfig() async {
    try {
      final data = await cacheManager.getString(_configCacheKey);
      
      if (data != null) {
        final json = jsonDecode(data);
        return ReaderConfig.fromJson(json);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheChapterList({
    required String novelId,
    required List<ChapterSimpleModel> chapters,
  }) async {
    try {
      final key = '$_chapterListCacheKey$novelId';
      final data = json.encode(
        chapters.map((c) => c.toJson()).toList(),
      );
      
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '缓存章节列表失败: ${e.toString()}');
    }
  }

  @override
  Future<List<ChapterSimpleModel>?> getCachedChapterList({
    required String novelId,
  }) async {
    try {
      final key = '$_chapterListCacheKey$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final List<dynamic> chaptersJson = json.decode(data);
        return chaptersJson
            .map((json) => ChapterSimpleModel.fromJson(json))
            .toList();
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      return await cacheManager.getCacheSize();
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      await cacheManager.clear();
    } catch (e) {
      throw CacheException(message: '清理所有缓存失败: ${e.toString()}');
    }
  }

  @override
  Future<CacheStatsModel> getCacheStats() async {
    try {
      final allKeys = await cacheManager.getKeys();
      
      int chapterCount = 0;
      int bookmarkCount = 0;
      int progressCount = 0;
      final Set<String> novelIds = {};
      
      for (final key in allKeys) {
        if (key.startsWith(_chapterCachePrefix) && !key.contains('index')) {
          chapterCount++;
          // 从key中提取novelId: chapter_novelId_chapterId
          final parts = key.split('_');
          if (parts.length >= 3) {
            novelIds.add(parts[1]);
          }
        } else if (key.startsWith(_bookmarkCacheKey)) {
          final data = await cacheManager.getString(key);
          if (data != null) {
            final List<dynamic> bookmarks = json.decode(data);
            bookmarkCount += bookmarks.length;
          }
        } else if (key.startsWith(_progressCacheKey)) {
          progressCount++;
        }
      }
      
      final cacheSize = await getCacheSize();
      
      return CacheStatsModel(
        totalSize: cacheSize,
        chapterCount: chapterCount,
        bookmarkCount: bookmarkCount,
        progressCount: progressCount,
        novelCount: novelIds.length,
      );
    } catch (e) {
      return const CacheStatsModel(
        totalSize: 0,
        chapterCount: 0,
        bookmarkCount: 0,
        progressCount: 0,
        novelCount: 0,
      );
    }
  }

  /// 生成章节缓存键
  String _getChapterCacheKey(String novelId, String chapterId) {
    return '${_chapterCachePrefix}${novelId}_$chapterId';
  }

  /// 更新章节缓存索引
  Future<void> _updateChapterCacheIndex(
    String novelId,
    String chapterId, {
    required bool add,
  }) async {
    try {
      final indexKey = '${_chapterCachePrefix}index_$novelId';
      final cachedIds = await getCachedChapterIds(novelId: novelId);
      
      if (add && !cachedIds.contains(chapterId)) {
        cachedIds.add(chapterId);
      } else if (!add) {
        cachedIds.remove(chapterId);
      }
      
      final data = json.encode(cachedIds);
      await cacheManager.setString(indexKey, data);
    } catch (e) {
      // 索引更新失败不影响主要功能
    }
  }
}

/// 缓存统计模型
class CacheStatsModel {
  final int totalSize; // 字节
  final int chapterCount;
  final int bookmarkCount;
  final int progressCount;
  final int novelCount;

  const CacheStatsModel({
    required this.totalSize,
    required this.chapterCount,
    required this.bookmarkCount,
    required this.progressCount,
    required this.novelCount,
  });

  /// 格式化大小显示
  String get formattedSize {
    if (totalSize < 1024) {
      return '${totalSize}B';
    } else if (totalSize < 1024 * 1024) {
      return '${(totalSize / 1024).toStringAsFixed(1)}KB';
    } else if (totalSize < 1024 * 1024 * 1024) {
      return '${(totalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(totalSize / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'chapterCount': chapterCount,
      'bookmarkCount': bookmarkCount,
      'progressCount': progressCount,
      'novelCount': novelCount,
    };
  }
}