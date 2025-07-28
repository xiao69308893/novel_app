import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../domain/repositories/bookshelf_repository.dart';
import '../datasources/bookshelf_local_data_source.dart';
import '../datasources/bookshelf_remote_data_source.dart';

/// 书架仓储实现
class BookshelfRepositoryImpl implements BookshelfRepository {
  final BookshelfRemoteDataSource remoteDataSource;
  final BookshelfLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const BookshelfRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<List<NovelModel>> getFavoriteNovels({
    int page = 1,
    int limit = 20,
    String? sortBy,
    String? filterBy,
  }) async {
    try {
      // 如果是第一页，优先从缓存获取
      if (page == 1) {
        final cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null && cachedNovels.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateFavoritesCache(sortBy: sortBy, filterBy: filterBy);
          }
          return Right(cachedNovels);
        }
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final novels = await remoteDataSource.getFavoriteNovels(
          page: page,
          limit: limit,
          sortBy: sortBy,
          filterBy: filterBy,
        );

        // 如果是第一页，缓存数据
        if (page == 1) {
          await localDataSource.cacheFavoriteNovels(novels);
        }

        return Right(novels);
      } else {
        // 没有网络，返回缓存数据或错误
        final cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null) {
          return Right(cachedNovels);
        } else {
          return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取收藏列表失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> addToFavorites({required String novelId}) async {
    try {
      // 先更新本地缓存状态
      await localDataSource.cacheFavoriteStatus(novelId, true);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.addToFavorites(novelId: novelId);
        
        // 清理收藏列表缓存，下次获取时会重新加载
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状态
      await localDataSource.cacheFavoriteStatus(novelId, false);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '添加收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> removeFromFavorites({required String novelId}) async {
    try {
      // 先更新本地缓存状态
      await localDataSource.cacheFavoriteStatus(novelId, false);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.removeFromFavorites(novelId: novelId);
        
        // 清理收藏列表缓存，下次获取时会重新加载
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状态
      await localDataSource.cacheFavoriteStatus(novelId, true);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '取消收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> checkFavoriteStatus({required String novelId}) async {
    try {
      // 优先从缓存获取
      final cachedStatus = await localDataSource.getCachedFavoriteStatus(novelId);
      
      // 如果有网络，异步更新缓存
      if (await networkInfo.isConnected) {
        try {
          final remoteStatus = await remoteDataSource.checkFavoriteStatus(novelId: novelId);
          
          // 更新缓存
          await localDataSource.cacheFavoriteStatus(novelId, remoteStatus);
          
          return Right(remoteStatus);
        } catch (e) {
          // 网络获取失败，使用缓存数据
          if (cachedStatus != null) {
            return Right(cachedStatus);
          } else {
            return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
          }
        }
      } else {
        // 没有网络，使用缓存数据
        if (cachedStatus != null) {
          return Right(cachedStatus);
        } else {
          return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '检查收藏状态失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> batchAddToFavorites({required List<String> novelIds}) async {
    try {
      // 先批量更新本地缓存状态
      final statusMap = <String, bool>{};
      for (final novelId in novelIds) {
        statusMap[novelId] = true;
      }
      await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.batchAddToFavorites(novelIds: novelIds);
        
        // 清理收藏列表缓存
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状态
      final statusMap = <String, bool>{};
      for (final novelId in novelIds) {
        statusMap[novelId] = false;
      }
      await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '批量添加收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> batchRemoveFromFavorites({required List<String> novelIds}) async {
    try {
      // 先批量更新本地缓存状态
      final statusMap = <String, bool>{};
      for (final novelId in novelIds) {
        statusMap[novelId] = false;
      }
      await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        await remoteDataSource.batchRemoveFromFavorites(novelIds: novelIds);
        
        // 清理收藏列表缓存
        await localDataSource.clearCache('favorites');
      }

      return const Right(null);
    } on ServerException catch (e) {
      // 服务器操作失败，回滚本地状态
      final statusMap = <String, bool>{};
      for (final novelId in novelIds) {
        statusMap[novelId] = true;
      }
      await (localDataSource as BookshelfLocalDataSourceImpl).batchUpdateFavoriteStatus(statusMap);
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '批量取消收藏失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserModel> getUserProfile() async {
    try {
      // 优先从缓存获取
      final cachedUser = await localDataSource.getCachedUserProfile();
      
      if (cachedUser != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserProfileCache();
        }
        return Right(cachedUser);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final user = await remoteDataSource.getUserProfile();
        
        // 缓存用户信息
        await localDataSource.cacheUserProfile(user);
        
        return Right(user);
      } else {
        return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取用户信息失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserModel> updateUserProfile({
    String? nickname,
    String? avatar,
    String? bio,
    String? email,
    String? phone,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final updatedUser = await remoteDataSource.updateUserProfile(
          nickname: nickname,
          avatar: avatar,
          bio: bio,
          email: email,
          phone: phone,
        );
        
        // 更新缓存
        await localDataSource.cacheUserProfile(updatedUser);
        
        return Right(updatedUser);
      } else {
        return const Left(NetworkFailure(message: '更新用户信息需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '更新用户信息失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<ReadingHistoryModel>> getReadingHistory({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 如果是第一页，优先从缓存获取
      if (page == 1) {
        final cachedHistory = await localDataSource.getCachedReadingHistory();
        if (cachedHistory != null && cachedHistory.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateReadingHistoryCache();
          }
          return Right(cachedHistory);
        }
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final history = await remoteDataSource.getReadingHistory(
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
        final cachedHistory = await localDataSource.getCachedReadingHistory();
        if (cachedHistory != null) {
          return Right(cachedHistory);
        } else {
          return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取阅读历史失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> addReadingHistory({
    required String novelId,
    required String chapterId,
    String? chapterTitle,
  }) async {
    try {
      // 本地添加阅读历史记录
      await localDataSource.addReadingHistoryRecord(
        novelId: novelId,
        chapterId: chapterId,
        chapterTitle: chapterTitle,
      );

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.addReadingHistory(
            novelId: novelId,
            chapterId: chapterId,
            chapterTitle: chapterTitle,
          );
        } catch (e) {
          // 网络同步失败不影响本地记录
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '添加阅读历史失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> clearReadingHistory({List<String>? novelIds}) async {
    try {
      // 如果有网络，先清理服务器数据
      if (await networkInfo.isConnected) {
        await remoteDataSource.clearReadingHistory(novelIds: novelIds);
      }

      // 清理本地缓存
      await localDataSource.clearCache('history');

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '清理阅读历史失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserStats> getUserStats() async {
    try {
      // 优先从缓存获取
      final cachedStats = await localDataSource.getCachedUserStats();
      
      if (cachedStats != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserStatsCache();
        }
        return Right(cachedStats);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final stats = await remoteDataSource.getUserStats();
        
        // 缓存统计数据
        await localDataSource.cacheUserStats(stats);
        
        return Right(stats);
      } else {
        return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取用户统计失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<UserSettings> getUserSettings() async {
    try {
      // 优先从缓存获取
      final cachedSettings = await localDataSource.getCachedUserSettings();
      
      if (cachedSettings != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateUserSettingsCache();
        }
        return Right(cachedSettings);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final settings = await remoteDataSource.getUserSettings();
        
        // 缓存设置数据
        await localDataSource.cacheUserSettings(settings);
        
        return Right(settings);
      } else {
        return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取用户设置失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> updateUserSettings({
    ReaderSettings? reader,
    NotificationSettings? notifications,
    PrivacySettings? privacy,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updateUserSettings(
          reader: reader,
          notifications: notifications,
          privacy: privacy,
        );
        
        // 清理设置缓存，下次获取时会重新加载
        await localDataSource.clearCache('settings');
        
        return const Right(null);
      } else {
        return const Left(NetworkFailure(message: '更新用户设置需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '更新用户设置失败：${e.toString()}'));
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
        final novels = await remoteDataSource.searchFavoriteNovels(
          keyword: keyword,
          page: page,
          limit: limit,
        );
        return Right(novels);
      } else {
        // 离线搜索，从缓存的收藏列表中搜索
        final cachedNovels = await localDataSource.getCachedFavoriteNovels();
        if (cachedNovels != null) {
          final filteredNovels = cachedNovels.where((novel) =>
            novel.title.toLowerCase().contains(keyword.toLowerCase()) ||
            novel.author.name.toLowerCase().contains(keyword.toLowerCase())
          ).toList();
          return Right(filteredNovels);
        } else {
          return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '搜索收藏小说失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<NovelModel>> getRecentlyReadNovels({int limit = 10}) async {
    try {
      // 优先从缓存获取
      final cachedNovels = await localDataSource.getCachedRecentlyReadNovels();
      
      if (cachedNovels != null && cachedNovels.isNotEmpty) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateRecentlyReadCache(limit);
        }
        return Right(cachedNovels);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final novels = await remoteDataSource.getRecentlyReadNovels(limit: limit);
        
        // 缓存数据
        await localDataSource.cacheRecentlyReadNovels(novels);
        
        return Right(novels);
      } else {
        return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取最近阅读失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<NovelModel>> getRecommendedNovels({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // 如果是第一页，优先从缓存获取
      if (page == 1) {
        final cachedNovels = await localDataSource.getCachedRecommendedNovels();
        if (cachedNovels != null && cachedNovels.isNotEmpty) {
          // 有缓存数据，异步更新缓存
          if (await networkInfo.isConnected) {
            _updateRecommendedCache();
          }
          return Right(cachedNovels);
        }
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final novels = await remoteDataSource.getRecommendedNovels(
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
        final cachedNovels = await localDataSource.getCachedRecommendedNovels();
        if (cachedNovels != null) {
          return Right(cachedNovels);
        } else {
          return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取推荐小说失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<CheckinResult> checkin() async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.checkin();
        
        // 清理签到状态缓存
        await localDataSource.clearCache('checkin');
        
        return Right(result);
      } else {
        return const Left(NetworkFailure(message: '签到需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '签到失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<CheckinStatus> getCheckinStatus() async {
    try {
      // 优先从缓存获取
      final cachedStatus = await localDataSource.getCachedCheckinStatus();
      
      if (cachedStatus != null) {
        // 有缓存数据，异步更新缓存
        if (await networkInfo.isConnected) {
          _updateCheckinStatusCache();
        }
        return Right(cachedStatus);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        final status = await remoteDataSource.getCheckinStatus();
        
        // 缓存签到状态
        await localDataSource.cacheCheckinStatus(status);
        
        return Right(status);
      } else {
        return const Left(NetworkFailure(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '获取签到状态失败：${e.toString()}'));
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
        return const Left(NetworkFailure(message: '同步数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '同步数据失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<String> exportUserData() async {
    try {
      if (await networkInfo.isConnected) {
        final downloadUrl = await remoteDataSource.exportUserData();
        return Right(downloadUrl);
      } else {
        return const Left(NetworkFailure(message: '导出数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '导出数据失败：${e.toString()}'));
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
        return const Left(NetworkFailure(message: '导入数据需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '导入数据失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteAccount() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAccount();
        
        // 清理所有本地数据
        await localDataSource.clearAllCache();
        
        return const Right(null);
      } else {
        return const Left(NetworkFailure(message: '删除账户需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '删除账户失败：${e.toString()}'));
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
        return const Left(NetworkFailure(message: '修改密码需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(GeneralFailure(message: '修改密码失败：${e.toString()}'));
    }
  }

  // 私有方法：异步更新缓存
  void _updateFavoritesCache({String? sortBy, String? filterBy}) async {
    try {
      final novels = await remoteDataSource.getFavoriteNovels(
        sortBy: sortBy,
        filterBy: filterBy,
      );
      await localDataSource.cacheFavoriteNovels(novels);
    } catch (e) {
      // 静默失败，不影响用户体验
    }
  }

  void _updateUserProfileCache() async {
    try {
      final user = await remoteDataSource.getUserProfile();
      await localDataSource.cacheUserProfile(user);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateReadingHistoryCache() async {
    try {
      final history = await remoteDataSource.getReadingHistory();
      await localDataSource.cacheReadingHistory(history);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateUserStatsCache() async {
    try {
      final stats = await remoteDataSource.getUserStats();
      await localDataSource.cacheUserStats(stats);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateUserSettingsCache() async {
    try {
      final settings = await remoteDataSource.getUserSettings();
      await localDataSource.cacheUserSettings(settings);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateRecentlyReadCache(int limit) async {
    try {
      final novels = await remoteDataSource.getRecentlyReadNovels(limit: limit);
      await localDataSource.cacheRecentlyReadNovels(novels);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateRecommendedCache() async {
    try {
      final novels = await remoteDataSource.getRecommendedNovels();
      await localDataSource.cacheRecommendedNovels(novels);
    } catch (e) {
      // 静默失败
    }
  }

  void _updateCheckinStatusCache() async {
    try {
      final status = await remoteDataSource.getCheckinStatus();
      await localDataSource.cacheCheckinStatus(status);
    } catch (e) {
      // 静默失败
    }
  }
}