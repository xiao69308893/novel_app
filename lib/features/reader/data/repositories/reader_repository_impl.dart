import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/reader_config.dart';
import '../../../../shared/models/chapter_model.dart' hide ReadingProgress;
import '../../domain/repositories/reader_repository.dart' ;
import '../datasources/reader_local_data_source.dart';
import '../datasources/reader_remote_data_source.dart';

/// 阅读器仓储实现
class ReaderRepositoryImpl implements ReaderRepository {
  final ReaderRemoteDataSource remoteDataSource;
  final ReaderLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const ReaderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  ResultFuture<ChapterModel> loadChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      // 优先从缓存加载
      final cachedChapter = await localDataSource.getCachedChapter(
        novelId: novelId,
        chapterId: chapterId,
      );

      if (cachedChapter != null) {
        return Right(cachedChapter);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 从网络加载章节
        final chapter = await remoteDataSource.loadChapter(
          novelId: novelId,
          chapterId: chapterId,
        );

        // 缓存章节内容
        await localDataSource.cacheChapter(chapter);

        return Right(chapter);
      } else {
        // 检查本地是否有缓存
        final cachedChapter = await localDataSource.getCachedChapter(
          novelId: novelId,
          chapterId: chapterId,
        );
        
        if (cachedChapter != null) {
          return Right(cachedChapter);
        }
        
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));

      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    }
  }

  @override
  ResultFuture<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
  }) async {
    try {
      // 优先从缓存获取
      final cachedChapters = await localDataSource.getCachedChapterList(
        novelId: novelId,
      );

      if (cachedChapters != null && cachedChapters.isNotEmpty) {
        return Right(cachedChapters);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 从网络获取章节列表
        final chapters = await remoteDataSource.getChapterList(
          novelId: novelId,
        );

        // 缓存章节列表
        await localDataSource.cacheChapterList(
          novelId: novelId,
          chapters: chapters,
        );

        return Right(chapters);
      } else {
        return  Left(NoInternetError(message: '网络连接不可用'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取章节列表失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<NovelModel> getNovelInfo({required String novelId}) async {
    try {
      // 优先从缓存获取
      final cachedNovel = await localDataSource.getCachedNovelInfo(
        novelId: novelId,
      );

      if (cachedNovel != null) {
        return Right(cachedNovel);
      }

      // 检查网络连接
      if (await networkInfo.isConnected) {
        // 从网络获取小说信息
        final novel = await remoteDataSource.getNovelInfo(novelId: novelId);

        // 缓存小说信息
        await localDataSource.cacheNovelInfo(novel);

        return Right(novel);
      } else {
        return  Left(NoInternetError(message: '网络连接不可用'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取小说信息失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  }) async {
    try {
      final readingProgress = ReadingProgress(
        novelId: novelId,
        chapterId: chapterId,
        position: position,
        progress: progress, 
        updatedAt: DateTime.now(),
      );

      // 本地保存
      await localDataSource.saveReadingProgress(readingProgress);

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.saveReadingProgress(
            novelId: novelId,
            chapterId: chapterId,
            position: position,
            progress: progress,
          );
        } catch (e) {
          // 网络保存失败不影响本地保存
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '保存阅读进度失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<ReadingProgress?> getReadingProgress({
    required String novelId,
  }) async {
    try {
      // 优先从本地获取
      final localProgress = await localDataSource.getReadingProgress(
        novelId: novelId,
      );

      // 如果有网络，尝试从服务器获取最新进度
      if (await networkInfo.isConnected) {
        try {
          final remoteProgress = await remoteDataSource.getReadingProgress(
            novelId: novelId,
          );

          // 比较本地和远程进度，返回最新的
          if (remoteProgress != null && 
              (localProgress == null || 
               remoteProgress.updatedAt.isAfter(localProgress.updatedAt))) {
            // 保存最新进度到本地
            await localDataSource.saveReadingProgress(remoteProgress);
            return Right(remoteProgress);
          }
        } catch (e) {
          // 网络获取失败，使用本地进度
        }
      }

      return Right(localProgress);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取阅读进度失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<BookmarkModel> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
    String? content,
  }) async {
    try {
      // 如果有网络，先添加到服务器
      if (await networkInfo.isConnected) {
        final bookmark = await remoteDataSource.addBookmark(
          novelId: novelId,
          chapterId: chapterId,
          position: position,
          note: note,
          content: content,
        );

        // 保存到本地
        await localDataSource.saveBookmark(bookmark);

        return Right(bookmark);
      } else {
        // 离线模式，创建本地书签
        final bookmark = BookmarkModel(
          id: '${DateTime.now().millisecondsSinceEpoch}', // 临时ID
          novelId: novelId,
          chapterId: chapterId,
          position: position,
          note: note,
          content: content,
          createdAt: DateTime.now(),
          userId: '', 
          chapterNumber: 0, 
          chapterTitle: '',
        );

        await localDataSource.saveBookmark(bookmark);
        return Right(bookmark);
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '添加书签失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> deleteBookmark({required String bookmarkId}) async {
    try {
      // 本地删除
      await localDataSource.deleteBookmark(bookmarkId: bookmarkId);

      // 如果有网络，同步删除服务器书签
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.deleteBookmark(bookmarkId: bookmarkId);
        } catch (e) {
          // 网络删除失败不影响本地删除
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '删除书签失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  }) async {
    try {
      // 获取本地书签
      final localBookmarks = await localDataSource.getBookmarks(
        novelId: novelId,
        chapterId: chapterId,
      );

      // 如果有网络，尝试同步服务器书签
      if (await networkInfo.isConnected) {
        try {
          final remoteBookmarks = await remoteDataSource.getBookmarks(
            novelId: novelId,
            chapterId: chapterId,
          );

          // 合并本地和远程书签（去重）
          final allBookmarks = <String, BookmarkModel>{};
          
          for (final bookmark in localBookmarks) {
            allBookmarks[bookmark.id] = bookmark;
          }
          
          for (final bookmark in remoteBookmarks) {
            allBookmarks[bookmark.id] = bookmark;
          }

          final mergedBookmarks = allBookmarks.values.toList();
          
          // 保存合并后的书签到本地
          for (final bookmark in mergedBookmarks) {
            await localDataSource.saveBookmark(bookmark);
          }

          return Right(mergedBookmarks);
        } catch (e) {
          // 网络获取失败，使用本地书签
        }
      }

      return Right(localBookmarks);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取书签列表失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> saveReaderConfig({required ReaderConfig config}) async {
    try {
      await localDataSource.saveReaderConfig(config);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '保存阅读器配置失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<ReaderConfig> getReaderConfig() async {
    try {
      final config = await localDataSource.getReaderConfig();
      return Right(config ?? const ReaderConfig());
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取阅读器配置失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> cacheChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final chapter = await remoteDataSource.loadChapter(
          novelId: novelId,
          chapterId: chapterId,
        );
        await localDataSource.cacheChapter(chapter);
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '网络连接不可用'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '缓存章节失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<String>> getCachedChapterIds({
    required String novelId,
  }) async {
    try {
      final chapterIds = await localDataSource.getCachedChapterIds(
        novelId: novelId,
      );
      return Right(chapterIds);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取缓存章节列表失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> clearCache({String? novelId}) async {
    try {
      await localDataSource.clearCache(novelId: novelId);
      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '清理缓存失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> updateReadingTime({
    required String novelId,
    required int minutes,
  }) async {
    try {
      // 本地更新
      await localDataSource.updateReadingTime(
        novelId: novelId,
        minutes: minutes,
      );

      // 如果有网络，同步到服务器
      if (await networkInfo.isConnected) {
        try {
          await remoteDataSource.updateReadingTime(
            novelId: novelId,
            minutes: minutes,
          );
        } catch (e) {
          // 网络更新失败不影响本地更新
        }
      }

      return const Right(null);
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '更新阅读时长失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<ReadingStats> getReadingStats() async {
    try {
      // 本地获取统计
      final localStats = await localDataSource.getReadingStats();

      // 如果有网络，尝试获取服务器统计
      if (await networkInfo.isConnected) {
        try {
          final remoteStats = await remoteDataSource.getReadingStats();
          
          // 保存到本地
          await localDataSource.saveReadingStats(remoteStats);
          
          return Right(remoteStats);
        } catch (e) {
          // 网络获取失败，使用本地统计
        }
      }

      return Right(localStats ?? const ReadingStats());
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取阅读统计失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<List<ChapterSimpleModel>> searchChapters({
    required String novelId,
    required String keyword,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final chapters = await remoteDataSource.searchChapters(
          novelId: novelId,
          keyword: keyword,
        );
        return Right(chapters);
      } else {
        // 离线搜索，从缓存的章节列表中搜索
        final cachedChapters = await localDataSource.getCachedChapterList(
          novelId: novelId,
        );
        
        if (cachedChapters != null) {
          final filteredChapters = cachedChapters.where((chapter) =>
            chapter.title.toLowerCase().contains(keyword.toLowerCase()) ||
            chapter.chapterNumber.toString().contains(keyword)
          ).toList();
          
          return Right(filteredChapters);
        } else {
          return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
        }
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '搜索章节失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final adjacentChapters = await remoteDataSource.getAdjacentChapters(
          novelId: novelId,
          chapterId: chapterId,
        );
        return Right(adjacentChapters);
      } else {
        // 离线模式，从缓存的章节列表中查找相邻章节
        final cachedChapters = await localDataSource.getCachedChapterList(
          novelId: novelId,
        );
        
        if (cachedChapters != null) {
          final currentIndex = cachedChapters.indexWhere((c) => c.id == chapterId);
          
          if (currentIndex != -1) {
            final previousChapter = currentIndex > 0 ? cachedChapters[currentIndex - 1] : null;
            final nextChapter = currentIndex < cachedChapters.length - 1 ? cachedChapters[currentIndex + 1] : null;
            
            return Right({
              'previous': previousChapter,
              'next': nextChapter,
            });
          }
        }
        
        return Left(NoInternetError(message: '网络连接不可用且无缓存数据'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } on CacheException catch (e) {
      return Left(StorageError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '获取相邻章节失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<void> purchaseChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.purchaseChapter(
          novelId: novelId,
          chapterId: chapterId,
        );
        return const Right(null);
      } else {
        return Left(NoInternetError(message: '购买章节需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '购买章节失败：${e.toString()}'));
    }
  }

  @override
  ResultFuture<bool> checkChapterPurchaseStatus({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      if (await networkInfo.isConnected) {
        final isPurchased = await remoteDataSource.checkChapterPurchaseStatus(
          novelId: novelId,
          chapterId: chapterId,
        );
        return Right(isPurchased);
      } else {
        return Left(NoInternetError(message: '检查购买状态需要网络连接'));
      }
    } on ServerException catch (e) {
      return Left(SystemError(message: e.message));
    } catch (e) {
      return Left(StorageError(message: '检查购买状态失败：${e.toString()}'));
    }
  }

  
}

