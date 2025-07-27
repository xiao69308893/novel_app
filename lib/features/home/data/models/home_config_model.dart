// 首页配置数据模型
import '../../domain/entities/home_config.dart';

class HomeSectionModel extends HomeSection {
  const HomeSectionModel({
    required super.id,
    required super.title,
    required super.type,
    super.config,
    super.sort,
    super.isVisible,
  });

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      config: json['config'] as Map<String, dynamic>? ?? {},
      sort: json['sort'] as int? ?? 0,
      isVisible: json['is_visible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'config': config,
      'sort': sort,
      'is_visible': isVisible,
    };
  }

  HomeSection toEntity() {
    return HomeSection(
      id: id,
      title: title,
      type: type,
      config: config,
      sort: sort,
      isVisible: isVisible,
    );
  }
}

class HomeConfigModel extends HomeConfig {
  const HomeConfigModel({
    required super.version,
    super.sections,
    super.globalConfig,
    required super.updatedAt,
  });

  factory HomeConfigModel.fromJson(Map<String, dynamic> json) {
    return HomeConfigModel(
      version: json['version'] as String,
      sections: (json['sections'] as List?)
          ?.map((section) => HomeSectionModel.fromJson(section as Map<String, dynamic>))
          .cast<HomeSection>()
          .toList() ?? [],
      globalConfig: json['global_config'] as Map<String, dynamic>? ?? {},
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'sections': sections.map((section) {
        if (section is HomeSectionModel) {
          return section.toJson();
        } else {
          return HomeSectionModel(
            id: section.id,
            title: section.title,
            type: section.type,
            config: section.config,
            sort: section.sort,
            isVisible: section.isVisible,
          ).toJson();
        }
      }).toList(),
      'global_config': globalConfig,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  HomeConfig toEntity() {
    return HomeConfig(
      version: version,
      sections: sections,
      globalConfig: globalConfig,
      updatedAt: updatedAt,
    );
  }
}
