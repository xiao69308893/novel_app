// 小说详情实体
import 'package:equatable/equatable.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';

class BookDetail extends Equatable {

  const BookDetail({
    required this.novel,
    required this.stats, this.chapters = const <ChapterSimpleModel>[],
    this.readingProgress,
    this.isFavorited = false,
    this.isDownloaded = false,
  });
  final NovelModel novel;
  final List<ChapterSimpleModel> chapters;
  final ReadingProgress? readingProgress;
  final bool isFavorited;
  final bool isDownloaded;
  final BookStats stats;

  /// 是否有阅读进度
  bool get hasProgress => readingProgress != null;

  /// 当前阅读章节
  ChapterSimpleModel? get currentChapter {
    if (readingProgress == null) return null;
    try {
      return chapters.firstWhere(
        (ChapterSimpleModel chapter) => chapter.id == readingProgress!.chapterId,
      );
    } catch (e) {
      return chapters.isNotEmpty ? chapters.first : null;
    }
  }

  /// 下一章节
  ChapterSimpleModel? get nextChapter {
    final ChapterSimpleModel? current = currentChapter;
    if (current == null) return chapters.isNotEmpty ? chapters.first : null;
    
    final int currentIndex = chapters.indexWhere((ChapterSimpleModel c) => c.id == current.id);
    if (currentIndex >= 0 && currentIndex < chapters.length - 1) {
      return chapters[currentIndex + 1];
    }
    return null;
  }

  /// 可阅读章节数
  int get readableChapterCount => chapters.where((ChapterSimpleModel chapter) => chapter.canRead).length;

  @override
  List<Object?> get props => <Object?>[
    novel, chapters, readingProgress, 
    isFavorited, isDownloaded, stats
  ];
}

class BookStats extends Equatable {

  const BookStats({
    this.totalViews = 0,
    this.todayViews = 0,
    this.favoriteCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.averageRating = 0.0,
    this.ratingCount = 0,
  });
  final int totalViews;
  final int todayViews;
  final int favoriteCount;
  final int commentCount;
  final int shareCount;
  final double averageRating;
  final int ratingCount;

  /// 格式化阅读量显示
  String get formattedViews {
    if (totalViews < 10000) {
      return '$totalViews次阅读';
    } else if (totalViews < 100000000) {
      return '${(totalViews / 10000).toStringAsFixed(1)}万次阅读';
    } else {
      return '${(totalViews / 100000000).toStringAsFixed(1)}亿次阅读';
    }
  }

  /// 格式化收藏量显示
  String get formattedFavorites {
    if (favoriteCount < 10000) {
      return '$favoriteCount收藏';
    } else {
      return '${(favoriteCount / 10000).toStringAsFixed(1)}万收藏';
    }
  }

  @override
  List<Object> get props => <Object>[
    totalViews, todayViews, favoriteCount, 
    commentCount, shareCount, averageRating, ratingCount
  ];
}
