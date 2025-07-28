import 'package:equatable/equatable.dart';
import '../../../../shared/models/novel_model.dart';

/// 收藏小说实体
class FavoriteNovel extends Equatable {
  /// 收藏ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 小说信息
  final NovelSimpleModel novel;
  
  /// 收藏时间
  final DateTime createdAt;
  
  /// 最后阅读时间
  final DateTime? lastReadAt;
  
  /// 是否已读完
  final bool isFinished;
  
  /// 阅读进度（章节数）
  final int readChapters;

  const FavoriteNovel({
    required this.id,
    required this.userId,
    required this.novel,
    required this.createdAt,
    this.lastReadAt,
    this.isFinished = false,
    this.readChapters = 0,
  });

  factory FavoriteNovel.fromJson(Map<String, dynamic> json) {
    return FavoriteNovel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      novel: NovelSimpleModel.fromJson(json['novel'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastReadAt: json['last_read_at'] != null
          ? DateTime.parse(json['last_read_at'] as String)
          : null,
      isFinished: json['is_finished'] as bool? ?? false,
      readChapters: json['read_chapters'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'novel': novel.toJson(),
      'created_at': createdAt.toIso8601String(),
      'last_read_at': lastReadAt?.toIso8601String(),
      'is_finished': isFinished,
      'read_chapters': readChapters,
    };
  }

  /// 阅读进度百分比
  double get progressPercent {
    if (novel.chapterCount == 0) return 0.0;
    return (readChapters / novel.chapterCount).clamp(0.0, 1.0);
  }

  /// 进度显示文本
  String get progressText {
    return '$readChapters/${novel.chapterCount}章';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        novel,
        createdAt,
        lastReadAt,
        isFinished,
        readChapters,
      ];
}