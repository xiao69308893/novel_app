import 'package:equatable/equatable.dart';

/// 小说状态枚举
enum NovelStatus {
  serializing(0, '连载中'),
  completed(1, '已完结'),
  paused(2, '暂停更新'),
  dropped(3, '太监');

  const NovelStatus(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static NovelStatus fromValue(int? value) {
    return NovelStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => NovelStatus.serializing,
    );
  }
}

/// VIP章节类型枚举
enum VipType {
  free(0, '免费'),
  vip(1, 'VIP'),
  premium(2, '付费');

  const VipType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static VipType fromValue(int? value) {
    return VipType.values.firstWhere(
      (v) => v.value == value,
      orElse: () => VipType.free,
    );
  }
}

/// 小说分类
class NovelCategory extends Equatable {
  /// 分类ID
  final String id;
  
  /// 分类名称
  final String name;
  
  /// 分类描述
  final String? description;
  
  /// 分类图标
  final String? icon;
  
  /// 排序权重
  final int sort;
  
  /// 是否启用
  final bool enabled;

  const NovelCategory({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.sort = 0,
    this.enabled = true,
  });

  factory NovelCategory.fromJson(Map<String, dynamic> json) {
    return NovelCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      sort: json['sort'] as int? ?? 0,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'sort': sort,
      'enabled': enabled,
    };
  }

  @override
  List<Object?> get props => [id, name, description, icon, sort, enabled];

  @override
  String toString() => 'NovelCategory{id: $id, name: $name}';
}

/// 小说标签
class NovelTag extends Equatable {
  /// 标签ID
  final String id;
  
  /// 标签名称
  final String name;
  
  /// 标签颜色
  final String? color;
  
  /// 使用次数
  final int useCount;

  const NovelTag({
    required this.id,
    required this.name,
    this.color,
    this.useCount = 0,
  });

  factory NovelTag.fromJson(Map<String, dynamic> json) {
    return NovelTag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      useCount: json['use_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'use_count': useCount,
    };
  }

  @override
  List<Object?> get props => [id, name, color, useCount];

  @override
  String toString() => 'NovelTag{id: $id, name: $name}';
}

/// 小说作者
class NovelAuthor extends Equatable {
  /// 作者ID
  final String id;
  
  /// 作者名称
  final String name;
  
  /// 作者头像
  final String? avatar;
  
  /// 作者简介
  final String? bio;
  
  /// 作品数量
  final int worksCount;
  
  /// 粉丝数量
  final int fansCount;

  const NovelAuthor({
    required this.id,
    required this.name,
    this.avatar,
    this.bio,
    this.worksCount = 0,
    this.fansCount = 0,
  });

  factory NovelAuthor.fromJson(Map<String, dynamic> json) {
    return NovelAuthor(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      worksCount: json['works_count'] as int? ?? 0,
      fansCount: json['fans_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'bio': bio,
      'works_count': worksCount,
      'fans_count': fansCount,
    };
  }

  @override
  List<Object?> get props => [id, name, avatar, bio, worksCount, fansCount];

  @override
  String toString() => 'NovelAuthor{id: $id, name: $name}';
}

/// 小说评分
class NovelRating extends Equatable {
  /// 总评分
  final double average;
  
  /// 评分人数
  final int count;
  
  /// 5星评分数量
  final int star5Count;
  
  /// 4星评分数量
  final int star4Count;
  
  /// 3星评分数量
  final int star3Count;
  
  /// 2星评分数量
  final int star2Count;
  
  /// 1星评分数量
  final int star1Count;

  const NovelRating({
    this.average = 0.0,
    this.count = 0,
    this.star5Count = 0,
    this.star4Count = 0,
    this.star3Count = 0,
    this.star2Count = 0,
    this.star1Count = 0,
  });

  factory NovelRating.fromJson(Map<String, dynamic> json) {
    return NovelRating(
      average: (json['average'] as num?)?.toDouble() ?? 0.0,
      count: json['count'] as int? ?? 0,
      star5Count: json['star5_count'] as int? ?? 0,
      star4Count: json['star4_count'] as int? ?? 0,
      star3Count: json['star3_count'] as int? ?? 0,
      star2Count: json['star2_count'] as int? ?? 0,
      star1Count: json['star1_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
      'count': count,
      'star5_count': star5Count,
      'star4_count': star4Count,
      'star3_count': star3Count,
      'star2_count': star2Count,
      'star1_count': star1Count,
    };
  }

  /// 评分分布百分比
  Map<int, double> get distribution {
    if (count == 0) return {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    
    return {
      5: star5Count / count * 100,
      4: star4Count / count * 100,
      3: star3Count / count * 100,
      2: star2Count / count * 100,
      1: star1Count / count * 100,
    };
  }

  @override
  List<Object> get props => [
        average,
        count,
        star5Count,
        star4Count,
        star3Count,
        star2Count,
        star1Count,
      ];
}

/// 小说统计
class NovelStats extends Equatable {
  /// 阅读次数
  final int readCount;
  
  /// 收藏次数
  final int favoriteCount;
  
  /// 评论次数
  final int commentCount;
  
  /// 分享次数
  final int shareCount;
  
  /// 推荐次数
  final int recommendCount;
  
  /// 今日阅读次数
  final int todayReadCount;
  
  /// 本周阅读次数
  final int weekReadCount;
  
  /// 本月阅读次数
  final int monthReadCount;

  const NovelStats({
    this.readCount = 0,
    this.favoriteCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.recommendCount = 0,
    this.todayReadCount = 0,
    this.weekReadCount = 0,
    this.monthReadCount = 0,
  });

  factory NovelStats.fromJson(Map<String, dynamic> json) {
    return NovelStats(
      readCount: json['read_count'] as int? ?? 0,
      favoriteCount: json['favorite_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      recommendCount: json['recommend_count'] as int? ?? 0,
      todayReadCount: json['today_read_count'] as int? ?? 0,
      weekReadCount: json['week_read_count'] as int? ?? 0,
      monthReadCount: json['month_read_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'read_count': readCount,
      'favorite_count': favoriteCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'recommend_count': recommendCount,
      'today_read_count': todayReadCount,
      'week_read_count': weekReadCount,
      'month_read_count': monthReadCount,
    };
  }

  /// 热度值计算
  double get hotScore {
    return (readCount * 1.0 +
            favoriteCount * 2.0 +
            commentCount * 1.5 +
            shareCount * 3.0 +
            recommendCount * 2.5 +
            todayReadCount * 5.0) /
        100;
  }

  @override
  List<Object> get props => [
        readCount,
        favoriteCount,
        commentCount,
        shareCount,
        recommendCount,
        todayReadCount,
        weekReadCount,
        monthReadCount,
      ];
}

/// 小说模型
class NovelModel extends Equatable {
  /// 小说ID
  final String id;
  
  /// 小说标题
  final String title;
  
  /// 作者信息
  final NovelAuthor author;
  
  /// 小说描述
  final String? description;
  
  /// 封面图片URL
  final String? coverUrl;
  
  /// 分类信息
  final NovelCategory? category;
  
  /// 标签列表
  final List<NovelTag> tags;
  
  /// 小说状态
  final NovelStatus status;
  
  /// VIP类型
  final VipType vipType;
  
  /// 总字数
  final int wordCount;
  
  /// 章节数量
  final int chapterCount;
  
  /// 最新章节标题
  final String? latestChapterTitle;
  
  /// 最新章节ID
  final String? latestChapterId;
  
  /// 最后更新时间
  final DateTime? lastUpdateTime;
  
  /// 发布时间
  final DateTime publishTime;
  
  /// 创建时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 评分信息
  final NovelRating? rating;
  
  /// 统计信息
  final NovelStats? stats;
  
  /// 是否完结
  final bool isFinished;
  
  /// 是否VIP
  final bool isVip;
  
  /// 是否热门
  final bool isHot;
  
  /// 是否推荐
  final bool isRecommended;
  
  /// 扩展字段
  final Map<String, dynamic>? extra;

  const NovelModel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.category,
    this.tags = const [],
    this.status = NovelStatus.serializing,
    this.vipType = VipType.free,
    this.wordCount = 0,
    this.chapterCount = 0,
    this.latestChapterTitle,
    this.latestChapterId,
    this.lastUpdateTime,
    required this.publishTime,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.stats,
    this.isFinished = false,
    this.isVip = false,
    this.isHot = false,
    this.isRecommended = false,
    this.extra,
  });

  /// 从JSON创建小说模型
  factory NovelModel.fromJson(Map<String, dynamic> json) {
    return NovelModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: NovelAuthor.fromJson(json['author'] as Map<String, dynamic>),
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      category: json['category'] != null
          ? NovelCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      tags: (json['tags'] as List?)
          ?.map((tag) => NovelTag.fromJson(tag as Map<String, dynamic>))
          .toList() ?? [],
      status: NovelStatus.fromValue(json['status'] as int?),
      vipType: VipType.fromValue(json['vip_type'] as int?),
      wordCount: json['word_count'] as int? ?? 0,
      chapterCount: json['chapter_count'] as int? ?? 0,
      latestChapterTitle: json['latest_chapter_title'] as String?,
      latestChapterId: json['latest_chapter_id'] as String?,
      lastUpdateTime: json['last_update_time'] != null
          ? DateTime.parse(json['last_update_time'] as String)
          : null,
      publishTime: DateTime.parse(json['publish_time'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      rating: json['rating'] != null
          ? NovelRating.fromJson(json['rating'] as Map<String, dynamic>)
          : null,
      stats: json['stats'] != null
          ? NovelStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      isFinished: json['is_finished'] as bool? ?? false,
      isVip: json['is_vip'] as bool? ?? false,
      isHot: json['is_hot'] as bool? ?? false,
      isRecommended: json['is_recommended'] as bool? ?? false,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author.toJson(),
      'description': description,
      'cover_url': coverUrl,
      'category': category?.toJson(),
      'tags': tags.map((tag) => tag.toJson()).toList(),
      'status': status.value,
      'vip_type': vipType.value,
      'word_count': wordCount,
      'chapter_count': chapterCount,
      'latest_chapter_title': latestChapterTitle,
      'latest_chapter_id': latestChapterId,
      'last_update_time': lastUpdateTime?.toIso8601String(),
      'publish_time': publishTime.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'rating': rating?.toJson(),
      'stats': stats?.toJson(),
      'is_finished': isFinished,
      'is_vip': isVip,
      'is_hot': isHot,
      'is_recommended': isRecommended,
      'extra': extra,
    };
  }

  /// 复制并修改小说信息
  NovelModel copyWith({
    String? id,
    String? title,
    NovelAuthor? author,
    String? description,
    String? coverUrl,
    NovelCategory? category,
    List<NovelTag>? tags,
    NovelStatus? status,
    VipType? vipType,
    int? wordCount,
    int? chapterCount,
    String? latestChapterTitle,
    String? latestChapterId,
    DateTime? lastUpdateTime,
    DateTime? publishTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    NovelRating? rating,
    NovelStats? stats,
    bool? isFinished,
    bool? isVip,
    bool? isHot,
    bool? isRecommended,
    Map<String, dynamic>? extra,
  }) {
    return NovelModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      vipType: vipType ?? this.vipType,
      wordCount: wordCount ?? this.wordCount,
      chapterCount: chapterCount ?? this.chapterCount,
      latestChapterTitle: latestChapterTitle ?? this.latestChapterTitle,
      latestChapterId: latestChapterId ?? this.latestChapterId,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      publishTime: publishTime ?? this.publishTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      stats: stats ?? this.stats,
      isFinished: isFinished ?? this.isFinished,
      isVip: isVip ?? this.isVip,
      isHot: isHot ?? this.isHot,
      isRecommended: isRecommended ?? this.isRecommended,
      extra: extra ?? this.extra,
    );
  }

  /// 格式化字数显示
  String get formattedWordCount {
    if (wordCount < 10000) {
      return '${wordCount}字';
    } else if (wordCount < 100000000) {
      return '${(wordCount / 10000).toStringAsFixed(1)}万字';
    } else {
      return '${(wordCount / 100000000).toStringAsFixed(1)}亿字';
    }
  }

  /// 格式化阅读次数
  String get formattedReadCount {
    final readCount = stats?.readCount ?? 0;
    if (readCount < 10000) {
      return '${readCount}次阅读';
    } else if (readCount < 100000000) {
      return '${(readCount / 10000).toStringAsFixed(1)}万次阅读';
    } else {
      return '${(readCount / 100000000).toStringAsFixed(1)}亿次阅读';
    }
  }

  /// 更新状态描述
  String get updateStatusText {
    if (isFinished) return '已完结';
    
    if (lastUpdateTime == null) return '未知';
    
    final now = DateTime.now();
    final diff = now.difference(lastUpdateTime!);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前更新';
      } else {
        return '${diff.inHours}小时前更新';
      }
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前更新';
    } else if (diff.inDays < 365) {
      return '${(diff.inDays / 30).floor()}个月前更新';
    } else {
      return '${(diff.inDays / 365).floor()}年前更新';
    }
  }

  /// 是否最近更新（7天内）
  bool get isRecentlyUpdated {
    if (lastUpdateTime == null) return false;
    return DateTime.now().difference(lastUpdateTime!).inDays <= 7;
  }

  /// 是否新书（发布30天内）
  bool get isNewBook {
    return DateTime.now().difference(publishTime).inDays <= 30;
  }

  /// 平均评分显示
  String get ratingDisplay {
    if (rating == null || rating!.count == 0) return '暂无评分';
    return '${rating!.average.toStringAsFixed(1)}分 (${rating!.count}人评价)';
  }

  /// 标签名称列表
  List<String> get tagNames => tags.map((tag) => tag.name).toList();

  /// 分类名称
  String get categoryName => category?.name ?? '未分类';

  /// 热度值
  double get hotScore => stats?.hotScore ?? 0.0;

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        description,
        coverUrl,
        category,
        tags,
        status,
        vipType,
        wordCount,
        chapterCount,
        latestChapterTitle,
        latestChapterId,
        lastUpdateTime,
        publishTime,
        createdAt,
        updatedAt,
        rating,
        stats,
        isFinished,
        isVip,
        isHot,
        isRecommended,
        extra,
      ];

  @override
  String toString() {
    return 'NovelModel{id: $id, title: $title, author: ${author.name}}';
  }
}

/// 小说简化模型（用于列表显示）
class NovelSimpleModel extends Equatable {
  /// 小说ID
  final String id;
  
  /// 小说标题
  final String title;
  
  /// 作者名称
  final String authorName;
  
  /// 封面图片URL
  final String? coverUrl;
  
  /// 分类名称
  final String? categoryName;
  
  /// 小说状态
  final NovelStatus status;
  
  /// 总字数
  final int wordCount;
  
  /// 章节数量
  final int chapterCount;
  
  /// 最新章节标题
  final String? latestChapterTitle;
  
  /// 最后更新时间
  final DateTime? lastUpdateTime;
  
  /// 是否完结
  final bool isFinished;
  
  /// 是否VIP
  final bool isVip;
  
  /// 是否热门
  final bool isHot;

  const NovelSimpleModel({
    required this.id,
    required this.title,
    required this.authorName,
    this.coverUrl,
    this.categoryName,
    this.status = NovelStatus.serializing,
    this.wordCount = 0,
    this.chapterCount = 0,
    this.latestChapterTitle,
    this.lastUpdateTime,
    this.isFinished = false,
    this.isVip = false,
    this.isHot = false,
  });

  /// 从完整模型创建简化模型
  factory NovelSimpleModel.fromNovel(NovelModel novel) {
    return NovelSimpleModel(
      id: novel.id,
      title: novel.title,
      authorName: novel.author.name,
      coverUrl: novel.coverUrl,
      categoryName: novel.category?.name,
      status: novel.status,
      wordCount: novel.wordCount,
      chapterCount: novel.chapterCount,
      latestChapterTitle: novel.latestChapterTitle,
      lastUpdateTime: novel.lastUpdateTime,
      isFinished: novel.isFinished,
      isVip: novel.isVip,
      isHot: novel.isHot,
    );
  }

  factory NovelSimpleModel.fromJson(Map<String, dynamic> json) {
    return NovelSimpleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      authorName: json['author_name'] as String,
      coverUrl: json['cover_url'] as String?,
      categoryName: json['category_name'] as String?,
      status: NovelStatus.fromValue(json['status'] as int?),
      wordCount: json['word_count'] as int? ?? 0,
      chapterCount: json['chapter_count'] as int? ?? 0,
      latestChapterTitle: json['latest_chapter_title'] as String?,
      lastUpdateTime: json['last_update_time'] != null
          ? DateTime.parse(json['last_update_time'] as String)
          : null,
      isFinished: json['is_finished'] as bool? ?? false,
      isVip: json['is_vip'] as bool? ?? false,
      isHot: json['is_hot'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author_name': authorName,
      'cover_url': coverUrl,
      'category_name': categoryName,
      'status': status.value,
      'word_count': wordCount,
      'chapter_count': chapterCount,
      'latest_chapter_title': latestChapterTitle,
      'last_update_time': lastUpdateTime?.toIso8601String(),
      'is_finished': isFinished,
      'is_vip': isVip,
      'is_hot': isHot,
    };
  }

  /// 格式化字数显示
  String get formattedWordCount {
    if (wordCount < 10000) {
      return '${wordCount}字';
    } else {
      return '${(wordCount / 10000).toStringAsFixed(1)}万字';
    }
  }

  /// 更新状态描述
  String get updateStatusText {
    if (isFinished) return '已完结';
    
    if (lastUpdateTime == null) return '未知';
    
    final now = DateTime.now();
    final diff = now.difference(lastUpdateTime!);
    
    if (diff.inDays == 0) {
      return '今日更新';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前更新';
    } else {
      return '${(diff.inDays / 7).floor()}周前更新';
    }
  }

  @override
  List<Object?> get props => [
        id,
        title,
        authorName,
        coverUrl,
        categoryName,
        status,
        wordCount,
        chapterCount,
        latestChapterTitle,
        lastUpdateTime,
        isFinished,
        isVip,
        isHot,
      ];

  @override
  String toString() {
    return 'NovelSimpleModel{id: $id, title: $title, author: $authorName}';
  }
}