import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../entities/reader_config.dart';


/// 阅读器仓储接口
abstract class ReaderRepository {
  /// 加载章节内容
  ResultFuture<ChapterModel> loadChapter({
    required String novelId,
    required String chapterId,
  });

  /// 获取章节列表
  ResultFuture<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
  });

  /// 获取小说信息
  ResultFuture<NovelModel> getNovelInfo({
    required String novelId,
  });

  /// 保存阅读进度
  ResultFuture<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  });

  /// 获取阅读进度
  ResultFuture<ReadingProgress?> getReadingProgress({
    required String novelId,
  });

  /// 添加书签
  ResultFuture<BookmarkModel> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
    String? content,
  });

  /// 删除书签
  ResultFuture<void> deleteBookmark({
    required String bookmarkId,
  });

  /// 获取书签列表
  ResultFuture<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  });

  /// 保存阅读器配置
  ResultFuture<void> saveReaderConfig({
    required ReaderConfig config,
  });

  /// 获取阅读器配置
  ResultFuture<ReaderConfig> getReaderConfig();

  /// 缓存章节
  ResultFuture<void> cacheChapter({
    required String novelId,
    required String chapterId,
  });

  /// 获取缓存的章节列表
  ResultFuture<List<String>> getCachedChapterIds({
    required String novelId,
  });

  /// 清理缓存
  ResultFuture<void> clearCache({
    String? novelId,
  });

  /// 更新阅读时长
  ResultFuture<void> updateReadingTime({
    required String novelId,
    required int minutes,
  });

  /// 获取阅读统计
  ResultFuture<ReadingStats> getReadingStats();

  /// 搜索章节
  ResultFuture<List<ChapterSimpleModel>> searchChapters({
    required String novelId,
    required String keyword,
  });

  /// 获取相邻章节
  ResultFuture<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String chapterId,
  });

  /// 购买章节
  ResultFuture<void> purchaseChapter({
    required String novelId,
    required String chapterId,
  });

  /// 检查章节购买状态
  ResultFuture<bool> checkChapterPurchaseStatus({
    required String novelId,
    required String chapterId,
  });
}

/// 阅读进度模型
class ReadingProgress {
  final String novelId;
  final String chapterId;
  final int position;
  final double progress;
  final DateTime updatedAt;

  const ReadingProgress({
    required this.novelId,
    required this.chapterId,
    required this.position,
    required this.progress,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'novelId': novelId,
      'chapterId': chapterId,
      'position': position,
      'progress': progress,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ReadingProgress.fromMap(Map<String, dynamic> map) {
    return ReadingProgress(
      novelId: (map['novelId'] as String?) ?? '',
      chapterId: (map['chapterId'] as String?) ?? '',
      position: (map['position'] as num?)?.toInt() ?? 0,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      updatedAt: DateTime.parse((map['updatedAt'] as String?) ?? DateTime.now().toIso8601String()),
    );
  }
}

/// 阅读统计模型
class ReadingStats {
  final int totalReadingTime; // 总阅读时长（分钟）
  final int booksRead; // 已读小说数
  final int chaptersRead; // 已读章节数
  final int todayReadingTime; // 今日阅读时长（分钟）
  final int weekReadingTime; // 本周阅读时长（分钟）
  final int monthReadingTime; // 本月阅读时长（分钟）
  final double averageReadingSpeed; // 平均阅读速度（字/分钟）
  final Map<String, int> readingTimeByDate; // 按日期统计的阅读时长

  const ReadingStats({
    this.totalReadingTime = 0,
    this.booksRead = 0,
    this.chaptersRead = 0,
    this.todayReadingTime = 0,
    this.weekReadingTime = 0,
    this.monthReadingTime = 0,
    this.averageReadingSpeed = 0.0,
    this.readingTimeByDate = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'totalReadingTime': totalReadingTime,
      'booksRead': booksRead,
      'chaptersRead': chaptersRead,
      'todayReadingTime': todayReadingTime,
      'weekReadingTime': weekReadingTime,
      'monthReadingTime': monthReadingTime,
      'averageReadingSpeed': averageReadingSpeed,
      'readingTimeByDate': readingTimeByDate,
    };
  }

  factory ReadingStats.fromMap(Map<String, dynamic> map) => ReadingStats(
      totalReadingTime: (map['totalReadingTime'] as num?)?.toInt() ?? 0,
      booksRead: (map['booksRead'] as num?)?.toInt() ?? 0,
      chaptersRead: (map['chaptersRead'] as num?)?.toInt() ?? 0,
      todayReadingTime: (map['todayReadingTime'] as num?)?.toInt() ?? 0,
      weekReadingTime: (map['weekReadingTime'] as num?)?.toInt() ?? 0,
      monthReadingTime: (map['monthReadingTime'] as num?)?.toInt() ?? 0,
      averageReadingSpeed: (map['averageReadingSpeed'] as num?)?.toDouble() ?? 0.0,
      readingTimeByDate: Map<String, int>.from(
        (map['readingTimeByDate'] as Map<dynamic, dynamic>?) ?? {},
      ),
    );
}