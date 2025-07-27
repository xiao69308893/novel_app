// 小说仓储接口
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../shared/models/novel_model.dart';
import '../../../shared/models/chapter_model.dart';
import '../entities/book_detail.dart';
import '../entities/comment.dart';

abstract class BookRepository {
  /// 获取小说详情
  Future<Either<AppError, BookDetail>> getBookDetail(String bookId);

  /// 获取章节列表
  Future<Either<AppError, List<ChapterSimpleModel>>> getChapterList({
    required String bookId,
    int page = 1,
    int limit = 50,
  });

  /// 获取章节详情
  Future<Either<AppError, ChapterModel>> getChapterDetail(String chapterId);

  /// 获取小说评论
  Future<Either<AppError, List<Comment>>> getBookComments({
    required String bookId,
    int page = 1,
    int limit = 20,
  });

  /// 获取章节评论
  Future<Either<AppError, List<Comment>>> getChapterComments({
    required String chapterId,
    int page = 1,
    int limit = 20,
  });

  /// 发表评论
  Future<Either<AppError, Comment>> postComment({
    required String targetId,
    required CommentType type,
    required String content,
    String? parentId,
  });

  /// 点赞评论
  Future<Either<AppError, bool>> likeComment(String commentId);

  /// 取消点赞评论
  Future<Either<AppError, bool>> unlikeComment(String commentId);

  /// 删除评论
  Future<Either<AppError, bool>> deleteComment(String commentId);

  /// 收藏小说
  Future<Either<AppError, bool>> favoriteBook(String bookId);

  /// 取消收藏小说
  Future<Either<AppError, bool>> unfavoriteBook(String bookId);

  /// 评分小说
  Future<Either<AppError, bool>> rateBook({
    required String bookId,
    required int rating,
    String? review,
  });

  /// 分享小说
  Future<Either<AppError, bool>> shareBook({
    required String bookId,
    required String platform,
  });

  /// 举报内容
  Future<Either<AppError, bool>> reportContent({
    required String targetId,
    required String type, // book, chapter, comment
    required String reason,
    String? description,
  });

  /// 下载章节
  Future<Either<AppError, bool>> downloadChapter(String chapterId);

  /// 下载小说
  Future<Either<AppError, bool>> downloadBook(String bookId);

  /// 获取下载进度
  Stream<double> getDownloadProgress(String taskId);

  /// 取消下载
  Future<Either<AppError, bool>> cancelDownload(String taskId);

  /// 获取阅读进度
  Future<Either<AppError, ReadingProgress?>> getReadingProgress(String bookId);

  /// 更新阅读进度
  Future<Either<AppError, bool>> updateReadingProgress({
    required String bookId,
    required String chapterId,
    required int position,
    required double progress,
  });

  /// 获取相似小说推荐
  Future<Either<AppError, List<NovelSimpleModel>>> getSimilarBooks({
    required String bookId,
    int limit = 10,
  });

  /// 获取作者其他作品
  Future<Either<AppError, List<NovelSimpleModel>>> getAuthorOtherBooks({
    required String authorId,
    String? excludeBookId,
    int limit = 10,
  });
}