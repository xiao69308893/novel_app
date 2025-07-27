// 轮播图数据模型
import '../../../domain/entities/banner.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.title,
    super.subtitle,
    required super.imageUrl,
    super.type,
    super.targetId,
    super.targetUrl,
    super.sort,
    super.isActive,
    super.startTime,
    super.endTime,
    required super.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      imageUrl: json['image_url'] as String,
      type: BannerType.fromValue(json['type'] as int?),
      targetId: json['target_id'] as String?,
      targetUrl: json['target_url'] as String?,
      sort: json['sort'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : null,
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'image_url': imageUrl,
      'type': type.value,
      'target_id': targetId,
      'target_url': targetUrl,
      'sort': sort,
      'is_active': isActive,
      'start_time': startTime?.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Banner toEntity() {
    return Banner(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      type: type,
      targetId: targetId,
      targetUrl: targetUrl,
      sort: sort,
      isActive: isActive,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
    );
  }
}