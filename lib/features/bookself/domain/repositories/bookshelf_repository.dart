import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../entities/favorite_novel.dart';
import '../entities/reading_history.dart';
import '../entities/user_profile.dart';

/// 书架仓储接口
abstract class BookshelfRepository {
  /// 获取用户档案
  Future<Either<AppError, UserProfile>> getUserProfile();
  
  /// 更新用户信息
  Future<Either<AppError, UserModel>> updateUserProfile(UserModel user);
  
  /// 获取收藏列表
  Future<Either<AppError, List<FavoriteNovel>>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
  });
  
  /// 添加收藏
  Future<Either<AppError, void>> addToFavorites(String novelId);
  
  /// 移除收藏
  Future<Either<AppError, void>> removeFromFavorites(String novelId);
  
  /// 检查是否已收藏
  Future<Either<AppError, bool>> isFavorite(String novelId);
  
  /// 批量操作收藏
  Future<Either<AppError, void>> batchFavoriteOperation({
    List<String>? addIds,
    List<String>? removeIds,
  });
  
  /// 获取阅读历史
  Future<Either<AppError, List<ReadingHistory>>> getReadingHistory({
    int page = 1,
    int limit = 20,
  });
  
  /// 清空阅读历史
  Future<Either<AppError, void>> clearReadingHistory();
  
  /// 删除单个历史记录
  Future<Either<AppError, void>> deleteHistoryItem(String historyId);
  
  /// 获取书签列表
  Future<Either<AppError, List<BookmarkModel>>> getBookmarks({
    String? novelId,
    int page = 1,
    int limit = 20,
  });
  
  /// 添加书签
  Future<Either<AppError, BookmarkModel>> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
  });
  
  /// 删除书签
  Future<Either<AppError, void>> deleteBookmark(String bookmarkId);
  
  /// 获取用户统计数据
  Future<Either<AppError, UserStats>> getUserStats();
  
  /// 更新用户设置
  Future<Either<AppError, void>> updateUserSettings(UserSettings settings);
  
  /// 签到
  Future<Either<AppError, Map<String, dynamic>>> checkIn();
  
  /// 获取签到状态
  Future<Either<AppError, bool>> getCheckInStatus();
  
  /// 检查收藏状态
  Future<Either<AppError, bool>> checkFavoriteStatus({required String novelId});
  
  /// 批量添加收藏
  Future<Either<AppError, void>> batchAddToFavorites({required List<String> novelIds});
  
  /// 批量移除收藏
  Future<Either<AppError, void>> batchRemoveFromFavorites({required List<String> novelIds});
  
  /// 添加阅读历史
  Future<Either<AppError, void>> addReadingHistory({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  });
  
  /// 获取用户设置
  Future<Either<AppError, UserSettings>> getUserSettings();
  
  /// 搜索收藏小说
  Future<Either<AppError, List<NovelModel>>> searchFavoriteNovels({
    required String keyword,
    int page = 1,
    int limit = 20,
  });
  
  /// 获取最近阅读小说
  Future<Either<AppError, List<NovelModel>>> getRecentlyReadNovels({int limit = 10});
  
  /// 获取推荐小说
  Future<Either<AppError, List<NovelModel>>> getRecommendedNovels({
    int page = 1,
    int limit = 20,
    String? category,
  });
  
  /// 同步数据
  Future<Either<AppError, void>> syncData();
  
  /// 导出用户数据
  Future<Either<AppError, String>> exportUserData();
  
  /// 导入用户数据
  Future<Either<AppError, void>> importUserData({required String dataPath});
  
  /// 删除账户
  Future<Either<AppError, void>> deleteAccount();
  
  /// 修改密码
  Future<Either<AppError, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}
