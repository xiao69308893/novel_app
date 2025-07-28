import 'dart:convert';
import '../../../core/api/api_client.dart';
import '../../../core/error/exceptions.dart';
import '../../../shared/models/chapter_model.dart';
import '../../../shared/models/novel_model.dart';
import '../../domain/entities/reader_config.dart';
import '../../domain/entities/reading_session.dart';

/// 阅读器远程数据源接口
abstract class ReaderRemoteDataSource {
  /// 获取章节内容
  Future<ChapterModel> getChapter({
    required String novelId,
    required String chapterId,
  });

  /// 获取章节列表
  Future<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
    int? page,
    int? pageSize,
  });

  /// 获取相邻章节信息
  Future<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String currentChapterId,
  });

  /// 保存阅读进度到服务器
  Future<void> saveReadingProgress({
    required String novelId,
    required String chapterId,
    required int position,
    required double progress,
  });

  /// 获取阅读进度
  Future<ReadingProgressModel?> getReadingProgress({
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
    int? page,
    int? pageSize,
  });

  /// 同步阅读器配置到服务器
  Future<void> syncReaderConfig({
    required ReaderConfig config,
  });

  /// 从服务器获取阅读器配置
  Future<ReaderConfig?> getReaderConfig();

  /// 购买章节
  Future<PurchaseResultModel> purchaseChapter({
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

  const ReaderRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<ChapterModel> getChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters/$chapterId',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ChapterModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? '获取章节失败',
            code: data['code']?.toString(),
          );
        }
      } else if (response.statusCode == 401) {
        throw UnauthorizedException(message: '用户未登录');
      } else if (response.statusCode == 403) {
        throw PermissionException(message: '没有访问权限');
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: '章节不存在');
      } else if (response.statusCode == 402) {
        throw PaymentRequiredException(message: '章节需要付费');
      } else {
        throw ServerException(
          message: '服务器错误',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<List<ChapterSimpleModel>> getChapterList({
    required String novelId,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, String>{
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'pageSize': pageSize.toString(),
      };

      final response = await apiClient.get(
        '/novels/$novelId/chapters',
        queryParameters: queryParams,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> chaptersJson = data['data']['list'] ?? [];
          return chaptersJson
              .map((json) => ChapterSimpleModel.fromJson(json))
              .toList();
        } else {
          throw ServerException(
            message: data['message'] ?? '获取章节列表失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '获取章节列表失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<Map<String, ChapterSimpleModel?>> getAdjacentChapters({
    required String novelId,
    required String currentChapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/novels/$novelId/chapters/$currentChapterId/adjacent',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final adjacentData = data['data'];
          return {
            'previous': adjacentData['previous'] != null
                ? ChapterSimpleModel.fromJson(adjacentData['previous'])
                : null,
            'next': adjacentData['next'] != null
                ? ChapterSimpleModel.fromJson(adjacentData['next'])
                : null,
          };
        } else {
          throw ServerException(
            message: data['message'] ?? '获取相邻章节失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '获取相邻章节失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
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
      final requestBody = {
        'novelId': novelId,
        'chapterId': chapterId,
        'position': position,
        'progress': progress,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await apiClient.post(
        '/reader/progress',
        body: json.encode(requestBody),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(
            message: data['message'] ?? '保存阅读进度失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '保存阅读进度失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<ReadingProgressModel?> getReadingProgress({
    required String novelId,
  }) async {
    try {
      final response = await apiClient.get(
        '/reader/progress/$novelId',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ReadingProgressModel.fromJson(data['data']);
        } else {
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException(
          message: '获取阅读进度失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
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
      final requestBody = {
        'novelId': novelId,
        'chapterId': chapterId,
        'position': position,
        if (note != null) 'note': note,
        if (content != null) 'content': content,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      final response = await apiClient.post(
        '/reader/bookmarks',
        body: json.encode(requestBody),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return BookmarkModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? '添加书签失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '添加书签失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBookmark({
    required String bookmarkId,
  }) async {
    try {
      final response = await apiClient.delete(
        '/reader/bookmarks/$bookmarkId',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(
            message: data['message'] ?? '删除书签失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '删除书签失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<List<BookmarkModel>> getBookmarks({
    required String novelId,
    String? chapterId,
    int? page,
    int? pageSize,
  }) async {
    try {
      final queryParams = <String, String>{
        'novelId': novelId,
        if (chapterId != null) 'chapterId': chapterId,
        if (page != null) 'page': page.toString(),
        if (pageSize != null) 'pageSize': pageSize.toString(),
      };

      final response = await apiClient.get(
        '/reader/bookmarks',
        queryParameters: queryParams,
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> bookmarksJson = data['data']['list'] ?? [];
          return bookmarksJson
              .map((json) => BookmarkModel.fromJson(json))
              .toList();
        } else {
          throw ServerException(
            message: data['message'] ?? '获取书签列表失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '获取书签列表失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<void> syncReaderConfig({
    required ReaderConfig config,
  }) async {
    try {
      final requestBody = config.toJson();

      final response = await apiClient.post(
        '/reader/config',
        body: json.encode(requestBody),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] != true) {
          throw ServerException(
            message: data['message'] ?? '同步配置失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '同步配置失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<ReaderConfig?> getReaderConfig() async {
    try {
      final response = await apiClient.get(
        '/reader/config',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return ReaderConfig.fromJson(data['data']);
        } else {
          return null;
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw ServerException(
          message: '获取配置失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<PurchaseResultModel> purchaseChapter({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final requestBody = {
        'novelId': novelId,
        'chapterId': chapterId,
      };

      final response = await apiClient.post(
        '/payment/chapters/purchase',
        body: json.encode(requestBody),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return PurchaseResultModel.fromJson(data['data']);
        } else {
          throw ServerException(
            message: data['message'] ?? '购买章节失败',
            code: data['code']?.toString(),
          );
        }
      } else {
        throw ServerException(
          message: '购买章节失败',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ConnectionException(message: '网络连接失败: ${e.toString()}');
    }
  }

  @override
  Future<bool> checkChapterPurchaseStatus({
    required String novelId,
    required String chapterId,
  }) async {
    try {
      final response = await apiClient.get(
        '/payment/chapters/$novelId/$chapterId/status',
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['purchased'] == true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// 获取认证头部信息
  Future<Map<String, String>> _getAuthHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 这里应该从认证管理器或本地存储获取token
    // final token = await AuthManager.getToken();
    // if (token != null) {
    //   headers['Authorization'] = 'Bearer $token';
    // }

    return headers;
  }
}

/// 阅读进度模型
class ReadingProgressModel {
  final String id;
  final String userId;
  final String novelId;
  final String chapterId;
  final int position;
  final double progress;
  final DateTime updatedAt;

  const ReadingProgressModel({
    required this.id,
    required this.userId,
    required this.novelId,
    required this.chapterId,
    required this.position,
    required this.progress,
    required this.updatedAt,
  });

  factory ReadingProgressModel.fromJson(Map<String, dynamic> json) {
    return ReadingProgressModel(
      id: json['id'],
      userId: json['userId'],
      novelId: json['novelId'],
      chapterId: json['chapterId'],
      position: json['position'],
      progress: (json['progress'] as num).toDouble(),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'novelId': novelId,
      'chapterId': chapterId,
      'position': position,
      'progress': progress,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// 购买结果模型
class PurchaseResultModel {
  final bool success;
  final String message;
  final String? transactionId;
  final int? remainingBalance;

  const PurchaseResultModel({
    required this.success,
    required this.message,
    this.transactionId,
    this.remainingBalance,
  });

  factory PurchaseResultModel.fromJson(Map<String, dynamic> json) {
    return PurchaseResultModel(
      success: json['success'],
      message: json['message'],
      transactionId: json['transactionId'],
      remainingBalance: json['remainingBalance'],
    );
  }
}