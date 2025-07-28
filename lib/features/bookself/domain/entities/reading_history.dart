import 'package:equatable/equatable.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';

/// 阅读历史实体
class ReadingHistory extends Equatable {
  /// 历史记录ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 小说信息
  final NovelSimpleModel novel;
  
  /// 最后阅读的章节信息
  final ChapterSimpleModel? lastChapter;
  
  /// 阅读进度
  final ReadingProgress? progress;
  
  /// 阅读时长（秒）
  final int readingTime;
  
  /// 最后阅读时间
  final DateTime lastReadAt;

  const ReadingHistory({
    required this.id,
    required this.userId,
    required this.novel,
    this.lastChapter,
    this.progress,
    this.readingTime = 0,
    required this.lastReadAt,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      novel: NovelSimpleModel.fromJson(json['novel'] as Map<String, dynamic>),
      lastChapter: json['last_chapter'] != null
          ? ChapterSimpleModel.fromJson(json['last_chapter'] as Map<String, dynamic>)
          : null,
      progress: json['progress'] != null
          ? ReadingProgress.fromJson(json['progress'] as Map<String, dynamic>)
          : null,
      readingTime: json['reading_time'] as int? ?? 0,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'novel': novel.toJson(),
      'last_chapter': lastChapter?.toJson(),
      'progress': progress?.toJson(),
      'reading_time': readingTime,
      'last_read_at': lastReadAt.toIso8601String(),
    };
  }

  /// 阅读时长显示
  String get readingTimeText {
    final hours = readingTime ~/ 3600;
    final minutes = (readingTime % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }

  /// 最后阅读时间显示
  String get lastReadTimeText {
    final now = DateTime.now();
    final diff = now.difference(lastReadAt);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前';
      } else {
        return '${diff.inHours}小时前';
      }
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else {
      return '${lastReadAt.month}月${lastReadAt.day}日';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        novel,
        lastChapter,
        progress,
        readingTime,
        lastReadAt,
      ];
}
