import 'dart:convert';
import 'package:novel_app/core/errors/exceptions.dart';

import '../../../../core/cache/cache_manager.dart';
import '../../../../shared/models/chapter_model.dart' hide ReadingProgress;
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/reader_config.dart';
import '../../domain/repositories/reader_repository.dart' ;

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

  const ReaderLocalDataSourceImpl({required this.cacheManager});
  final CacheManager cacheManager;

  static const String _chapterPrefix = 'chapter_';
  static const String _chapterListPrefix = 'chapter_list_';
  static const String _novelPrefix = 'novel_';
  static const String _progressPrefix = 'progress_';
  static const String _bookmarkPrefix = 'bookmark_';
  static const String _configKey = 'reader_config';
  static const String _statsKey = 'reading_stats';
  static const String _readingTimePrefix = 'reading_time_';

  @override
  Future<void> cacheChapter(ChapterModel chapter) async {
    try {
      final String key = '$_chapterPrefix${chapter.novelId}_${chapter.id}';
      final String data = jsonEncode(chapter.toJson());
      await cacheManager.put(key, data);
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
      final String key = '$_chapterPrefix${novelId}_$chapterId';
      final String? data = await cacheManager.get<String>(key);

      if (data != null) {
        final Map<String, dynamic> json =
            jsonDecode(data.toString()) as Map<String, dynamic>;

        return ChapterModel.fromJson(json);
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
      final String key = '$_chapterListPrefix$novelId';
      final String data = jsonEncode(chapters.map((ChapterSimpleModel c) => c.toJson()).toList());
      await cacheManager.put(key, data);
    } catch (e) {
      throw CacheException(message: '缓存章节列表失败：${e.toString()}');
    }
  }

  @override
  Future<List<ChapterSimpleModel>?> getCachedChapterList({
    required String novelId,
  }) async {
    try {
      final String key = '$_chapterListPrefix$novelId';
      final String? data = await cacheManager.get<String>(key);

      if (data != null) {
        final List<dynamic> jsonList =
            (jsonDecode(data.toString()) as List).cast<dynamic>();
        return jsonList
            .map((json) =>
                ChapterSimpleModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存章节列表失败：${e.toString()}');
    }
  }

  @override
  Future<void> cacheNovelInfo(NovelModel novel) async {
    try {
      final String key = '$_novelPrefix${novel.id}';
      final String data = jsonEncode(novel.toJson());
      await cacheManager.put(key, data);
    } catch (e) {
      throw CacheException(message: '缓存小说信息失败：${e.toString()}');
    }
  }

  @override
  Future<NovelModel?> getCachedNovelInfo({required String novelId}) async {
    try {
      final String key = '$_novelPrefix$novelId';
      final String? data = await cacheManager.get<String>(key);

      if (data != null) {
        final Map<String, dynamic> json =
            jsonDecode(data.toString()) as Map<String, dynamic>;
        return NovelModel.fromJson(json);
      }
      return null;
    } catch (e) {
      throw CacheException(message: '获取缓存小说信息失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    try {
      final String key = '$_progressPrefix${progress.novelId}';
      final String data = jsonEncode(progress);
      await cacheManager.put(key, data);
    } catch (e) {
      throw CacheException(message: '保存阅读进度失败：${e.toString()}');
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress({required String novelId}) async {
    try {
      final String key = '$_progressPrefix$novelId';
      final String? data = await cacheManager.get<String>(key);

      if (data != null) {
        final Map<String, dynamic> json =
            jsonDecode(data) as Map<String, dynamic>;
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
      final List<BookmarkModel> bookmarks = await getBookmarks(novelId: bookmark.novelId);

      // 添加新书签或更新现有书签
      final List<BookmarkModel> updatedBookmarks = <BookmarkModel>[...bookmarks];
      final int existingIndex =
          updatedBookmarks.indexWhere((BookmarkModel b) => b.id == bookmark.id);

      if (existingIndex != -1) {
        updatedBookmarks[existingIndex] = bookmark;
      } else {
        updatedBookmarks.add(bookmark);
      }

      // 保存更新后的书签列表
      final String key = '$_bookmarkPrefix${bookmark.novelId}';
      final String data = jsonEncode(updatedBookmarks.map((BookmarkModel b) => b.toJson()).toList());
      await cacheManager.put(key, data);
    } catch (e) {
      throw CacheException(message: '保存书签失败：${e.toString()}');
    }
  }

  @override
  Future<void> deleteBookmark({required String bookmarkId}) async {
    try {
      // 需要遍历所有小说的书签来找到要删除的书签
      final List<String> allKeys = await cacheManager.getAllKeys();

      for (final String key in allKeys) {
        if (key.startsWith(_bookmarkPrefix)) {
          final String? data = await cacheManager.get<String>(key);
          if (data != null) {
            final List<dynamic> jsonList =
                jsonDecode(data) as List<dynamic>;
            final List<BookmarkModel> bookmarks =
                jsonList.map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>)).toList();

            final List<BookmarkModel> updatedBookmarks =
                bookmarks.where((BookmarkModel b) => b.id != bookmarkId).toList();

            if (updatedBookmarks.length != bookmarks.length) {
              // 找到并删除了书签，保存更新后的列表
              final String updatedData =
                  jsonEncode(updatedBookmarks.map((BookmarkModel b) => b.toJson()).toList());

              await cacheManager.put(key, updatedData);
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
      final String key = '$_bookmarkPrefix$novelId';
      final String? data = await cacheManager.get<String>(key);

      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data) as List<dynamic>;
        List<BookmarkModel> bookmarks =
            jsonList.map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>)).toList();

        // 如果指定了章节ID，过滤书签
        if (chapterId != null) {
          bookmarks = bookmarks.where((BookmarkModel b) => b.chapterId == chapterId).toList();
        }

        return bookmarks;
      }
      return <BookmarkModel>[];
    } catch (e) {
      throw CacheException(message: '获取书签列表失败：${e.toString()}');
    }
  }

  @override
  Future<void> saveReaderConfig(ReaderConfig config) async {
    try {
      final String data = jsonEncode(config.toMap());
      await cacheManager.put(_configKey, data);
    } catch (e) {
      throw CacheException(message: '保存阅读器配置失败：${e.toString()}');
    }
  }

  @override
  Future<ReaderConfig?> getReaderConfig() async {
    try {
      final String? data = await cacheManager.get<String>(_configKey);

      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data.toString()) as Map<String, dynamic>;

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
      final String data = jsonEncode(stats.toMap());
      await cacheManager.put(_statsKey, data);
    } catch (e) {
      throw CacheException(message: '保存阅读统计失败：${e.toString()}');
    }
  }

  @override
  Future<ReadingStats?> getReadingStats() async {
    try {
      final String? data = await cacheManager.get<String>(_statsKey);

      if (data != null) {
        final Map<String, dynamic> json = jsonDecode(data) as Map<String, dynamic>;

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
      final List<String> allKeys = await cacheManager.getAllKeys();
      final List<String> chapterIds = <String>[];

      for (final String key in allKeys) {
        if (key.startsWith('$_chapterPrefix$novelId')) {
          final String chapterId = key.split('_').last;
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
        final List<String> allKeys = await cacheManager.getAllKeys();
        final List<String> keysToDelete = allKeys
            .where((String key) =>
                key.contains(novelId) &&
                (key.startsWith(_chapterPrefix) ||
                    key.startsWith(_chapterListPrefix) ||
                    key.startsWith(_novelPrefix) ||
                    key.startsWith(_progressPrefix) ||
                    key.startsWith(_bookmarkPrefix)))
            .toList();

        for (final String key in keysToDelete) {
          await cacheManager.remove(key);
        }
      } else {
        // 清理所有阅读器相关缓存
        await cacheManager.clearAll();
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
      final String today = DateTime.now().toIso8601String().split('T')[0];
      final String key = '$_readingTimePrefix${novelId}_$today';

      // 获取今日已有的阅读时长
      final int existingTime = await cacheManager.get<int>(key) ?? 0;

      // 更新阅读时长
      await cacheManager.put(key, existingTime + minutes);

      // 同时更新总体统计
      await _updateTotalReadingStats(novelId, minutes);
    } catch (e) {
      throw CacheException(message: '更新阅读时长失败：${e.toString()}');
    }
  }

  /// 更新总体阅读统计
  Future<void> _updateTotalReadingStats(String novelId, int minutes) async {
    try {
      final ReadingStats stats = await getReadingStats() ?? const ReadingStats();

      final ReadingStats updatedStats = ReadingStats(
        totalReadingTime: stats.totalReadingTime + minutes,
        booksRead: stats.booksRead,
        chaptersRead: stats.chaptersRead,
        todayReadingTime: stats.todayReadingTime + minutes,
        weekReadingTime: stats.weekReadingTime + minutes,
        monthReadingTime: stats.monthReadingTime + minutes,
        averageReadingSpeed: stats.averageReadingSpeed,
        readingTimeByDate: <String, int>{
          ...stats.readingTimeByDate,
          DateTime.now().toIso8601String().split('T')[0]:
              (stats.readingTimeByDate[
                          DateTime.now().toIso8601String().split('T')[0]] ??
                      0) +
                  minutes,
        },
      );

      await saveReadingStats(updatedStats);
    } catch (e) {
      // 更新统计失败不应该影响主流程
    }
  }
}
