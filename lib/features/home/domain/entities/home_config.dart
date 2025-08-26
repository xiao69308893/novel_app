import 'package:equatable/equatable.dart';

class HomeSection extends Equatable {

  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    this.config = const <String, dynamic>{},
    this.sort = 0,
    this.isVisible = true,
  });
  final String id;
  final String title;
  final String type; // banner, recommendation, ranking, category
  final Map<String, dynamic> config;
  final int sort;
  final bool isVisible;

  @override
  List<Object> get props => <Object>[id, title, type, config, sort, isVisible];
}

class HomeConfig extends Equatable {

  const HomeConfig({
    required this.version,
    required this.updatedAt, this.sections = const <HomeSection>[],
    this.globalConfig = const <String, dynamic>{},
  });
  final String version;
  final List<HomeSection> sections;
  final Map<String, dynamic> globalConfig;
  final DateTime updatedAt;

  /// 获取可见的区块
  List<HomeSection> get visibleSections => sections.where((HomeSection section) => section.isVisible).toList()
      ..sort((HomeSection a, HomeSection b) => a.sort.compareTo(b.sort));

  @override
  List<Object> get props => <Object>[version, sections, globalConfig, updatedAt];
}