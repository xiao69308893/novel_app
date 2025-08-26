// 小说远程数据源
import 'package:dio/dio.dart';
import 'package:novel_app/core/network/api_response.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/error_handler.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../models/book_detail_model.dart';
import '../models/comment_model.dart';

abstract class BookRemoteDataSource {
  Future<BookDetailModel> getBookDetail(String bookId);
  Future<List<ChapterSimpleModel>> getChapterList({
    required String bookId,
    int page = 1,
    int limit = 50,
  });
  Future<ChapterModel> getChapterDetail(String chapterId);
  Future<List<CommentModel>> getBookComments({
    required String bookId,
    int page = 1,
    int limit = 20,
  });
  Future<List<CommentModel>> getChapterComments({
    required String chapterId,
    int page = 1,
    int limit = 20,
  });
  Future<CommentModel> postComment({
    required String targetId,
    required String type,
    required String content,
    String? parentId,
  });
  Future<bool> likeComment(String commentId);
  Future<bool> unlikeComment(String commentId);
  Future<bool> deleteComment(String commentId);
  Future<bool> favoriteBook(String bookId);
  Future<bool> unfavoriteBook(String bookId);
  Future<bool> rateBook({
    required String bookId,
    required int rating,
    String? review,
  });
  Future<bool> shareBook({
    required String bookId,
    required String platform,
  });
  Future<bool> reportContent({
    required String targetId,
    required String type,
    required String reason,
    String? description,
  });
  Future<String> downloadChapter(String chapterId);
  Future<String> downloadBook(String bookId);
  Future<bool> cancelDownload(String taskId);
  Future<ReadingProgress?> getReadingProgress(String bookId);
  Future<bool> updateReadingProgress({
    required String bookId,
    required String chapterId,
    required int position,
    required double progress,
  });
  Future<List<NovelSimpleModel>> getSimilarBooks({
    required String bookId,
    int limit = 10,
  });
  Future<List<NovelSimpleModel>> getAuthorOtherBooks({
    required String authorId,
    String? excludeBookId,
    int limit = 10,
  });
}

class BookRemoteDataSourceImpl implements BookRemoteDataSource {

  BookRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<BookDetailModel> getBookDetail(String bookId) async {
    try {
      final ApiResponse response = await apiClient.get('/books/$bookId');
      return BookDetailModel.fromJson(response.data['data'] as Map<String, dynamic>);

    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<ChapterSimpleModel>> getChapterList({
    required String bookId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/books/$bookId/chapters',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => ChapterSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<ChapterModel> getChapterDetail(String chapterId) async {
    try {
      final ApiResponse response = await apiClient.get('/chapters/$chapterId');
      return ChapterModel.fromJson(response.data['data'] as Map<String, dynamic>);

    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getBookComments({
    required String bookId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/books/$bookId/comments',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<CommentModel>> getChapterComments({
    required String chapterId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/chapters/$chapterId/comments',
        queryParameters: <String, dynamic>{
          'page': page,
          'limit': limit,
        },
      );
      final List<dynamic> data = response.data['data'] as List<dynamic>;
      return data.map((json) => CommentModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<CommentModel> postComment({
    required String targetId,
    required String type,
    required String content,
    String? parentId,
  }) async {
    try {
      final ApiResponse response = await apiClient.post(
        '/comments',
        data: <String, String>{
          'target_id': targetId,
          'type': type,
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );
      return CommentModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> likeComment(String commentId) async {
    try {
      await apiClient.post('/comments/$commentId/like');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> unlikeComment(String commentId) async {
    try {
      await apiClient.delete('/comments/$commentId/like');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> deleteComment(String commentId) async {
    try {
      await apiClient.delete('/comments/$commentId');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> favoriteBook(String bookId) async {
    try {
      await apiClient.post('/books/$bookId/favorite');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> unfavoriteBook(String bookId) async {
    try {
      await apiClient.delete('/books/$bookId/favorite');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> rateBook({
    required String bookId,
    required int rating,
    String? review,
  }) async {
    try {
      await apiClient.post(
        '/books/$bookId/rate',
        data: <String, Object>{
          'rating': rating,
          if (review != null) 'review': review,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> shareBook({
    required String bookId,
    required String platform,
  }) async {
    try {
      await apiClient.post(
        '/books/$bookId/share',
        data: <String, String>{
          'platform': platform,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> reportContent({
    required String targetId,
    required String type,
    required String reason,
    String? description,
  }) async {
    try {
      await apiClient.post(
        '/reports',
        data: <String, String>{
          'target_id': targetId,
          'type': type,
          'reason': reason,
          if (description != null) 'description': description,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<String> downloadChapter(String chapterId) async {
    try {
      final ApiResponse response = await apiClient.post(
        '/chapters/$chapterId/download',
      );
      return response.data['data']['task_id'] as String;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<String> downloadBook(String bookId) async {
    try {
      final ApiResponse response = await apiClient.post(
        '/books/$bookId/download',
      );
      return response.data['data']['task_id'] as String;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> cancelDownload(String taskId) async {
    try {
      await apiClient.delete('/downloads/$taskId');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    try {
      final ApiResponse response = await apiClient.get('/books/$bookId/progress');
      final Map<String, dynamic> data = response.data['data'] as Map<String, dynamic>;
      return data != null ? ReadingProgress.fromJson(data) : null;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> updateReadingProgress({
    required String bookId,
    required String chapterId,
    required int position,
    required double progress,
  }) async {
    try {
      await apiClient.put(
        '/books/$bookId/progress',
        data: <String, Object>{
          'chapter_id': chapterId,
          'position': position,
          'progress': progress,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<List<NovelSimpleModel>> getSimilarBooks({
    required String bookId,
    int limit = 10,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/books/$bookId/similar',
        queryParameters: <String, dynamic>{
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
  Future<List<NovelSimpleModel>> getAuthorOtherBooks({
    required String authorId,
    String? excludeBookId,
    int limit = 10,
  }) async {
    try {
      final ApiResponse response = await apiClient.get(
        '/authors/$authorId/books',
        queryParameters: <String, dynamic>{
          if (excludeBookId != null) 'exclude': excludeBookId,
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
}