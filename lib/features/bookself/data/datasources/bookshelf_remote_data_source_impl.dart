import 'package:dio/dio.dart';
import 'package:novel_app/core/network/api_response.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../bookself/domain/entities/reading_history.dart';

/// 书架远程数据源接口
abstract class BookshelfRemoteDataSource {
  /// 获取收藏小说列表
  Future<List<NovelModel>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? filterBy,
  });

  /// 获取推荐小说列表
  Future<List<NovelModel>> getRecommendedNovels({
    int page = 1,
    int limit = 20,
  });

  /// 添加到收藏
  Future<void> addToFavorites({required String novelId});

  /// 从收藏中移除
  Future<void> removeFromFavorites({required String novelId});

  /// 检查收藏状态
  Future<bool> checkFavoriteStatus({required String novelId});

  /// 批量添加收藏
  Future<void> batchAddToFavorites({required List<String> novelIds});

  /// 批量移除收藏
  Future<void> batchRemoveFromFavorites({required List<String> novelIds});

  /// 获取用户资料
  Future<UserModel> getUserProfile();

  /// 更新用户资料
  Future<UserModel> updateUserProfile(UserModel user);

  /// 用户签到
  Future<Map<String, dynamic>> checkIn();

  /// 获取签到状态
  Future<bool> getCheckInStatus();

  /// 导出用户数据
  Future<String> exportUserData();

  /// 导入用户数据
  Future<void> importUserData({required String dataPath});

  /// 同步数据
  Future<void> syncData();

  /// 删除账户
  Future<void> deleteAccount();

  /// 修改密码
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
  
  /// 获取阅读历史
  Future<List<ReadingHistory>> getReadingHistory({
    int page = 1,
    int limit = 20,
  });
  
  /// 添加阅读历史
  Future<void> addReadingHistory({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  });
  
  /// 清理阅读历史
  Future<void> clearReadingHistory({List<String>? novelIds});
  
  /// 获取用户统计
  Future<UserStats> getUserStats();
  
  /// 获取用户设置
  Future<UserSettings> getUserSettings();
  
  /// 更新用户设置
  Future<void> updateUserSettings(UserSettings settings);
  
  /// 搜索收藏小说
  Future<List<NovelModel>> searchFavoriteNovels({
    required String keyword,
    int page = 1,
    int limit = 20,
  });
  
  /// 获取最近阅读小说
  Future<List<NovelModel>> getRecentlyReadNovels({int limit = 10});
}

/// 书架远程数据源实现
class BookshelfRemoteDataSourceImpl implements BookshelfRemoteDataSource {

  const BookshelfRemoteDataSourceImpl({
    required this.apiClient,
  });
  final ApiClient apiClient;

  @override
  Future<List<NovelModel>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? filterBy,
  }) async {
    try {
      final Map<String, String> queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sortBy != null) 'sort_by': sortBy,
        if (filterBy != null) 'filter_by': filterBy,
      };

      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>(
        '/user/favorites',
        queryParameters: queryParams,
      );

      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final List<dynamic> novelsJson = (data?['list'] as List<dynamic>?) ?? <dynamic>[];
      return novelsJson.map((dynamic json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelModel>> getRecommendedNovels({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, String> queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>(
        '/novels/recommended',
        queryParameters: queryParams,
      );

      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final List<dynamic> novelsJson = (data?['list'] as List<dynamic>?) ?? <dynamic>[];
      return novelsJson.map((dynamic json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> addToFavorites({required String novelId}) async {
    try {
      await apiClient.post(
        '/user/favorites',
        data: <String, String>{'novel_id': novelId},
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> removeFromFavorites({required String novelId}) async {
    try {
      await apiClient.delete('/user/favorites/$novelId');
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> checkFavoriteStatus({required String novelId}) async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/favorites/$novelId/status');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      return (data?['is_favorite'] as bool?) ?? false;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> batchAddToFavorites({required List<String> novelIds}) async {
    try {
      await apiClient.post(
        '/user/favorites/batch',
        data: <String, Object>{'novel_ids': novelIds, 'action': 'add'},
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> batchRemoveFromFavorites({required List<String> novelIds}) async {
    try {
      await apiClient.post(
        '/user/favorites/batch',
        data: <String, Object>{'novel_ids': novelIds, 'action': 'remove'},
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/profile');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppError.unknown('Invalid response data');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      final ApiResponse response = await apiClient.put(
        '/user/profile',
        data: user.toJson(),
      );
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppError.unknown('Invalid response data');
      }
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> checkIn() async {
    try {
      final ApiResponse response = await apiClient.post('/user/checkin');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppError.unknown('Invalid response data');
      }
      return data;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> getCheckInStatus() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/checkin/status');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      return (data?['checked_in'] as bool?) ?? false;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<String> exportUserData() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/data/export');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final String? downloadUrl = data?['download_url'] as String?;
      if (downloadUrl == null) {
        throw AppError.unknown('Invalid response data');
      }
      return downloadUrl;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> importUserData({required String dataPath}) async {
    try {
      await apiClient.post(
        '/user/data/import',
        data: <String, String>{'data_path': dataPath},
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> syncData() async {
    try {
      await apiClient.post('/user/data/sync');
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await apiClient.delete('/user/account');
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.put(
        '/user/password',
        data: <String, String>{
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<ReadingHistory>> getReadingHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, String> queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>(
        '/user/reading-history',
        queryParameters: queryParams,
      );

      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final List<dynamic> historyJson = (data?['list'] as List<dynamic>?) ?? <dynamic>[];
      return historyJson.map((dynamic json) => ReadingHistory.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> addReadingHistory({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  }) async {
    try {
      await apiClient.post(
        '/user/reading-history',
        data: <String, Object>{
          'novel_id': novelId,
          'chapter_id': chapterId,
          'reading_time': readingTime,
          if (lastPosition != null) 'last_position': lastPosition,
        },
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> clearReadingHistory({List<String>? novelIds}) async {
    try {
      if (novelIds != null && novelIds.isNotEmpty) {
        // 删除指定小说的阅读历史
        await apiClient.delete(
          '/user/reading-history',
          data: <String, List<String>>{'novel_ids': novelIds},
        );
      } else {
        // 清空所有阅读历史
        await apiClient.delete('/user/reading-history/all');
      }
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<UserStats> getUserStats() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/stats');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppError.unknown('Invalid response data');
      }
      return UserStats.fromJson(data);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<UserSettings> getUserSettings() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/user/settings');
      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppError.unknown('Invalid response data');
      }
      return UserSettings.fromJson(data);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<void> updateUserSettings(UserSettings settings) async {
    try {
      await apiClient.put(
        '/user/settings',
        data: settings.toJson(),
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelModel>> searchFavoriteNovels({
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, String> queryParams = <String, String>{
        'keyword': keyword,
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>(
        '/user/favorites/search',
        queryParameters: queryParams,
      );

      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final List<dynamic> novelsJson = (data?['list'] as List<dynamic>?) ?? <dynamic>[];
      return novelsJson.map((dynamic json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelModel>> getRecentlyReadNovels({int limit = 10}) async {
    try {
      final Map<String, String> queryParams = <String, String>{
        'limit': limit.toString(),
      };

      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>(
        '/user/recently-read',
        queryParameters: queryParams,
      );

      final Map<String, dynamic>? data = response.data?['data'] as Map<String, dynamic>?;
      final List<dynamic> novelsJson = (data?['list'] as List<dynamic>?) ?? <dynamic>[];
      return novelsJson.map((dynamic json) => NovelModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }
}
