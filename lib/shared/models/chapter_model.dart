import 'package:equatable/equatable.dart';

/// 章节类型枚举
enum ChapterType {
  normal(0, '正文'),
  vip(1, 'VIP章节'),
  free(2, '免费章节'),
  preview(3, '试读章节');

  const ChapterType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static ChapterType fromValue(int? value) {
    return ChapterType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ChapterType.normal,
    );
  }
}

/// 章节状态枚举
enum ChapterStatus {
  published(0, '已发布'),
  draft(1, '草稿'),
  locked(2, '锁定'),
  deleted(3, '已删除');

  const ChapterStatus(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static ChapterStatus fromValue(int? value) {
    return ChapterStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ChapterStatus.published,
    );
  }
}

/// 章节统计
class ChapterStats extends Equatable {
  /// 阅读次数
  final int readCount;
  
  /// 评论次数
  final int commentCount;
  
  /// 点赞次数
  final int likeCount;
  
  /// 分享次数
  final int shareCount;
  
  /// 今日阅读次数
  final int todayReadCount;

  const ChapterStats({
    this.readCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.todayReadCount = 0,
  });

  factory ChapterStats.fromJson(Map<String, dynamic> json) {
    return ChapterStats(
      readCount: json['read_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      todayReadCount: json['today_read_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'read_count': readCount,
      'comment_count': commentCount,
      'like_count': likeCount,
      'share_count': shareCount,
      'today_read_count': todayReadCount,
    };
  }

  ChapterStats copyWith({
    int? readCount,
    int? commentCount,
    int? likeCount,
    int? shareCount,
    int? todayReadCount,
  }) {
    return ChapterStats(
      readCount: readCount ?? this.readCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      todayReadCount: todayReadCount ?? this.todayReadCount,
    );
  }

  @override
  List<Object> get props => [
        readCount,
        commentCount,
        likeCount,
        shareCount,
        todayReadCount,
      ];
}

/// 章节模型
class ChapterModel extends Equatable {
  /// 章节ID
  final String id;
  
  /// 所属小说ID
  final String novelId;
  
  /// 章节标题
  final String title;
  
  /// 章节序号
  final int chapterNumber;
  
  /// 章节内容
  final String? content;
  
  /// 章节摘要/预览
  final String? summary;
  
  /// 章节类型
  final ChapterType type;
  
  /// 章节状态
  final ChapterStatus status;
  
  /// 字数
  final int wordCount;
  
  /// 价格（积分/金币）
  final int price;
  
  /// 是否免费
  final bool isFree;
  
  /// 是否已购买
  final bool isPurchased;
  
  /// 是否已缓存
  final bool isCached;
  
  /// 是否已收藏
  final bool isFavorite;
  
  /// 发布时间
  final DateTime? publishTime;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 统计信息
  final ChapterStats? stats;
  
  /// 上一章节ID
  final String? previousChapterId;
  
  /// 下一章节ID
  final String? nextChapterId;
  
  /// 扩展字段
  final Map<String, dynamic>? extra;

  const ChapterModel({
    required this.id,
    required this.novelId,
    required this.title,
    required this.chapterNumber,
    this.content,
    this.summary,
    this.type = ChapterType.normal,
    this.status = ChapterStatus.published,
    this.wordCount = 0,
    this.price = 0,
    this.isFree = true,
    this.isPurchased = false,
    this.isCached = false,
    this.isFavorite = false,
    this.publishTime,
    required this.createdAt,
    required this.updatedAt,
    this.stats,
    this.previousChapterId,
    this.nextChapterId,
    this.extra,
  });

  /// 从JSON创建章节模型
  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      novelId: json['novel_id'] as String,
      title: json['title'] as String,
      chapterNumber: json['chapter_number'] as int,
      content: json['content'] as String?,
      summary: json['summary'] as String?,
      type: ChapterType.fromValue(json['type'] as int?),
      status: ChapterStatus.fromValue(json['status'] as int?),
      wordCount: json['word_count'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? true,
      isPurchased: json['is_purchased'] as bool? ?? false,
      isCached: json['is_cached'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      publishTime: json['publish_time'] != null
          ? DateTime.parse(json['publish_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      stats: json['stats'] != null
          ? ChapterStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      previousChapterId: json['previous_chapter_id'] as String?,
      nextChapterId: json['next_chapter_id'] as String?,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novel_id': novelId,
      'title': title,
      'chapter_number': chapterNumber,
      'content': content,
      'summary': summary,
      'type': type.value,
      'status': status.value,
      'word_count': wordCount,
      'price': price,
      'is_free': isFree,
      'is_purchased': isPurchased,
      'is_cached': isCached,
      'is_favorite': isFavorite,
      'publish_time': publishTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'stats': stats?.toJson(),
      'previous_chapter_id': previousChapterId,
      'next_chapter_id': nextChapterId,
      'extra': extra,
    };
  }

  /// 复制并修改章节信息
  ChapterModel copyWith({
    String? id,
    String? novelId,
    String? title,
    int? chapterNumber,
    String? content,
    String? summary,
    ChapterType? type,
    ChapterStatus? status,
    int? wordCount,
    int? price,
    bool? isFree,
    bool? isPurchased,
    bool? isCached,
    bool? isFavorite,
    DateTime? publishTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChapterStats? stats,
    String? previousChapterId,
    String? nextChapterId,
    Map<String, dynamic>? extra,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: content ?? this.content,
      summary: summary ?? this.summary,
      type: type ?? this.type,
      status: status ?? this.status,
      wordCount: wordCount ?? this.wordCount,
      price: price ?? this.price,
      isFree: isFree ?? this.isFree,
      isPurchased: isPurchased ?? this.isPurchased,
      isCached: isCached ?? this.isCached,
      isFavorite: isFavorite ?? this.isFavorite,
      publishTime: publishTime ?? this.publishTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      stats: stats ?? this.stats,
      previousChapterId: previousChapterId ?? this.previousChapterId,
      nextChapterId: nextChapterId ?? this.nextChapterId,
      extra: extra ?? this.extra,
    );
  }

  /// 是否可以阅读
  bool get canRead {
    return status == ChapterStatus.published && 
           (isFree || isPurchased);
  }

  /// 是否需要购买
  bool get needPurchase {
    return !isFree && !isPurchased && price > 0;
  }

  /// 是否为VIP章节
  bool get isVip {
    return type == ChapterType.vip;
  }

  /// 格式化字数显示
  String get formattedWordCount {
    if (wordCount < 1000) {
      return '${wordCount}字';
    } else {
      return '${(wordCount / 1000).toStringAsFixed(1)}k字';
    }
  }

  /// 章节序号显示（带前缀）
  String get chapterNumberText {
    return '第${chapterNumber}章';
  }

  /// 完整章节标题
  String get fullTitle {
    return '$chapterNumberText $title';
  }

  /// 价格显示
  String get priceText {
    if (isFree) return '免费';
    if (price == 0) return '免费';
    return '${price}积分';
  }

  /// 发布时间显示
  String get publishTimeText {
    if (publishTime == null) return '未发布';
    
    final now = DateTime.now();
    final diff = now.difference(publishTime!);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前';
      } else {
        return '${diff.inHours}小时前';
      }
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${publishTime!.year}-${publishTime!.month.toString().padLeft(2, '0')}-${publishTime!.day.toString().padLeft(2, '0')}';
    }
  }

  /// 是否有上一章
  bool get hasPrevious => previousChapterId != null;

  /// 是否有下一章
  bool get hasNext => nextChapterId != null;

  /// 阅读次数显示
  String get readCountText {
    final count = stats?.readCount ?? 0;
    if (count < 1000) {
      return '${count}次阅读';
    } else {
      return '${(count / 1000).toStringAsFixed(1)}k次阅读';
    }
  }

  @override
  List<Object?> get props => [
        id,
        novelId,
        title,
        chapterNumber,
        content,
        summary,
        type,
        status,
        wordCount,
        price,
        isFree,
        isPurchased,
        isCached,
        isFavorite,
        publishTime,
        createdAt,
        updatedAt,
        stats,
        previousChapterId,
        nextChapterId,
        extra,
      ];

  @override
  String toString() {
    return 'ChapterModel{id: $id, title: $title, chapterNumber: $chapterNumber}';
  }

  static fromMap(Map<String, dynamic> map) {}
}

/// 章节简化模型（用于章节列表显示）
class ChapterSimpleModel extends Equatable {
  /// 章节ID
  final String id;
  
  /// 章节标题
  final String title;
  
  /// 章节序号
  final int chapterNumber;
  
  /// 章节类型
  final ChapterType type;
  
  /// 字数
  final int wordCount;
  
  /// 价格
  final int price;
  
  /// 是否免费
  final bool isFree;
  
  /// 是否已购买
  final bool isPurchased;
  
  /// 是否已缓存
  final bool isCached;
  
  /// 发布时间
  final DateTime? publishTime;

  const ChapterSimpleModel({
    required this.id,
    required this.title,
    required this.chapterNumber,
    this.type = ChapterType.normal,
    this.wordCount = 0,
    this.price = 0,
    this.isFree = true,
    this.isPurchased = false,
    this.isCached = false,
    this.publishTime,
  });

  /// 从完整模型创建简化模型
  factory ChapterSimpleModel.fromChapter(ChapterModel chapter) {
    return ChapterSimpleModel(
      id: chapter.id,
      title: chapter.title,
      chapterNumber: chapter.chapterNumber,
      type: chapter.type,
      wordCount: chapter.wordCount,
      price: chapter.price,
      isFree: chapter.isFree,
      isPurchased: chapter.isPurchased,
      isCached: chapter.isCached,
      publishTime: chapter.publishTime,
    );
  }

  factory ChapterSimpleModel.fromJson(Map<String, dynamic> json) {
    return ChapterSimpleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      chapterNumber: json['chapter_number'] as int,
      type: ChapterType.fromValue(json['type'] as int?),
      wordCount: json['word_count'] as int? ?? 0,
      price: json['price'] as int? ?? 0,
      isFree: json['is_free'] as bool? ?? true,
      isPurchased: json['is_purchased'] as bool? ?? false,
      isCached: json['is_cached'] as bool? ?? false,
      publishTime: json['publish_time'] != null
          ? DateTime.parse(json['publish_time'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chapter_number': chapterNumber,
      'type': type.value,
      'word_count': wordCount,
      'price': price,
      'is_free': isFree,
      'is_purchased': isPurchased,
      'is_cached': isCached,
      'publish_time': publishTime?.toIso8601String(),
    };
  }

  /// 是否可以阅读
  bool get canRead => isFree || isPurchased;

  /// 是否需要购买
  bool get needPurchase => !isFree && !isPurchased && price > 0;

  /// 章节序号显示
  String get chapterNumberText => '第${chapterNumber}章';

  /// 完整章节标题
  String get fullTitle => '$chapterNumberText $title';

  /// 格式化字数显示
  String get formattedWordCount {
    if (wordCount < 1000) {
      return '${wordCount}字';
    } else {
      return '${(wordCount / 1000).toStringAsFixed(1)}k字';
    }
  }

  /// 价格显示
  String get priceText {
    if (isFree) return '免费';
    if (price == 0) return '免费';
    return '${price}积分';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        chapterNumber,
        type,
        wordCount,
        price,
        isFree,
        isPurchased,
        isCached,
        publishTime,
      ];

  @override
  String toString() {
    return 'ChapterSimpleModel{id: $id, title: $title, chapterNumber: $chapterNumber}';
  }
}

/// 阅读进度模型
class ReadingProgress extends Equatable {
  /// 用户ID
  final String userId;
  
  /// 小说ID
  final String novelId;
  
  /// 当前章节ID
  final String chapterId;
  
  /// 当前章节序号
  final int chapterNumber;
  
  /// 章节内阅读位置（字符位置）
  final int position;
  
  /// 章节内阅读进度百分比
  final double progress;
  
  /// 总阅读时长（秒）
  final int totalReadingTime;
  
  /// 最后阅读时间
  final DateTime lastReadAt;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;

  const ReadingProgress({
    required this.userId,
    required this.novelId,
    required this.chapterId,
    required this.chapterNumber,
    this.position = 0,
    this.progress = 0.0,
    this.totalReadingTime = 0,
    required this.lastReadAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      userId: json['user_id'] as String,
      novelId: json['novel_id'] as String,
      chapterId: json['chapter_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      position: json['position'] as int? ?? 0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      totalReadingTime: json['total_reading_time'] as int? ?? 0,
      lastReadAt: DateTime.parse(json['last_read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'novel_id': novelId,
      'chapter_id': chapterId,
      'chapter_number': chapterNumber,
      'position': position,
      'progress': progress,
      'total_reading_time': totalReadingTime,
      'last_read_at': lastReadAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ReadingProgress copyWith({
    String? userId,
    String? novelId,
    String? chapterId,
    int? chapterNumber,
    int? position,
    double? progress,
    int? totalReadingTime,
    DateTime? lastReadAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReadingProgress(
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      position: position ?? this.position,
      progress: progress ?? this.progress,
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 进度百分比显示
  String get progressText {
    return '${(progress * 100).toStringAsFixed(1)}%';
  }

  /// 总阅读时长显示
  String get totalReadingTimeText {
    final hours = totalReadingTime ~/ 3600;
    final minutes = (totalReadingTime % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }

  @override
  List<Object> get props => [
        userId,
        novelId,
        chapterId,
        chapterNumber,
        position,
        progress,
        totalReadingTime,
        lastReadAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'ReadingProgress{userId: $userId, novelId: $novelId, chapterNumber: $chapterNumber, progress: $progress}';
  }
}

/// 书签模型
class BookmarkModel extends Equatable {
  /// 书签ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 小说ID
  final String novelId;
  
  /// 章节ID
  final String chapterId;
  
  /// 章节序号
  final int chapterNumber;
  
  /// 章节标题
  final String chapterTitle;
  
  /// 书签位置（字符位置）
  final int position;
  
  /// 书签内容（书签位置的文本片段）
  final String? content;
  
  /// 书签备注
  final String? note;
  
  /// 创建时间
  final DateTime createdAt;

  const BookmarkModel({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.chapterId,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.position,
    this.content,
    this.note,
    required this.createdAt,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      novelId: json['novel_id'] as String,
      chapterId: json['chapter_id'] as String,
      chapterNumber: json['chapter_number'] as int,
      chapterTitle: json['chapter_title'] as String,
      position: json['position'] as int,
      content: json['content'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'novel_id': novelId,
      'chapter_id': chapterId,
      'chapter_number': chapterNumber,
      'chapter_title': chapterTitle,
      'position': position,
      'content': content,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 章节位置显示
  String get locationText {
    return '第${chapterNumber}章 $chapterTitle';
  }

  /// 创建时间显示
  String get createdTimeText {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前';
      } else {
        return '${diff.inHours}小时前';
      }
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        novelId,
        chapterId,
        chapterNumber,
        chapterTitle,
        position,
        content,
        note,
        createdAt,
      ];

  @override
  String toString() {
    return 'BookmarkModel{id: $id, chapterNumber: $chapterNumber, position: $position}';
  }
}