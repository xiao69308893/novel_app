import 'package:equatable/equatable.dart';

class HomeSection extends Equatable {
  final String id;
  final String title;
  final String type; // banner, recommendation, ranking, category
  final Map<String, dynamic> config;
  final int sort;
  final bool isVisible;

  const HomeSection({
    required this.id,
    required this.title,
    required this.type,
    this.config = const {},
    this.sort = 0,
    this.isVisible = true,
  });

  @override
  List<Object> get props => [id, title, type, config, sort, isVisible];
}

class HomeConfig extends Equatable {
  final String version;
  final List<HomeSection> sections;
  final Map<String, dynamic> globalConfig;
  final DateTime updatedAt;

  const HomeConfig({
    required this.version,
    this.sections = const [],
    this.globalConfig = const {},
    required this.updatedAt,
  });

  /// 获取可见的区块
  List<HomeSection> get visibleSections {
    return sections.where((section) => section.isVisible).toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
  }

  @override
  List<Object> get props => [version, sections, globalConfig, updatedAt];
}