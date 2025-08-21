import '../../../../core/api/api_client.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/repositories/reader_repository.dart' hide ReadingProgress;

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

      if (response.statusCode == 200) {
        return ChapterModel.fromMap(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '章节加载失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ChapterSimpleModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '章节列表加载失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<NovelModel> getNovelInfo({required String novelId}) async {
    try {
      final response = await apiClient.get('/novels/$novelId');

      if (response.statusCode == 200) {
        return NovelModel.fromMap(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '小说信息加载失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? '保存阅读进度失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data != null ? ReadingProgress.fromMap(data) : null;
      } else if (response.statusCode == 404) {
        return null; // 没有阅读进度
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取阅读进度失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 201) {
        return BookmarkModel.fromMap(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '添加书签失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> deleteBookmark({required String bookmarkId}) async {
    try {
      final response = await apiClient.delete('/bookmarks/$bookmarkId');

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? '删除书签失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => BookmarkModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取书签列表失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? '更新阅读时长失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
      );
    }
  }

  @override
  Future<ReadingStats> getReadingStats() async {
    try {
      final response = await apiClient.get('/reading/stats');

      if (response.statusCode == 200) {
        return ReadingStats.fromMap(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取阅读统计失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => ChapterSimpleModel.fromMap(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? '搜索章节失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return {
          'previous': data['previous'] != null 
              ? ChapterSimpleModel.fromMap(data['previous']) 
              : null,
          'next': data['next'] != null 
              ? ChapterSimpleModel.fromMap(data['next']) 
              : null,
        };
      } else {
        throw ServerException(
          message: response.data['message'] ?? '获取相邻章节失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? '购买章节失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
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

      if (response.statusCode == 200) {
        return response.data['data']['purchased'] == true;
      } else {
        throw ServerException(
          message: response.data['message'] ?? '检查购买状态失败',
          statusCode: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: '网络请求失败：${e.toString()}',
        statusCode: '500',
      );
    }
  }
}