// 首页本地数据源
import 'dart:convert';
import '../../../../core/utils/preferences_helper.dart';
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
        final List<dynamic> bannersList = json.decode(bannersJson);
        return bannersList
            .map((bannerJson) => BannerModel.fromJson(bannerJson))
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
      final recommendationsJson = await PreferencesHelper.getString(_recommendationsKey);
      if (recommendationsJson != null) {
        final List<dynamic> recommendationsList = json.decode(recommendationsJson);
        return recommendationsList
            .map((recommendationJson) => RecommendationModel.fromJson(recommendationJson))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveRecommendations(List<RecommendationModel> recommendations) async {
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
        final List<dynamic> historyList = json.decode(historyJson);
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
}