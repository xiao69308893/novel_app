import 'package:novel_app/core/errors/exceptions.dart';

import '../../../../core/api/api_client.dart';
import '../../../../shared/models/chapter_model.dart' hide ReadingProgress;
import '../../../../shared/models/novel_model.dart';
import '../../domain/repositories/reader_repository.dart';

/// 阅读器远程数据源接口
abstract class ReaderRemoteDataSource {
  /// 加载章节内容
  Future<ChapterModel> loadChapter({
    required String novelId,
    required String chapterId,
  });

  /// 获取章节列表
  Future<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
  });

  /// 获取小说信息
  Future<NovelModel> getNovelInfo({
    required String novelId,
  });

  /// 保存阅读进度
  Future<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  });

  /// 获取阅读进度
  Future<ReadingProgress?> getReadingProgress({
    required String novelId,
  });

  /// 添加书签
  Future<BookmarkModel> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
    String? content,
  });

  /// 删除书签
  Future<void> deleteBookmark({
    required String bookmarkId,
  });

  /// 获取书签列表
  Future<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  });

  /// 更新阅读时长
  Future<void> updateReadingTime({
    required String novelId,
    required int minutes,
  });

  /// 获取阅读统计
  Future<ReadingStats> getReadingStats();

  /// 搜索章节
  Future<List<ChapterSimpleModel>> searchChapters({
    required String novelId,
    required String keyword,
  });

  /// 获取相邻章节
  Future<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String chapterId,
  });

  /// 购买章节
  Future<void> purchaseChapter({
    required String novelId,
    required String chapterId,
  });

  /// 检查章节购买状态
  Future<bool> checkChapterPurchaseStatus({
    required String novelId,
    required String chapterId,
  });
}

/// 阅读器远程数据源实现
class ReaderRemoteDataSourceImpl implements ReaderRemoteDataSource {
  final ApiClient apiClient;

  const ReaderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ChapterModel> loadChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters/$chapterId',
      );

      if (response.code == 200) {
        final Map<String, dynamic> data =
            response.data['data'] as Map<String, dynamic>;
        return ChapterModel.fromJson(data);
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '章节加载失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters',
        queryParameters: {
          'simple': true, // 获取简化版章节列表
        },
      );

      if (response.code == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;

        return data.map((json) => ChapterSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '章节列表加载失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<NovelModel> getNovelInfo({required String novelId}) async {
    try {
      final response = await apiClient.get('/novels/$novelId');

      if (response.code == 200) {
        return NovelModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '小说信息加载失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  }) async {
    try {
      final response = await apiClient.post(
        '/reading/progress',
        data: {
          'novelId': novelId,
          'chapterId': chapterId,
          'position': position,
          'progress': progress,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.code != 200) {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '保存阅读进度失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<ReadingProgress?> getReadingProgress({
    required String novelId,
  }) async {
    try {
      final response = await apiClient.get(
        '/reading/progress/$novelId',
      );

      if (response.code == 200) {
        final data = response.data['data'];
        return data != null ? ReadingProgress.fromMap(data  as Map<String, dynamic>) : null;
      } else if (response.code == 404) {
        return null; // 没有阅读进度
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '获取阅读进度失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<BookmarkModel> addBookmark({
    required String novelId,
    required String chapterId,
    required int position,
    String? note,
    String? content,
  }) async {
    try {
      final response = await apiClient.post(
        '/bookmarks',
        data: {
          'novelId': novelId,
          'chapterId': chapterId,
          'position': position,
          'note': note,
          'content': content,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      if (response.code == 201) {
        return BookmarkModel.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '添加书签失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<void> deleteBookmark({required String bookmarkId}) async {
    try {
      final response = await apiClient.delete('/bookmarks/$bookmarkId');

      if (response.code != 200) {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '删除书签失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
  }) async {
    try {
      final queryParams = <String, dynamic>{'novelId': novelId};
      if (chapterId != null) {
        queryParams['chapterId'] = chapterId;
      }

      final response = await apiClient.get(
        '/bookmarks',
        queryParameters: queryParams,
      );

      if (response.code == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;

        return data.map((json) => BookmarkModel.fromJson(json as Map<String, dynamic>)).toList();
      } else if (response.code == 404) {
        return []; // 没有书签，返回空列表
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '获取书签列表失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<void> updateReadingTime({
    required String novelId,
    required int minutes,
  }) async {
    try {
      final response = await apiClient.post(
        '/reading/time',
        data: {
          'novelId': novelId,
          'minutes': minutes,
          'date': DateTime.now().toIso8601String().split('T')[0],
        },
      );

      if (response.code != 200) {
        throw ServerException(
          message: (response.data['message'] as String)?? '更新阅读时长失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<ReadingStats> getReadingStats() async {
    try {
      final response = await apiClient.get('/reading/stats');

      if (response.code == 200) {
        return ReadingStats.fromMap(response.data['data'] as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '获取阅读统计失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<List<ChapterSimpleModel>> searchChapters({
    required String novelId,
    required String keyword,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters/search',
        queryParameters: {
          'keyword': keyword,
        },
      );

      if (response.code == 200) {
        final List<dynamic> data = response.data['data'] as List<dynamic>;
        return data.map((json) => ChapterSimpleModel.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '搜索章节失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters/$chapterId/adjacent',
      );

      if (response.code == 200) {
        final data = response.data['data'];
        return {
          'previous': data['previous'] != null
              ? ChapterSimpleModel.fromJson(data['previous'] as Map<String, dynamic>)
              : null,
          'next': data['next'] != null
              ? ChapterSimpleModel.fromJson(data['next'] as Map<String, dynamic>)
              : null,
        };
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '获取相邻章节失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<void> purchaseChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.post(
        '/purchases/chapters',
        data: {
          'novelId': novelId,
          'chapterId': chapterId,
        },
      );

      if (response.code != 200) {
        throw ServerException(
          message: (response.data['message'] as String)?? '购买章节失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }

  @override
  Future<bool> checkChapterPurchaseStatus({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/purchases/chapters/status',
        queryParameters: {
          'novelId': novelId,
          'chapterId': chapterId,
        },
      );

      if (response.code == 200) {
        return response.data['data']['purchased'] == true;
      } else {
        throw ServerException(
          message: (response.data['message'] as String?) ?? '检查购买状态失败',
          code: response.code.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        code: '500',
      );
    }
  }
}
