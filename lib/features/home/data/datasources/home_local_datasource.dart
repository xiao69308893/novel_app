// 首页本地数据源
import 'dart:convert';
import '../../../../core/utils/preferences_helper.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/recommendation.dart';
import '../models/home_config_model.dart';
import '../models/banner_model.dart';
import '../models/recommendation_model.dart';

abstract class HomeLocalDataSource {
  Future<HomeConfigModel?> getHomeConfig();
  Future<void> saveHomeConfig(HomeConfigModel config);
  Future<List<BannerModel>?> getBanners();
  Future<void> saveBanners(List<BannerModel> banners);
  Future<List<RecommendationModel>?> getRecommendations();
  Future<void> saveRecommendations(List<RecommendationModel> recommendations);
  Future<List<String>?> getSearchHistory();
  Future<void> saveSearchHistory(List<String> history);
  Future<void> addSearchHistory(String keyword);
  Future<void> clearSearchHistory();
  Future<void> clearCache();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  static const String _homeConfigKey = 'home_config';
  static const String _bannersKey = 'home_banners';
  static const String _recommendationsKey = 'home_recommendations';
  static const String _searchHistoryKey = 'search_history';

  @override
  Future<HomeConfigModel?> getHomeConfig() async {
    try {
      final configJson = await PreferencesHelper.getString(_homeConfigKey);
      if (configJson != null) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        return HomeConfigModel.fromJson(configMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveHomeConfig(HomeConfigModel config) async {
    final configJson = json.encode(config.toJson());
    await PreferencesHelper.setString(_homeConfigKey, configJson);
  }

  @override
  Future<List<BannerModel>?> getBanners() async {
    try {
      final bannersJson = await PreferencesHelper.getString(_bannersKey);
      if (bannersJson != null) {
        final List<dynamic> bannersList = json.decode(bannersJson) as List<dynamic>;
        return bannersList
            .map((bannerJson) => BannerModel.fromJson(bannerJson as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveBanners(List<BannerModel> banners) async {
    final bannersJson = json.encode(
      banners.map((banner) => banner.toJson()).toList(),
    );
    await PreferencesHelper.setString(_bannersKey, bannersJson);
  }

  @override
  Future<List<RecommendationModel>?> getRecommendations() async {
    try {
      final recommendationsJson =
          await PreferencesHelper.getString(_recommendationsKey);
      if (recommendationsJson != null) {
        final List<dynamic> recommendationsList =
            json.decode(recommendationsJson) as List<dynamic>;
        return recommendationsList
            .map((recommendationJson) =>
                RecommendationModel.fromJson(recommendationJson as Map<String, dynamic>))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRecommendations(
      List<RecommendationModel> recommendations) async {
    final recommendationsJson = json.encode(
      recommendations.map((recommendation) => recommendation.toJson()).toList(),
    );
    await PreferencesHelper.setString(_recommendationsKey, recommendationsJson);
  }

  @override
  Future<List<String>?> getSearchHistory() async {
    try {
      final historyJson = await PreferencesHelper.getString(_searchHistoryKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson) as List<dynamic>;
        return historyList.cast<String>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveSearchHistory(List<String> history) async {
    final historyJson = json.encode(history);
    await PreferencesHelper.setString(_searchHistoryKey, historyJson);
  }

  @override
  Future<void> addSearchHistory(String keyword) async {
    final history = await getSearchHistory() ?? [];

    // 移除重复项
    history.remove(keyword);

    // 添加到开头
    history.insert(0, keyword);

    // 限制历史记录数量
    if (history.length > 20) {
      history.removeRange(20, history.length);
    }

    await saveSearchHistory(history);
  }

  @override
  Future<void> clearSearchHistory() async {
    await PreferencesHelper.remove(_searchHistoryKey);
  }

  @override
  Future<void> clearCache() async {
    await PreferencesHelper.remove(_homeConfigKey);
    await PreferencesHelper.remove(_bannersKey);
    await PreferencesHelper.remove(_recommendationsKey);
  }

  /// 初始化模拟数据（用于测试）
  Future<void> initMockData() async {
    // 模拟首页配置
    final mockConfig = HomeConfigModel(
      version: '1.0.0',
      sections: [
        HomeSectionModel(
          id: 'banner',
          title: '轮播图',
          type: 'banner',
          config: {'enabled': true},
          sort: 1,
          isVisible: true,
        ),
        HomeSectionModel(
          id: 'recommendation',
          title: '推荐内容',
          type: 'recommendation',
          config: {'type': 'editor'},
          sort: 2,
          isVisible: true,
        ),
      ],
      globalConfig: {
        'appName': 'Novel App',
        'bannerEnabled': true,
        'recommendationEnabled': true,
        'maxBanners': 5,
        'maxRecommendations': 10,
        'refreshInterval': 300,
        'cacheExpiry': 3600,
        'features': ['banner', 'recommendation', 'ranking'],
        'theme': {
          'primaryColor': '#2196F3',
          'accentColor': '#FF9800',
        },
      },
      updatedAt: DateTime.now(),
    );
    await saveHomeConfig(mockConfig);

    // 模拟轮播图数据
    final mockBanners = [
      BannerModel(
        id: '1',
        title: '热门小说推荐',
        imageUrl: 'https://b0.bdstatic.com/e4b42c67e0f6b52ad6145395acae609a.jpg',
        targetUrl: '/novels/hot',
        sort: 1,
        isActive: true,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      ),
      BannerModel(
        id: '2',
        title: '新书上架',
        imageUrl: 'https://redimage.xhscdn.com/1000g00825pfu1c2fm00g5nm58etg8ldk27s0n6o?imageView2/1/w/1372/h/1829/format/webp',
        targetUrl: '/novels/new',
        sort: 2,
        isActive: true,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 30)),
        createdAt: DateTime.now(),
      ),
    ];
    await saveBanners(mockBanners);

    // 模拟推荐数据
    final mockRecommendations = [
      RecommendationModel(
        id: '1',
        title: '编辑推荐',
        type: RecommendationType.editor,
        novels: [
          NovelSimpleModel.fromJson({
            'id': '1',
            'title': '斗破苍穹',
            'author_name': '天蚕土豆',
            'cover_url': 'https://b0.bdstatic.com/9dd17fb2cd2de717fc9ac9040c1a5bff.jpg',
            'category_name': '玄幻',
            'status': 1, // 已完结
            'word_count': 5370000,
          }),
          NovelSimpleModel.fromJson({
            'id': '2',
            'title': '武动乾坤',
            'author_name': '天蚕土豆',
            'cover_url': 'https://b0.bdstatic.com/4607a69dd5705ae0360180b8d9aaffff.jpg',
            'category_name': '玄幻',
            'status': 1, // 已完结
            'word_count': 4890000,
          }),
        ],
        sort: 1,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      RecommendationModel(
        id: '2',
        title: '热门榜单',
        type: RecommendationType.hot,
        novels: [
          NovelSimpleModel.fromJson({
            'id': '3',
            'title': '完美世界',
            'author_name': '辰东',
            'cover_url': 'https://b0.bdstatic.com/e4b42c67e0f6b52ad6145395acae609a.jpg',
            'category_name': '玄幻',
            'status': 1, // 已完结
            'word_count': 6780000,
          }),
          NovelSimpleModel.fromJson({
            'id': '4',
            'title': '遮天',
            'author_name': '辰东',
            'cover_url': 'https://redimage.xhscdn.com/1000g00825pfu1c2fm00g5nm58etg8ldk27s0n6o?imageView2/1/w/1372/h/1829/format/webp',
            'category_name': '玄幻',
            'status': 1, // 已完结
            'word_count': 6900000,
          }),
        ],
        sort: 2,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    try {
      print('开始保存推荐数据，数量: ${mockRecommendations.length}');
      await saveRecommendations(mockRecommendations);
      print('推荐数据保存成功');

      // 验证保存结果
      final savedRecommendations = await getRecommendations();
      print('验证保存结果，获取到的推荐数据数量: ${savedRecommendations?.length ?? 0}');
    } catch (e) {
      print('保存推荐数据时出错: $e');
    }
  }
}
