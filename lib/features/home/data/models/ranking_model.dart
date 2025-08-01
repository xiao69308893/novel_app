// 排行榜数据模型
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/ranking.dart';

class RankingItemModel extends RankingItem {
  const RankingItemModel({
    required super.rank,
    required super.novel,
    super.score,
    super.metric,
    super.change,
  });

  factory RankingItemModel.fromJson(Map<String, dynamic> json) {
    return RankingItemModel(
      rank: json['rank'] as int,
      novel: NovelSimpleModel.fromJson(json['novel'] as Map<String, dynamic>),
      score: json['score'] as int?,
      metric: json['metric'] as String?,
      change: json['change'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'novel': novel.toJson(),
      'score': score,
      'metric': metric,
      'change': change,
    };
  }

  RankingItem toEntity() {
    return RankingItem(
      rank: rank,
      novel: novel,
      score: score,
      metric: metric,
      change: change,
    );
  }
}

class RankingModel extends Ranking {
  const RankingModel({
    required super.id,
    required super.title,
    super.type,
    super.period,
    super.items,
    required super.updatedAt,
  });

  factory RankingModel.fromJson(Map<String, dynamic> json) {
    return RankingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: RankingType.fromValue(json['type'] as int?),
      period: RankingPeriod.fromValue(json['period'] as int?),
      items: (json['items'] as List?)
          ?.map((item) => RankingItemModel.fromJson(item as Map<String, dynamic>))
          .cast<RankingItem>()
          .toList() ?? [],
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.value,
      'period': period.value,
      'items': items.map((item) {
        if (item is RankingItemModel) {
          return item.toJson();
        } else {
          // 如果不是Model类型，转换为Model再转JSON
          return RankingItemModel(
            rank: item.rank,
            novel: item.novel,
            score: item.score,
            metric: item.metric,
            change: item.change,
          ).toJson();
        }
      }).toList(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Ranking toEntity() {
    return Ranking(
      id: id,
      title: title,
      type: type,
      period: period,
      items: items,
      updatedAt: updatedAt,
    );
  }
}