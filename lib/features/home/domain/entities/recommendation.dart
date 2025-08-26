// 推荐实体
import 'package:equatable/equatable.dart';
import '../../../../shared/models/novel_model.dart';

enum RecommendationType {
  hot(0, '热门推荐'),
  new_(1, '新书推荐'),
  editor(2, '编辑推荐'),
  personalized(3, '个性化推荐'),
  category(4, '分类推荐'),
  author(5, '作者推荐');

  const RecommendationType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static RecommendationType fromValue(int? value) => RecommendationType.values.firstWhere(
      (RecommendationType t) => t.value == value,
      orElse: () => RecommendationType.hot,
    );
}

class Recommendation extends Equatable {

  const Recommendation({
    required this.id,
    required this.title,
    required this.createdAt, required this.updatedAt, this.description,
    this.type = RecommendationType.hot,
    this.novels = const <NovelSimpleModel>[],
    this.coverUrl,
    this.sort = 0,
    this.isActive = true,
  });
  final String id;
  final String title;
  final String? description;
  final RecommendationType type;
  final List<NovelSimpleModel> novels;
  final String? coverUrl;
  final int sort;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => <Object?>[
    id, title, description, type, novels, coverUrl,
    sort, isActive, createdAt, updatedAt
  ];
}