import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../domain/entities/favorite_novel.dart';
import '../../domain/entities/reading_history.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/bookshelf_repository.dart';
import '../datasources/bookshelf_local_data_source_impl.dart';
import '../datasources/bookshelf_remote_data_source_impl.dart';

/// 书架仓储实现
class BookshelfRepositoryImpl implements BookshelfRepository {

  const BookshelfRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final BookshelfRemoteDataSource remoteDataSource;
  final BookshelfLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  ResultFuture<UserProfile> getUserProfile() async {
    try {
      // 优先从缓存获�?
      final UserModel? cachedUser = await localDataSource.getCachedUserProfile();
      
      if (cachedUser != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserProfileCache();
        }
        // �?UserModel 转换�?UserProfile
        final UserProfile userProfile = UserProfile(user: cachedUser);
        return Right(userProfile);
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final UserModel user = await remoteDataSource.getUserProfile();
        
        // 缓存用户信息
        await localDataSource.cacheUserProfile(user);
        
        // �?UserModel 转换�?UserProfile
        final UserProfile userProfile = UserProfile(user: user);
        return Right(userProfile);
      } else {
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取用户信息失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserModel> updateUserProfile(UserModel user) async {
    try {
      if (await networkInfo.isConnected) {
        final UserModel updatedUser = await remoteDataSource.updateUserProfile(UserModel(
          id: user.id,
          username: user.username,
          nickname: user.nickname,
          avatar: user.avatar,
          bio: user.bio,
          email: user.email,
          phone: user.phone,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        
        // 更新缓存
        await localDataSource.cacheUserProfile(updatedUser);
        
        return Right(updatedUser);
      } else {
        return Left(NoInternetError(message: '更新用户信息需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('更新用户信息失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<FavoriteNovel>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      // 如果是第一页，优先从缓存获�?
      if (page == 1) {
        final List<NovelModel>? cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null && cachedNovels.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateFavoritesCache(sortBy: sortBy);
          }
          // �?NovelModel 转换�?FavoriteNovel
          final List<FavoriteNovel> favoriteNovels = cachedNovels.map((NovelModel novel) => FavoriteNovel(
            id: novel.id,
            userId: 'current_user', // 这里应该从用户会话中获取
            novel: NovelSimpleModel.fromNovel(novel),
            createdAt: DateTime.now(), // 这里应该从缓存中获取实际时间
          )).toList();
          return Right(favoriteNovels);
        }
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final List<NovelModel> novels = await remoteDataSource.getFavoriteNovels(
          page: page,
          limit: limit,
          sortBy: sortBy,
        );

        // 如果是第一页，缓存数据
        if (page == 1) {
          await localDataSource.cacheFavoriteNovels(novels);
        }

        // �?NovelModel 转换�?FavoriteNovel
        final List<FavoriteNovel> favoriteNovels = novels.map((NovelModel novel) => FavoriteNovel(
          id: novel.id,
          userId: 'current_user',
          novel: NovelSimpleModel.fromNovel(novel),
          createdAt: DateTime.now(),
        )).toList();

        return Right(favoriteNovels);
      } else {
        // 没有网络，返回缓存数据或错误
        final List<NovelModel>? cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null) {
          final List<FavoriteNovel> favoriteNovels = cachedNovels.map((NovelModel novel) => FavoriteNovel(
            id: novel.id,
            userId: 'current_user',
            novel: NovelSimpleModel.fromNovel(novel),
            createdAt: DateTime.now(),
          )).toList();
          return Right(favoriteNovels);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取收藏列表失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> addToFavorites(String novelId) async {
    try {
      // 先更新本地缓存状�?
      await localDataSource.cacheFavoriteStatus(novelId, true);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.addToFavorites(novelId: novelId);
        
        // 清理收藏列表缓存，下次获取时会重新加�?
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状�?
      await localDataSource.cacheFavoriteStatus(novelId, false);
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('添加收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> removeFromFavorites(String novelId) async {
    try {
      // 先更新本地缓存状�?
      await localDataSource.cacheFavoriteStatus(novelId, false);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.removeFromFavorites(novelId: novelId);
        
        // 清理收藏列表缓存，下次获取时会重新加�?
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状�?
      await localDataSource.cacheFavoriteStatus(novelId, true);
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('取消收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> isFavorite(String novelId) async {
    try {
      // 优先从缓存获�?
      final bool? cachedStatus = await localDataSource.getCachedFavoriteStatus(novelId);
      
      // 如果有网络，异步更新缓存
      if (await networkInfo.isConnected) {
        try {
          final bool remoteStatus = await remoteDataSource.checkFavoriteStatus(novelId: novelId);
          
          // 更新缓存
          await localDataSource.cacheFavoriteStatus(novelId, remoteStatus);
          
          return Right(remoteStatus);
        } catch (e) {
          // 网络获取失败，使用缓存数�?
          if (cachedStatus != null) {
            return Right(cachedStatus);
          } else {
            return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
          }
        }
      } else {
        // 没有网络，使用缓存数�?
        if (cachedStatus != null) {
          return Right(cachedStatus);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('检查收藏状态失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> batchFavoriteOperation({
    List<String>? addIds,
    List<String>? removeIds,
  }) async {
    try {
      // 先批量更新本地缓存状�?
      if (addIds != null) {
        final Map<String, bool> statusMap = <String, bool>{};
        for (final String novelId in addIds) {
          statusMap[novelId] = true;
        }
        await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      }

      if (removeIds != null) {
        final Map<String, bool> statusMap = <String, bool>{};
        for (final String novelId in removeIds) {
          statusMap[novelId] = false;
        }
        await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      }

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        if (addIds != null) {
          await remoteDataSource.batchAddToFavorites(novelIds: addIds);
        }
        if (removeIds != null) {
          await remoteDataSource.batchRemoveFromFavorites(novelIds: removeIds);
        }
        
        // 清理收藏列表缓存
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状�?
      if (addIds != null) {
        final Map<String, bool> statusMap = <String, bool>{};
        for (final String novelId in addIds) {
          statusMap[novelId] = false;
        }
        await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      }
      if (removeIds != null) {
        final Map<String, bool> statusMap = <String, bool>{};
        for (final String novelId in removeIds) {
          statusMap[novelId] = true;
        }
        await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      }
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('批量收藏操作失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<ReadingHistory>> getReadingHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 如果是第一页，优先从缓存获�?
      if (page == 1) {
        final List<ReadingHistory>? cachedHistory = await localDataSource.getCachedReadingHistory();
        if (cachedHistory != null && cachedHistory.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateReadingHistoryCache();
          }
          return Right(cachedHistory);
        }
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final List<ReadingHistory> history = await remoteDataSource.getReadingHistory(
          page: page,
          limit: limit,
        );

        // 如果是第一页，缓存数据
        if (page == 1) {
          await localDataSource.cacheReadingHistory(history);
        }

        return Right(history);
      } else {
        // 没有网络，返回缓存数据或错误
        final List<ReadingHistory>? cachedHistory = await localDataSource.getCachedReadingHistory();
        if (cachedHistory != null) {
          return Right(cachedHistory);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取阅读历史失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> clearReadingHistory() async {
    try {
      // 如果有网络，先清理服务器数据
      if (await networkInfo.isConnected) {
        await remoteDataSource.clearReadingHistory();
      }

      // 清理本地缓存
      await localDataSource.clearCache('history');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('清理阅读历史失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteHistoryItem(String historyId) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.clearReadingHistory(novelIds: <String>[historyId]);
        
        // 清理本地缓存
        await localDataSource.clearCache('history');
        
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '删除历史记录需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('删除历史记录失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<BookmarkModel>> getBookmarks({
    String? novelId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // 这里需要调用远程数据源的书签方�?
        // 由于当前远程数据源没有书签相关方法，我们返回空列�?
        return const Right(<BookmarkModel>[]);
      } else {
        return Left(NoInternetError(message: '获取书签需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取书签失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<BookmarkModel> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        // 这里需要调用远程数据源的添加书签方�?
        // 由于当前远程数据源没有书签相关方法，我们创建一个模拟的书签
        final BookmarkModel bookmark = BookmarkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'current_user',
          novelId: novelId,
          chapterId: chapterId,
          chapterNumber: 1,
          chapterTitle: '章节标题',
          position: position,
          note: note,
          createdAt: DateTime.now(),
        );
        return Right(bookmark);
      } else {
        return Left(NoInternetError(message: '添加书签需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('添加书签失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteBookmark(String bookmarkId) async {
    try {
      if (await networkInfo.isConnected) {
        // 这里需要调用远程数据源的删除书签方�?
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '删除书签需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('删除书签失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserStats> getUserStats() async {
    try {
      // 优先从缓存获�?
      final UserStats? cachedStats = await localDataSource.getCachedUserStats();
      
      if (cachedStats != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserStatsCache();
        }
        return Right(cachedStats);
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final UserStats stats = await remoteDataSource.getUserStats();
        
        // 缓存统计数据
        await localDataSource.cacheUserStats(stats);
        
        return Right(stats);
      } else {
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取用户统计失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> updateUserSettings(UserSettings settings) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateUserSettings(settings);
        
        // 清理设置缓存，下次获取时会重新加�?
        await localDataSource.clearCache('settings');
        
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '更新用户设置需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('更新用户设置失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> checkIn() async {
    try {
      if (await networkInfo.isConnected) {
        final Map<String, dynamic> result = await remoteDataSource.checkIn();
        
        // 清理签到状态缓�?
        await localDataSource.clearCache('checkin');
        
        return Right(result);
      } else {
        return Left(NoInternetError(message: '签到需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('签到失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> getCheckInStatus() async {
    try {
      // 优先从缓存获�?
      final bool? cachedStatus = await localDataSource.getCachedCheckinStatus();
      
      if (cachedStatus != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateCheckinStatusCache();
        }
        return Right(cachedStatus);
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final bool status = await remoteDataSource.getCheckInStatus();
        
        // 缓存签到状�?
        await localDataSource.cacheCheckinStatus(<String, dynamic>{'checked_in': status});
        
        return Right(status);
      } else {
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取签到状态失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> checkFavoriteStatus({required String novelId}) async => isFavorite(novelId);

  @override
  ResultFuture<void> batchAddToFavorites({required List<String> novelIds}) async => batchFavoriteOperation(addIds: novelIds);

  @override
  ResultFuture<void> batchRemoveFromFavorites({required List<String> novelIds}) async => batchFavoriteOperation(removeIds: novelIds);

  @override
  ResultFuture<void> addReadingHistory({
    required String novelId,
    required String chapterId,
    required int readingTime,
    String? lastPosition,
  }) async {
    try {
      // 本地添加阅读历史记录
      await localDataSource.addReadingHistoryRecord(
        novelId: novelId,
        chapterId: chapterId,
        readingTime: readingTime,
        lastPosition: lastPosition,
      );

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addReadingHistory(
            novelId: novelId,
            chapterId: chapterId,
            readingTime: readingTime,
            lastPosition: lastPosition,
          );
        } catch (e) {
          // 网络同步失败不影响本地记�?
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('添加阅读历史失败：{e.toString()}'));
    }
  }

  @override
  ResultFuture<UserSettings> getUserSettings() async {
    try {
      // 优先从缓存获�?
      final UserSettings? cachedSettings = await localDataSource.getCachedUserSettings();
      
      if (cachedSettings != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserSettingsCache();
        }
        return Right(cachedSettings);
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final UserSettings settings = await remoteDataSource.getUserSettings();
        
        // 缓存设置数据
        await localDataSource.cacheUserSettings(settings);
        
        return Right(settings);
      } else {
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取用户设置失败：{e.toString()}'));
    }
  }

  @override
  ResultFuture<List<NovelModel>> searchFavoriteNovels({
    required String keyword,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final List<NovelModel> novels = await remoteDataSource.searchFavoriteNovels(
          keyword: keyword,
          page: page,
          limit: limit,
        );
        return Right(novels);
      } else {
        // 离线搜索，从缓存的收藏列表中搜索
        final List<NovelModel>? cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null) {
          final List<NovelModel> filteredNovels = cachedNovels.where((NovelModel novel) =>
            novel.title.toLowerCase().contains(keyword.toLowerCase()) ||
            novel.author.name.toLowerCase().contains(keyword.toLowerCase())
          ).toList();
          return Right(filteredNovels);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('搜索收藏小说失败：{e.toString()}'));
    }
  }

  @override
  ResultFuture<List<NovelModel>> getRecentlyReadNovels({int limit = 10}) async {
    try {
      // 优先从缓存获�?
      final List<NovelModel>? cachedNovels = await localDataSource.getCachedRecentlyReadNovels();
      
      if (cachedNovels != null && cachedNovels.isNotEmpty) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateRecentlyReadCache(limit);
        }
        return Right(cachedNovels);
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final List<NovelModel> novels = await remoteDataSource.getRecentlyReadNovels(limit: limit);
        
        // 缓存数据
        await localDataSource.cacheRecentlyReadNovels(novels);
        
        return Right(novels);
      } else {
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取最近阅读失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<NovelModel>> getRecommendedNovels({
    int page = 1,
    int limit = 20,
    String? category,
  }) async {
    try {
      // 如果是第一页，优先从缓存获�?
      if (page == 1) {
        final List<NovelModel>? cachedNovels = await localDataSource.getCachedRecommendedNovels();
        if (cachedNovels != null && cachedNovels.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateRecommendedCache();
          }
          return Right(cachedNovels);
        }
      }

      // 检查网络连�?
      if (await networkInfo.isConnected) {
        final List<NovelModel> novels = await remoteDataSource.getRecommendedNovels(
          page: page,
          limit: limit,
        );

        // 如果是第一页，缓存数据
        if (page == 1) {
          await localDataSource.cacheRecommendedNovels(novels);
        }

        return Right(novels);
      } else {
        // 没有网络，返回缓存数据或错误
        final List<NovelModel>? cachedNovels = await localDataSource.getCachedRecommendedNovels();
        if (cachedNovels != null) {
          return Right(cachedNovels);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('获取推荐小说失败：{e.toString()}'));
    }
  }

  @override
  ResultFuture<void> syncData() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.syncData();
        
        // 清理所有缓存，强制重新加载
        await localDataSource.clearAllCache();
        
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '同步数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('同步数据失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<String> exportUserData() async {
    try {
      if (await networkInfo.isConnected) {
        final String downloadUrl = await remoteDataSource.exportUserData();
        return Right(downloadUrl);
      } else {
        return Left(NoInternetError(message: '导出数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('导出数据失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> importUserData({required String dataPath}) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.importUserData(dataPath: dataPath);
        
        // 清理所有缓存，重新加载数据
        await localDataSource.clearAllCache();
        
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '导入数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('导入数据失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteAccount() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAccount();
        
        // 清理所有本地数�?
        await localDataSource.clearAllCache();
        
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '删除账户需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('删除账户失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '修改密码需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(NetworkError(message: e.message));
    } catch (e) {
      return Left(AppError.unknown('修改密码失败：${e.toString()}'));
    }
  }

  // 私有方法：异步更新缓�?
  Future<void> _updateFavoritesCache({String? sortBy}) async {
    try {
      final List<NovelModel> novels = await remoteDataSource.getFavoriteNovels(
        sortBy: sortBy,
      );
      await localDataSource.cacheFavoriteNovels(novels);
    } catch (e) {
      // 静默失败，不影响用户体验
    }
  }

  Future<void> _updateUserProfileCache() async {
    try {
      final UserModel user = await remoteDataSource.getUserProfile();
      await localDataSource.cacheUserProfile(user);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateReadingHistoryCache() async {
    try {
      final List<ReadingHistory> history = await remoteDataSource.getReadingHistory();
      await localDataSource.cacheReadingHistory(history);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateUserStatsCache() async {
    try {
      final UserStats stats = await remoteDataSource.getUserStats();
      await localDataSource.cacheUserStats(stats);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateUserSettingsCache() async {
    try {
      final UserSettings settings = await remoteDataSource.getUserSettings();
      await localDataSource.cacheUserSettings(settings);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateRecentlyReadCache(int limit) async {
    try {
      final List<NovelModel> novels = await remoteDataSource.getRecentlyReadNovels(limit: limit);
      await localDataSource.cacheRecentlyReadNovels(novels);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateRecommendedCache() async {
    try {
      final List<NovelModel> novels = await remoteDataSource.getRecommendedNovels();
      await localDataSource.cacheRecommendedNovels(novels);
    } catch (e) {
      // 静默失败
    }
  }

  Future<void> _updateCheckinStatusCache() async {
    try {
      final bool status = await remoteDataSource.getCheckInStatus();
      await localDataSource.cacheCheckinStatus(<String, dynamic>{'checked_in': status});
    } catch (e) {
      // 静默失败
    }
  }
}


















