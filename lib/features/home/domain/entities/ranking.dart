import 'package:equatable/equatable.dart';
import '../../../../shared/models/novel_model.dart';

enum RankingType {
  hot(0, '热门榜'),
  new_(1, '新书榜'),
  recommend(2, '推荐榜'),
  favorite(3, '收藏榜'),
  comment(4, '评论榜'),
  update(5, '更新榜'),
  complete(6, '完本榜');

  const RankingType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static RankingType fromValue(int? value) => RankingType.values.firstWhere(
      (RankingType t) => t.value == value,
      orElse: () => RankingType.hot,
    );
}

enum RankingPeriod {
  daily(0, '日榜'),
  weekly(1, '周榜'),
  monthly(2, '月榜'),
  total(3, '总榜');

  const RankingPeriod(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static RankingPeriod fromValue(int? value) => RankingPeriod.values.firstWhere(
      (RankingPeriod p) => p.value == value,
      orElse: () => RankingPeriod.weekly,
    );
}

class RankingItem extends Equatable { // 排名变化（正数上升，负数下降）

  const RankingItem({
    required this.rank,
    required this.novel,
    this.score,
    this.metric,
    this.change,
  });
  final int rank;
  final NovelSimpleModel novel;
  final int? score;
  final String? metric; // 排名指标（阅读量、收藏量等）
  final int? change;

  /// 排名变化显示
  String get changeDisplay {
    if (change == null) return '';
    if (change! > 0) return '+$change';
    if (change! < 0) return '$change';
    return '—';
  }

  /// 排名变化图标
  String get changeIcon {
    if (change == null) return '';
    if (change! > 0) return '↑';
    if (change! < 0) return '↓';
    return '—';
  }

  @override
  List<Object?> get props => <Object?>[rank, novel, score, metric, change];
}

class Ranking extends Equatable {

  const Ranking({
    required this.id,
    required this.title,
    required this.updatedAt, this.type = RankingType.hot,
    this.period = RankingPeriod.weekly,
    this.items = const <RankingItem>[],
  });
  final String id;
  final String title;
  final RankingType type;
  final RankingPeriod period;
  final List<RankingItem> items;
  final DateTime updatedAt;

  @override
  List<Object> get props => <Object>[id, title, type, period, items, updatedAt];
}
