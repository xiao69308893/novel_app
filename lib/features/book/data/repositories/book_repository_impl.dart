// 小说仓储实现
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/network/network_info.dart';
import '../../../shared/models/novel_model.dart';
import '../../../shared/models/chapter_model.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_remote_datasource.dart';
import '../datasources/book_local_datasource.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final BookLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  BookRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<AppError, BookDetail>> getBookDetail(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final bookDetailModel = await remoteDataSource.getBookDetail(bookId);
        
        // 缓存到本地
        await localDataSource.saveBookDetail(bookDetailModel);
        
        // 检查收藏和下载状态
        final favorites = await localDataSource.getFavoriteBooks() ?? [];
        final downloaded = await localDataSource.getDownloadedBooks() ?? [];
        
        final updatedDetail = BookDetailModel(
          novel: bookDetailModel.novel,
          chapters: bookDetailModel.chapters,
          readingProgress: bookDetailModel.readingProgress,
          isFavorited: favorites.contains(bookId),
          isDownloaded: downloaded.contains(bookId),
          stats: bookDetailModel.stats,
        );
        
        return Right(updatedDetail.toEntity());
      } on AppError catch (e) {
        // 网络请求失败，尝试从本地获取
        final localDetail = await localDataSource.getBookDetail(bookId);
        if (localDetail != null) {
          return Right(localDetail.toEntity());
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      // 无网络连接，从本地获取
      final localDetail = await localDataSource.getBookDetail(bookId);
      if (localDetail != null) {
        return Right(localDetail.toEntity());
      }
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, List<ChapterSimpleModel>>> getChapterList({
    required String bookId,
    int page = 1,
    int limit = 50,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final chapters = await remoteDataSource.getChapterList(
          bookId: bookId,
          page: page,
          limit: limit,
        );
        
        // 首页章节缓存到本地
        if (page == 1) {
          await localDataSource.saveChapterList(bookId, chapters);
        }
        
        return Right(chapters);
      } on AppError catch (e) {
        // 网络请求失败且是首页时，尝试从本地获取
        if (page == 1) {
          final localChapters = await localDataSource.getChapterList(bookId);
          if (localChapters != null) {
            return Right(localChapters);
          }
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      if (page == 1) {
        // 无网络连接，从本地获取首页章节
        final localChapters = await localDataSource.getChapterList(bookId);
        if (localChapters != null) {
          return Right(localChapters);
        }
      }
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, ChapterModel>> getChapterDetail(String chapterId) async {
    if (await networkInfo.isConnected) {
      try {
        final chapter = await remoteDataSource.getChapterDetail(chapterId);
        
        // 缓存到本地
        await localDataSource.saveChapterDetail(chapter);
        
        return Right(chapter);
      } on AppError catch (e) {
        // 网络请求失败，尝试从本地获取
        final localChapter = await localDataSource.getChapterDetail(chapterId);
        if (localChapter != null) {
          return Right(localChapter);
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      // 无网络连接，从本地获取
      final localChapter = await localDataSource.getChapterDetail(chapterId);
      if (localChapter != null) {
        return Right(localChapter);
      }
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, List<Comment>>> getBookComments({
    required String bookId,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final commentModels = await remoteDataSource.getBookComments(
          bookId: bookId,
          page: page,
          limit: limit,
        );
        return Right(commentModels.map((model) => model.toEntity()).toList());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, List<Comment>>> getChapterComments({
    required String chapterId,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final commentModels = await remoteDataSource.getChapterComments(
          chapterId: chapterId,
          page: page,
          limit: limit,
        );
        return Right(commentModels.map((model) => model.toEntity()).toList());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, Comment>> postComment({
    required String targetId,
    required CommentType type,
    required String content,
    String? parentId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final commentModel = await remoteDataSource.postComment(
          targetId: targetId,
          type: type.name,
          content: content,
          parentId: parentId,
        );
        return Right(commentModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> likeComment(String commentId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.likeComment(commentId);
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> unlikeComment(String commentId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unlikeComment(commentId);
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> deleteComment(String commentId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.deleteComment(commentId);
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> favoriteBook(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.favoriteBook(bookId);
        if (result) {
          // 更新本地收藏状态
          await localDataSource.addFavoriteBook(bookId);
        }
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> unfavoriteBook(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.unfavoriteBook(bookId);
        if (result) {
          // 更新本地收藏状态
          await localDataSource.removeFavoriteBook(bookId);
        }
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> rateBook({
    required String bookId,
    required int rating,
    String? review,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.rateBook(
          bookId: bookId,
          rating: rating,
          review: review,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> shareBook({
    required String bookId,
    required String platform,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.shareBook(
          bookId: bookId,
          platform: platform,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> reportContent({
    required String targetId,
    required String type,
    required String reason,
    String? description,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.reportContent(
          targetId: targetId,
          type: type,
          reason: reason,
          description: description,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> downloadChapter(String chapterId) async {
    if (await networkInfo.isConnected) {
      try {
        final taskId = await remoteDataSource.downloadChapter(chapterId);
        // TODO: 实现下载逻辑
        return const Right(true);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, bool>> downloadBook(String bookId) async {
    if (await networkInfo.isConnected) {
      try {
        final taskId = await remoteDataSource.downloadBook(bookId);
        // TODO: 实现下载逻辑
        await localDataSource.addDownloadedBook(bookId);
        return const Right(true);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Stream<double> getDownloadProgress(String taskId) {
    // TODO: 实现下载进度监听
    return Stream.value(0.0);
  }

  @override
  Future<Either<AppError, bool>> cancelDownload(String taskId) async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.cancelDownload(taskId);
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, ReadingProgress?>> getReadingProgress(String bookId) async {
    try {
      // 优先从本地获取
      final localProgress = await localDataSource.getReadingProgress(bookId);
      
      if (await networkInfo.isConnected) {
        try {
          final remoteProgress = await remoteDataSource.getReadingProgress(bookId);
          if (remoteProgress != null) {
            // 保存到本地
            await localDataSource.saveReadingProgress(remoteProgress);
            return Right(remoteProgress);
          }
        } catch (e) {
          // 远程获取失败，使用本地数据
        }
      }
      
      return Right(localProgress);
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<AppError, bool>> updateReadingProgress({
    required String bookId,
    required String chapterId,
    required int position,
    required double progress,
  }) async {
    try {
      // 创建进度对象
      final readingProgress = ReadingProgress(
        userId: 'current_user', // TODO: 从认证状态获取用户ID
        novelId: bookId,
        chapterId: chapterId,
        chapterNumber: 1, // TODO: 从章节信息获取
        position: position,
        progress: progress,
        lastReadAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // 先保存到本地
      await localDataSource.saveReadingProgress(readingProgress);
      
      if (await networkInfo.isConnected) {
        try {
          final result = await remoteDataSource.updateReadingProgress(
            bookId: bookId,
            chapterId: chapterId,
            position: position,
            progress: progress,
          );
          return Right(result);
        } catch (e) {
          // 远程更新失败，但本地已保存
          return const Right(true);
        }
      } else {
        // 无网络，但本地已保存
        return const Right(true);
      }
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getSimilarBooks({
    required String bookId,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getSimilarBooks(
          bookId: bookId,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getAuthorOtherBooks({
    required String authorId,
    String? excludeBookId,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getAuthorOtherBooks(
          authorId: authorId,
          excludeBookId: excludeBookId,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(AppError.noInternet());
    }
  }
}