// 首页远程数据源
import 'package:dio/dio.dart';
import 'package:novel_app/core/network/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/novel_model.dart';
import '../models/banner_model.dart';
import '../models/recommendation_model.dart';
import '../models/ranking_model.dart';
import '../models/home_config_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeConfigModel> getHomeConfig();
  Future<List<BannerModel>> getBanners();
  Future<List<RecommendationModel>> getRecommendations({
    String? type,
    int page = 1,
    int limit = 10,
  });
  Future<RankingModel> getRanking({
    required String type,
    String period = 'weekly',
    int limit = 50,
  });
  Future<List<NovelSimpleModel>> getHotNovels({
    int page = 1,
    int limit = 20,
  });
  Future<List<NovelSimpleModel>> getNewNovels({
    int page = 1,
    int limit = 20,
  });
  Future<List<NovelSimpleModel>> getEditorRecommendations({
    int page = 1,
    int limit = 20,
  });
  Future<List<NovelSimpleModel>> getPersonalizedRecommendations({
    int page = 1,
    int limit = 20,
  });
  Future<List<NovelSimpleModel>> getCategoryHotNovels({
    required String categoryId,
    int page = 1,
    int limit = 20,
  });
  Future<List<NovelSimpleModel>> searchNovels({
    required String keyword,
    String? categoryId,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  });
  Future<List<String>> getHotSearchKeywords();
  Future<List<String>> getSearchSuggestions(String keyword);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {

  HomeRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<HomeConfigModel> getHomeConfig() async {
    try {
      final ApiResponse response = await apiClient.get('/home/config');
      return HomeConfigModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final ApiResponse response = await apiClient.get('/home/banners');
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => BannerModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<RecommendationModel>> getRecommendations({
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/home/recommendations',
        queryParameters: <String, dynamic>{
          if (type != null) 'type': type,
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => RecommendationModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<RankingModel> getRanking({
    required String type,
    String period = 'weekly',
    int limit = 50,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/home/ranking',
        queryParameters: <String, dynamic>{
          'type': type,
          'period': period,
          'limit': limit,
        },
      );
      return RankingModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getHotNovels({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/hot',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getNewNovels({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/new',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getEditorRecommendations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/editor-recommendations',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getPersonalizedRecommendations({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/personalized',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getCategoryHotNovels({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/category/$categoryId/hot',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> searchNovels({
    required String keyword,
    String? categoryId,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/novels/search',
        queryParameters: <String, dynamic>{
          'keyword': keyword,
          if (categoryId != null) 'category_id': categoryId,
          if (status != null) 'status': status,
          if (sortBy != null) 'sort_by': sortBy,
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => NovelSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<String>> getHotSearchKeywords() async {
    try {
      final ApiResponse response = await apiClient.get('/search/hot-keywords');
      final List<dynamic> data = response.data['data'] as List<dynamic>;

      return data.cast<String>();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(String keyword) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/search/suggestions',
        queryParameters: <String, dynamic>{'keyword': keyword},
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;

      return data.cast<String>();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }
}