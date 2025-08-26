// 推荐内容数据模型
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/recommendation.dart';

class RecommendationModel extends Recommendation {
  const RecommendationModel({
    required super.id,
    required super.title,
    required super.createdAt, required super.updatedAt, super.description,
    super.type,
    super.novels,
    super.coverUrl,
    super.sort,
    super.isActive,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) => RecommendationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: RecommendationType.fromValue(json['type'] as int?),
      novels: (json['novels'] as List?)
          ?.map((novel) => NovelSimpleModel.fromJson(novel as Map<String, dynamic>))
          .cast<NovelSimpleModel>()
          .toList() ?? <NovelSimpleModel>[],
      coverUrl: json['cover_url'] as String?,
      sort: json['sort'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'type': type.value,
      'novels': novels.map((NovelSimpleModel novel) => novel.toJson()).toList(),
      'cover_url': coverUrl,
      'sort': sort,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

  Recommendation toEntity() => Recommendation(
      id: id,
      title: title,
      description: description,
      type: type,
      novels: novels,
      coverUrl: coverUrl,
      sort: sort,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
}