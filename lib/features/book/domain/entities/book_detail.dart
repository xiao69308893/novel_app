// 小说详情实体
import 'package:equatable/equatable.dart';
import '../../../shared/models/novel_model.dart';
import '../../../shared/models/chapter_model.dart';

class BookDetail extends Equatable {
  final NovelModel novel;
  final List<ChapterSimpleModel> chapters;
  final ReadingProgress? readingProgress;
  final bool isFavorited;
  final bool isDownloaded;
  final BookStats stats;

  const BookDetail({
    required this.novel,
    this.chapters = const [],
    this.readingProgress,
    this.isFavorited = false,
    this.isDownloaded = false,
    required this.stats,
  });

  /// 是否有阅读进度
  bool get hasProgress => readingProgress != null;

  /// 当前阅读章节
  ChapterSimpleModel? get currentChapter {
    if (readingProgress == null) return null;
    return chapters.firstWhere(
      (chapter) => chapter.id == readingProgress!.chapterId,
      orElse: () => chapters.isNotEmpty ? chapters.first : null,
    );
  }

  /// 下一章节
  ChapterSimpleModel? get nextChapter {
    final current = currentChapter;
    if (current == null) return chapters.isNotEmpty ? chapters.first : null;
    
    final currentIndex = chapters.indexWhere((c) => c.id == current.id);
    if (currentIndex >= 0 && currentIndex < chapters.length - 1) {
      return chapters[currentIndex + 1];
    }
    return null;
  }

  /// 可阅读章节数
  int get readableChapterCount {
    return chapters.where((chapter) => chapter.canRead).length;
  }

  @override
  List<Object?> get props => [
    novel, chapters, readingProgress, 
    isFavorited, isDownloaded, stats
  ];
}

class BookStats extends Equatable {
  final int totalViews;
  final int todayViews;
  final int favoriteCount;
  final int commentCount;
  final int shareCount;
  final double averageRating;
  final int ratingCount;

  const BookStats({
    this.totalViews = 0,
    this.todayViews = 0,
    this.favoriteCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });

  /// 格式化阅读量显示
  String get formattedViews {
    if (totalViews < 10000) {
      return '${totalViews}次阅读';
    } else if (totalViews < 100000000) {
      return '${(totalViews / 10000).toStringAsFixed(1)}万次阅读';
    } else {
      return '${(totalViews / 100000000).toStringAsFixed(1)}亿次阅读';
    }
  }

  /// 格式化收藏量显示
  String get formattedFavorites {
    if (favoriteCount < 10000) {
      return '${favoriteCount}收藏';
    } else {
      return '${(favoriteCount / 10000).toStringAsFixed(1)}万收藏';
    }
  }

  @override
  List<Object> get props => [
    totalViews, todayViews, favoriteCount, 
    commentCount, shareCount, averageRating, ratingCount
  ];
}
