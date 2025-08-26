// 小说详情数据模型
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/book_detail.dart';

class BookStatsModel extends BookStats {
  const BookStatsModel({
    super.totalViews,
    super.todayViews,
    super.favoriteCount,
    super.commentCount,
    super.shareCount,
    super.averageRating,
    super.ratingCount,
  });

  factory BookStatsModel.fromJson(Map<String, dynamic> json) {
    return BookStatsModel(
      totalViews: json['total_views'] as int? ?? 0,
      todayViews: json['today_views'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['rating_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_views': totalViews,
      'today_views': todayViews,
      'favorite_count': favoriteCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'average_rating': averageRating,
      'rating_count': ratingCount,
    };
  }

  BookStats toEntity() {
    return BookStats(
      totalViews: totalViews,
      todayViews: todayViews,
      favoriteCount: favoriteCount,
      commentCount: commentCount,
      shareCount: shareCount,
      averageRating: averageRating,
      ratingCount: ratingCount,
    );
  }
}

class BookDetailModel extends BookDetail {
  const BookDetailModel({
    required super.novel,
    super.chapters,
    super.readingProgress,
    super.isFavorited,
    super.isDownloaded,
    required super.stats,
  });

  factory BookDetailModel.fromJson(Map<String, dynamic> json) {
    return BookDetailModel(
      novel: NovelModel.fromJson(json['novel'] as Map<String, dynamic>),
      chapters: (json['chapters'] as List?)
          ?.map((chapter) => ChapterSimpleModel.fromJson(chapter as Map<String, dynamic>))
          .toList() ?? [],
      readingProgress: json['reading_progress'] != null
          ? ReadingProgress.fromJson(json['reading_progress'] as Map<String, dynamic>)
          : null,
      isFavorited: json['is_favorited'] as bool? ?? false,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
      stats: BookStatsModel.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'novel': (novel as NovelModel).toJson(),
      'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
      'reading_progress': readingProgress?.toJson(),
      'is_favorited': isFavorited,
      'is_downloaded': isDownloaded,
      'stats': (stats as BookStatsModel).toJson(),
    };
  }

  BookDetail toEntity() {
    return BookDetail(
      novel: novel,
      chapters: chapters,
      readingProgress: readingProgress,
      isFavorited: isFavorited,
      isDownloaded: isDownloaded,
      stats: stats,
    );
  }
}