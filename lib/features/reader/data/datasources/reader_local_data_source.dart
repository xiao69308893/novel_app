import 'dart:convert';
import '../../../../core/cache/cache_manager.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/reader_config.dart';
import '../../domain/repositories/reader_repository.dart';

/// 阅读器本地数据源接口
abstract class ReaderLocalDataSource {
  /// 缓存章节内容
  Future<void> cacheChapter(ChapterModel chapter);

  /// 获取缓存的章节内容
  Future<ChapterModel?> getCachedChapter({
    required String novelId,
    required String chapterId,
  });

  /// 缓存章节列表
  Future<void> cacheChapterList({
    required String novelId,
    required List<ChapterSimpleModel> chapters,
  });

  /// 获取缓存的章节列表
  Future<List<ChapterSimpleModel>?> getCachedChapterList({
    required String novelId,
  });

  /// 缓存小说信息
  Future<void> cacheNovelInfo(NovelModel novel);

  /// 获取缓存的小说信息
  Future<NovelModel?> getCachedNovelInfo({required String novelId});

  /// 保存阅读进度
  Future<void> saveReadingProgress(ReadingProgress progress);

  /// 获取阅读进度
  Future<ReadingProgress?> getReadingProgress({required String novelId});

  /// 保存书签
  Future<void> saveBookmark(BookmarkModel bookmark);

  /// 删除书签
  Future<void> deleteBookmark({required String bookmarkId});

  /// 获取书签列表
  Future<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  });

  /// 保存阅读器配置
  Future<void> saveReaderConfig(ReaderConfig config);

  /// 获取阅读器配置
  Future<ReaderConfig?> getReaderConfig();

  /// 保存阅读统计
  Future<void> saveReadingStats(ReadingStats stats);

  /// 获取阅读统计
  Future<ReadingStats?> getReadingStats();

  /// 获取缓存的章节ID列表
  Future<List<String>> getCachedChapterIds({required String novelId});

  /// 清理缓存
  Future<void> clearCache({String? novelId});

  /// 更新阅读时长
  Future<void> updateReadingTime({
    required String novelId,
    required int minutes,
  });
}

/// 阅读器本地数据源实现
class ReaderLocalDataSourceImpl implements ReaderLocalDataSource {
  final CacheManager cacheManager;

  static const String _chapterPrefix = 'chapter_';
  static const String _chapterListPrefix = 'chapter_list_';
  static const String _novelPrefix = 'novel_';
  static const String _progressPrefix = 'progress_';
  static const String _bookmarkPrefix = 'bookmark_';
  static const String _configKey = 'reader_config';
  static const String _statsKey = 'reading_stats';
  static const String _readingTimePrefix = 'reading_time_';

  const ReaderLocalDataSourceImpl({required this.cacheManager});

  @override
  Future<void> cacheChapter(ChapterModel chapter) async {
    try {
      final key = '$_chapterPrefix${chapter.novelId}_${chapter.id}';
      final data = jsonEncode(chapter.toMap());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '缓存章节失败：${e.toString()}');
    }
  }

  @override
  Future<ChapterModel?> getCachedChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final key = '$_chapterPrefix${novelId}_$chapterId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);
        return ChapterModel.fromMap(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存章节失败：${e.toString()}');
    }
  }

  @override
  Future<void> cacheChapterList({
    required String novelId,
    required List<ChapterSimpleModel> chapters,
  }) async {
    try {
      final key = '$_chapterListPrefix$novelId';
      final data = jsonEncode(chapters.map((c) => c.toMap()).toList());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '缓存章节列表失败：${e.toString()}');
    }
  }

  @override
  Future<List<ChapterSimpleModel>?> getCachedChapterList({
    required String novelId,
  }) async {
    try {
      final key = '$_chapterListPrefix$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        return jsonList.map((json) => ChapterSimpleModel.fromMap(json)).toList();
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存章节列表失败：${e.toString()}');
    }
  }

  @override
  Future<void> cacheNovelInfo(NovelModel novel) async {
    try {
      final key = '$_novelPrefix${novel.id}';
      final data = jsonEncode(novel.toMap());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '缓存小说信息失败：${e.toString()}');
    }
  }

  @override
  Future<NovelModel?> getCachedNovelInfo({required String novelId}) async {
    try {
      final key = '$_novelPrefix$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);
        return NovelModel.fromMap(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存小说信息失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final key = '$_progressPrefix${progress.novelId}';
      final data = jsonEncode(progress.toMap());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '保存阅读进度失败：${e.toString()}');
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress({required String novelId}) async {
    try {
      final key = '$_progressPrefix$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);
        return ReadingProgress.fromMap(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取阅读进度失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveBookmark(BookmarkModel bookmark) async {
    try {
      // 先获取现有书签列表
      final bookmarks = await getBookmarks(novelId: bookmark.novelId);
      
      // 添加新书签或更新现有书签
      final updatedBookmarks = [...bookmarks];
      final existingIndex = updatedBookmarks.indexWhere((b) => b.id == bookmark.id);
      
      if (existingIndex != -1) {
        updatedBookmarks[existingIndex] = bookmark;
      } else {
        updatedBookmarks.add(bookmark);
      }
      
      // 保存更新后的书签列表
      final key = '$_bookmarkPrefix${bookmark.novelId}';
      final data = jsonEncode(updatedBookmarks.map((b) => b.toMap()).toList());
      await cacheManager.setString(key, data);
    } catch (e) {
      throw CacheException(message: '保存书签失败：${e.toString()}');
    }
  }

  @override
  Future<void> deleteBookmark({required String bookmarkId}) async {
    try {
      // 需要遍历所有小说的书签来找到要删除的书签
      final allKeys = await cacheManager.getKeys();
      
      for (final key in allKeys) {
        if (key.startsWith(_bookmarkPrefix)) {
          final data = await cacheManager.getString(key);
          if (data != null) {
            final List<dynamic> jsonList = jsonDecode(data);
            final bookmarks = jsonList.map((json) => BookmarkModel.fromMap(json)).toList();
            
            final updatedBookmarks = bookmarks.where((b) => b.id != bookmarkId).toList();
            
            if (updatedBookmarks.length != bookmarks.length) {
              // 找到并删除了书签，保存更新后的列表
              final updatedData = jsonEncode(updatedBookmarks.map((b) => b.toMap()).toList());
              await cacheManager.setString(key, updatedData);
              break;
            }
          }
        }
      }
    } catch (e) {
      throw CacheException(message: '删除书签失败：${e.toString()}');
    }
  }

  @override
  Future<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  }) async {
    try {
      final key = '$_bookmarkPrefix$novelId';
      final data = await cacheManager.getString(key);
      
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        List<BookmarkModel> bookmarks = jsonList.map((json) => BookmarkModel.fromMap(json)).toList();
        
        // 如果指定了章节ID，过滤书签
        if (chapterId != null) {
          bookmarks = bookmarks.where((b) => b.chapterId == chapterId).toList();
        }
        
        return bookmarks;
      }
      return [];
    } catch (e) {
      throw CacheException(message: '获取书签列表失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveReaderConfig(ReaderConfig config) async {
    try {
      final data = jsonEncode(config.toMap());
      await cacheManager.setString(_configKey, data);
    } catch (e) {
      throw CacheException(message: '保存阅读器配置失败：${e.toString()}');
    }
  }

  @override
  Future<ReaderConfig?> getReaderConfig() async {
    try {
      final data = await cacheManager.getString(_configKey);
      
      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);
        return ReaderConfig.fromMap(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取阅读器配置失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveReadingStats(ReadingStats stats) async {
    try {
      final data = jsonEncode(stats.toMap());
      await cacheManager.setString(_statsKey, data);
    } catch (e) {
      throw CacheException(message: '保存阅读统计失败：${e.toString()}');
    }
  }

  @override
  Future<ReadingStats?> getReadingStats() async {
    try {
      final data = await cacheManager.getString(_statsKey);
      
      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data);
        return ReadingStats.fromMap(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取阅读统计失败：${e.toString()}');
    }
  }

  @override
  Future<List<String>> getCachedChapterIds({required String novelId}) async {
    try {
      final allKeys = await cacheManager.getKeys();
      final chapterIds = <String>[];
      
      for (final key in allKeys) {
        if (key.startsWith('$_chapterPrefix$novelId')) {
          final chapterId = key.split('_').last;
          chapterIds.add(chapterId);
        }
      }
      
      return chapterIds;
    } catch (e) {
      throw CacheException(message: '获取缓存章节列表失败：${e.toString()}');
    }
  }

  @override
  Future<void> clearCache({String? novelId}) async {
    try {
      if (novelId != null) {
        // 清理指定小说的缓存
        final allKeys = await cacheManager.getKeys();
        final keysToDelete = allKeys.where((key) => 
          key.contains(novelId) && (
            key.startsWith(_chapterPrefix) ||
            key.startsWith(_chapterListPrefix) ||
            key.startsWith(_novelPrefix) ||
            key.startsWith(_progressPrefix) ||
            key.startsWith(_bookmarkPrefix)
          )
        ).toList();
        
        for (final key in keysToDelete) {
          await cacheManager.remove(key);
        }
      } else {
        // 清理所有阅读器相关缓存
        await cacheManager.clear();
      }
    } catch (e) {
      throw CacheException(message: '清理缓存失败：${e.toString()}');
    }
  }

  @override
  Future<void> updateReadingTime({
    required String novelId,
    required int minutes,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final key = '$_readingTimePrefix${novelId}_$today';
      
      // 获取今日已有的阅读时长
      final existingTime = await cacheManager.getInt(key) ?? 0;
      
      // 更新阅读时长
      await cacheManager.setInt(key, existingTime + minutes);
      
      // 同时更新总体统计
      await _updateTotalReadingStats(novelId, minutes);
    } catch (e) {
      throw CacheException(message: '更新阅读时长失败：${e.toString()}');
    }
  }

  /// 更新总体阅读统计
  Future<void> _updateTotalReadingStats(String novelId, int minutes) async {
    try {
      final stats = await getReadingStats() ?? const ReadingStats();
      
      final updatedStats = ReadingStats(
        totalReadingTime: stats.totalReadingTime + minutes,
        booksRead: stats.booksRead,
        chaptersRead: stats.chaptersRead,
        todayReadingTime: stats.todayReadingTime + minutes,
        weekReadingTime: stats.weekReadingTime + minutes,
        monthReadingTime: stats.monthReadingTime + minutes,
        averageReadingSpeed: stats.averageReadingSpeed,
        readingTimeByDate: {
          ...stats.readingTimeByDate,
          DateTime.now().toIso8601String().split('T')[0]: 
              (stats.readingTimeByDate[DateTime.now().toIso8601String().split('T')[0]] ?? 0) + minutes,
        },
      );
      
      await saveReadingStats(updatedStats);
    } catch (e) {
      // 更新统计失败不应该影响主流程
    }
  }
}