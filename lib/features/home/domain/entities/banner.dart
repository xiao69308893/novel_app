// 轮播图实体
import 'package:equatable/equatable.dart';

enum BannerType {
  novel(0, '小说推荐'),
  activity(1, '活动推广'),
  announcement(2, '公告'),
  external(3, '外部链接');

  const BannerType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static BannerType fromValue(int? value) => BannerType.values.firstWhere(
      (BannerType t) => t.value == value,
      orElse: () => BannerType.novel,
    );
}

class Banner extends Equatable {

  const Banner({
    required this.id,
    required this.title,
    required this.imageUrl, required this.createdAt, this.subtitle,
    this.type = BannerType.novel,
    this.targetId,
    this.targetUrl,
    this.sort = 0,
    this.isActive = true,
    this.startTime,
    this.endTime,
  });
  final String id;
  final String title;
  final String? subtitle;
  final String imageUrl;
  final BannerType type;
  final String? targetId; // 目标ID（小说ID、活动ID等）
  final String? targetUrl; // 目标链接
  final int sort;
  final bool isActive;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime createdAt;

  /// 是否在有效期内
  bool get isValid {
    if (!isActive) return false;
    
    final DateTime now = DateTime.now();
    if (startTime != null && now.isBefore(startTime!)) return false;
    if (endTime != null && now.isAfter(endTime!)) return false;
    
    return true;
  }

  @override
  List<Object?> get props => <Object?>[
    id, title, subtitle, imageUrl, type, targetId, 
    targetUrl, sort, isActive, startTime, endTime, createdAt
  ];
}