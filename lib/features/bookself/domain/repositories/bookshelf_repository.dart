import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../entities/favorite_novel.dart';
import '../entities/reading_history.dart';
import '../entities/user_profile.dart';

/// 书架仓储接口
abstract class BookshelfRepository {
  /// 获取用户档案
  Future<Either<Failure, UserProfile>> getUserProfile();
  
  /// 更新用户信息
  Future<Either<Failure, UserModel>> updateUserProfile(UserModel user);
  
  /// 获取收藏列表
  Future<Either<Failure, List<FavoriteNovel>>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
  });
  
  /// 添加收藏
  Future<Either<Failure, void>> addToFavorites(String novelId);
  
  /// 移除收藏
  Future<Either<Failure, void>> removeFromFavorites(String novelId);
  
  /// 检查是否已收藏
  Future<Either<Failure, bool>> isFavorite(String novelId);
  
  /// 批量操作收藏
  Future<Either<Failure, void>> batchFavoriteOperation({
    List<String>? addIds,
    List<String>? removeIds,
  });
  
  /// 获取阅读历史
  Future<Either<Failure, List<ReadingHistory>>> getReadingHistory({
    int page = 1,
    int limit = 20,
  });
  
  /// 清空阅读历史
  Future<Either<Failure, void>> clearReadingHistory();
  
  /// 删除单个历史记录
  Future<Either<Failure, void>> deleteHistoryItem(String historyId);
  
  /// 获取书签列表
  Future<Either<Failure, List<BookmarkModel>>> getBookmarks({
    String? novelId,
    int page = 1,
    int limit = 20,
  });
  
  /// 添加书签
  Future<Either<Failure, BookmarkModel>> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
  });
  
  /// 删除书签
  Future<Either<Failure, void>> deleteBookmark(String bookmarkId);
  
  /// 获取用户统计数据
  Future<Either<Failure, UserStats>> getUserStats();
  
  /// 更新用户设置
  Future<Either<Failure, void>> updateUserSettings(UserSettings settings);
  
  /// 签到
  Future<Either<Failure, Map<String, dynamic>>> checkIn();
  
  /// 获取签到状态
  Future<Either<Failure, bool>> getCheckInStatus();
}
