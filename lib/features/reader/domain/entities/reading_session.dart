import 'package:equatable/equatable.dart';
import '../../../../shared/models/chapter_model.dart';

/// 阅读会话实体
class ReadingSession extends Equatable {
  /// 会话ID
  final String id;
  
  /// 用户ID
  final String userId;
  
  /// 小说ID
  final String novelId;
  
  /// 当前章节
  final ChapterModel currentChapter;
  
  /// 分页内容列表
  final List<String> pages;
  
  /// 当前页码（从0开始）
  final int currentPage;
  
  /// 开始阅读时间
  final DateTime startTime;
  
  /// 最后更新时间
  final DateTime? lastUpdateTime;
  
  /// 是否自动翻页
  final bool isAutoPage;
  
  /// 阅读进度百分比
  final double progressPercent;

  const ReadingSession({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.currentChapter,
    required this.pages,
    this.currentPage = 0,
    required this.startTime,
    this.lastUpdateTime,
    this.isAutoPage = false,
    this.progressPercent = 0.0,
  });

  /// 获取当前页内容
  String get currentPageContent {
    if (pages.isEmpty || currentPage < 0 || currentPage >= pages.length) {
      return '';
    }
    return pages[currentPage];
  }

  /// 是否有下一页
  bool get hasNextPage => currentPage < pages.length - 1;

  /// 是否有上一页
  bool get hasPreviousPage => currentPage > 0;

  /// 总页数
  int get totalPages => pages.length;

  /// 阅读时长（分钟）
  int get readingDurationMinutes {
    final endTime = lastUpdateTime ?? DateTime.now();
    return endTime.difference(startTime).inMinutes;
  }

  /// 章节阅读进度百分比
  double get chapterProgressPercent {
    if (pages.isEmpty) return 0.0;
    return (currentPage + 1) / pages.length;
  }

  /// 是否在当前位置有书签
  bool get hasBookmarkAtCurrentPosition {
    // 这里需要根据实际的书签数据来判断
    // 暂时返回false，实际使用时需要传入书签列表进行判断
    return false;
  }

  /// 复制并修改会话
  ReadingSession copyWith({
    String? id,
    String? userId,
    String? novelId,
    ChapterModel? currentChapter,
    List<String>? pages,
    int? currentPage,
    DateTime? startTime,
    DateTime? lastUpdateTime,
    bool? isAutoPage,
    double? progressPercent,
  }) {
    return ReadingSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      novelId: novelId ?? this.novelId,
      currentChapter: currentChapter ?? this.currentChapter,
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
      startTime: startTime ?? this.startTime,
      lastUpdateTime: lastUpdateTime ?? this.lastUpdateTime,
      isAutoPage: isAutoPage ?? this.isAutoPage,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }

  /// 跳转到下一页
  ReadingSession nextPage() {
    if (!hasNextPage) return this;
    return copyWith(
      currentPage: currentPage + 1,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 跳转到上一页
  ReadingSession previousPage() {
    if (!hasPreviousPage) return this;
    return copyWith(
      currentPage: currentPage - 1,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 跳转到指定页
  ReadingSession jumpToPage(int page) {
    if (page < 0 || page >= pages.length) return this;
    return copyWith(
      currentPage: page,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 切换自动翻页状态
  ReadingSession toggleAutoPage() {
    return copyWith(
      isAutoPage: !isAutoPage,
      lastUpdateTime: DateTime.now(),
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'currentChapter': currentChapter.toMap(),
      'pages': pages,
      'currentPage': currentPage,
      'startTime': startTime.toIso8601String(),
      'lastUpdateTime': lastUpdateTime?.toIso8601String(),
      'isAutoPage': isAutoPage,
      'progressPercent': progressPercent,
    };
  }

  /// 从Map创建
  factory ReadingSession.fromMap(Map<String, dynamic> map) {
    return ReadingSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      novelId: map['novelId'] ?? '',
      currentChapter: ChapterModel.fromMap(map['currentChapter'] ?? {}),
      pages: List<String>.from(map['pages'] ?? []),
      currentPage: map['currentPage'] ?? 0,
      startTime: DateTime.parse(map['startTime'] ?? DateTime.now().toIso8601String()),
      lastUpdateTime: map['lastUpdateTime'] != null 
          ? DateTime.parse(map['lastUpdateTime'])
          : null,
      isAutoPage: map['isAutoPage'] ?? false,
      progressPercent: map['progressPercent']?.toDouble() ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    novelId,
    currentChapter,
    pages,
    currentPage,
    startTime,
    lastUpdateTime,
    isAutoPage,
    progressPercent,
  ];
}