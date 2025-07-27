import '../utils/logger.dart';

/// API响应状态枚举
enum ApiStatus {
  success,
  error,
  loading,
  empty,
}

/// 通用API响应模型
class ApiResponse<T> {
  /// 响应状态
  final ApiStatus status;
  
  /// 响应数据
  final T? data;
  
  /// 错误信息
  final String? message;
  
  /// 错误代码
  final int? code;
  
  /// 是否成功
  final bool success;
  
  /// 额外信息
  final Map<String, dynamic>? extra;
  
  /// 时间戳
  final DateTime timestamp;

  ApiResponse._({
    required this.status,
    this.data,
    this.message,
    this.code,
    required this.success,
    this.extra,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 成功响应
  factory ApiResponse.success(
    T data, [
    String? message,
    Map<String, dynamic>? extra,
  ]) {
    return ApiResponse._(
      status: ApiStatus.success,
      data: data,
      message: message ?? '操作成功',
      success: true,
      extra: extra,
    );
  }

  /// 错误响应
  factory ApiResponse.error(
    String message, {
    int? code,
    T? data,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse._(
      status: ApiStatus.error,
      data: data,
      message: message,
      code: code,
      success: false,
      extra: extra,
    );
  }

  /// 加载中响应
  factory ApiResponse.loading([String? message]) {
    return ApiResponse._(
      status: ApiStatus.loading,
      message: message ?? '加载中...',
      success: false,
    );
  }

  /// 空数据响应
  factory ApiResponse.empty([String? message]) {
    return ApiResponse._(
      status: ApiStatus.empty,
      message: message ?? '暂无数据',
      success: false,
    );
  }

  /// 从JSON创建响应
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    try {
      final success = json['success'] as bool? ?? 
                     (json['code'] == 200 || json['code'] == '200' || json['status'] == 'success');
      final code = _parseCode(json['code'] ?? json['status_code']);
      final message = json['message'] as String? ?? 
                     json['msg'] as String? ?? 
                     (success ? '操作成功' : '操作失败');

      T? data;
      if (success && json['data'] != null && fromJsonT != null) {
        try {
          data = fromJsonT(json['data']);
        } catch (e) {
          Logger.error('解析响应数据失败', e);
          return ApiResponse.error('数据解析失败', code: code);
        }
      } else if (success && fromJsonT != null) {
        // 如果没有data字段，尝试直接解析整个json
        try {
          data = fromJsonT(json);
        } catch (e) {
          Logger.debug('JSON', '直接解析失败，跳过数据解析');
        }
      }

      return ApiResponse._(
        status: success ? ApiStatus.success : ApiStatus.error,
        data: data,
        message: message,
        code: code,
        success: success,
        extra: _extractExtra(json),
      );
    } catch (e) {
      Logger.error('解析API响应失败', e);
      return ApiResponse.error('响应解析失败: $e');
    }
  }

  /// 解析状态码
  static int? _parseCode(dynamic code) {
    if (code == null) return null;
    if (code is int) return code;
    if (code is String) return int.tryParse(code);
    return null;
  }

  /// 提取额外信息
  static Map<String, dynamic>? _extractExtra(Map<String, dynamic> json) {
    final extra = <String, dynamic>{};
    
    // 提取分页信息
    if (json.containsKey('pagination')) {
      extra['pagination'] = json['pagination'];
    }
    
    // 提取总数信息
    if (json.containsKey('total')) {
      extra['total'] = json['total'];
    }
    
    // 提取当前页信息
    if (json.containsKey('page')) {
      extra['page'] = json['page'];
    }
    
    // 提取每页大小
    if (json.containsKey('page_size')) {
      extra['page_size'] = json['page_size'];
    }
    
    // 提取是否有更多数据
    if (json.containsKey('has_more')) {
      extra['has_more'] = json['has_more'];
    }
    
    return extra.isNotEmpty ? extra : null;
  }

  /// 转换数据类型
  ApiResponse<R> map<R>(R Function(T) mapper) {
    if (data == null) {
      return ApiResponse._(
        status: status,
        data: null,
        message: message,
        code: code,
        success: success,
        extra: extra,
        timestamp: timestamp,
      );
    }
    
    try {
      final newData = mapper(data!);
      return ApiResponse._(
        status: status,
        data: newData,
        message: message,
        code: code,
        success: success,
        extra: extra,
        timestamp: timestamp,
      );
    } catch (e) {
      Logger.error('响应数据转换失败', e);
      return ApiResponse.error('数据转换失败: $e');
    }
  }

  /// 复制并修改响应
  ApiResponse<T> copyWith({
    ApiStatus? status,
    T? data,
    String? message,
    int? code,
    bool? success,
    Map<String, dynamic>? extra,
  }) {
    return ApiResponse._(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
      code: code ?? this.code,
      success: success ?? this.success,
      extra: extra ?? this.extra,
      timestamp: timestamp,
    );
  }

  /// 是否为成功状态
  bool get isSuccess => status == ApiStatus.success && success;

  /// 是否为错误状态
  bool get isError => status == ApiStatus.error;

  /// 是否为加载状态
  bool get isLoading => status == ApiStatus.loading;

  /// 是否为空数据状态
  bool get isEmpty => status == ApiStatus.empty;

  /// 是否有数据
  bool get hasData => data != null;

  /// 获取分页信息
  PaginationInfo? get pagination {
    if (extra?['pagination'] != null) {
      return PaginationInfo.fromJson(extra!['pagination']);
    }
    
    // 从extra中直接提取分页信息
    final page = extra?['page'] as int?;
    final pageSize = extra?['page_size'] as int?;
    final total = extra?['total'] as int?;
    final hasMore = extra?['has_more'] as bool?;
    
    if (page != null || pageSize != null || total != null) {
      return PaginationInfo(
        page: page ?? 1,
        pageSize: pageSize ?? 20,
        total: total ?? 0,
        hasMore: hasMore,
      );
    }
    
    return null;
  }

  /// 转换为Map
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'data': data,
      'message': message,
      'code': code,
      'success': success,
      'extra': extra,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'ApiResponse{status: $status, success: $success, message: $message, code: $code, hasData: $hasData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiResponse<T> &&
        other.status == status &&
        other.data == data &&
        other.message == message &&
        other.code == code &&
        other.success == success;
  }

  @override
  int get hashCode {
    return status.hashCode ^
        data.hashCode ^
        message.hashCode ^
        code.hashCode ^
        success.hashCode;
  }
}

/// 分页信息模型
class PaginationInfo {
  /// 当前页码
  final int page;
  
  /// 每页大小
  final int pageSize;
  
  /// 总记录数
  final int total;
  
  /// 是否有更多数据
  final bool? hasMore;
  
  /// 总页数
  int get totalPages => (total / pageSize).ceil();
  
  /// 是否为第一页
  bool get isFirstPage => page <= 1;
  
  /// 是否为最后一页
  bool get isLastPage => page >= totalPages;
  
  /// 是否有下一页
  bool get hasNextPage => hasMore ?? !isLastPage;
  
  /// 是否有上一页
  bool get hasPreviousPage => !isFirstPage;

  const PaginationInfo({
    required this.page,
    required this.pageSize,
    required this.total,
    this.hasMore,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int? ?? json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? json['per_page'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      hasMore: json['has_more'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'total': total,
      'total_pages': totalPages,
      'has_more': hasMore,
      'is_first_page': isFirstPage,
      'is_last_page': isLastPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }

  @override
  String toString() {
    return 'PaginationInfo{page: $page, pageSize: $pageSize, total: $total, hasMore: $hasMore}';
  }
}

/// 列表响应模型
class ListResponse<T> {
  final List<T> items;
  final PaginationInfo? pagination;
  final Map<String, dynamic>? extra;

  const ListResponse({
    required this.items,
    this.pagination,
    this.extra,
  });

  factory ListResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] as List? ?? 
                     json['data'] as List? ?? 
                     json['list'] as List? ?? 
                     [];

    final items = itemsJson
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    PaginationInfo? pagination;
    if (json.containsKey('pagination')) {
      pagination = PaginationInfo.fromJson(json['pagination']);
    } else {
      // 尝试从根级别提取分页信息
      final page = json['page'] as int?;
      final pageSize = json['page_size'] as int? ?? json['per_page'] as int?;
      final total = json['total'] as int?;
      final hasMore = json['has_more'] as bool?;
      
      if (page != null || pageSize != null || total != null) {
        pagination = PaginationInfo(
          page: page ?? 1,
          pageSize: pageSize ?? items.length,
          total: total ?? items.length,
          hasMore: hasMore,
        );
      }
    }

    return ListResponse(
      items: items,
      pagination: pagination,
      extra: ApiResponse._extractExtra(json),
    );
  }

  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'pagination': pagination?.toJson(),
      'extra': extra,
    };
  }

  /// 是否为空列表
  bool get isEmpty => items.isEmpty;

  /// 是否有数据
  bool get isNotEmpty => items.isNotEmpty;

  /// 列表长度
  int get length => items.length;

  /// 添加更多数据（用于分页加载）
  ListResponse<T> addMore(List<T> moreItems, [PaginationInfo? newPagination]) {
    return ListResponse(
      items: [...items, ...moreItems],
      pagination: newPagination ?? pagination,
      extra: extra,
    );
  }

  @override
  String toString() {
    return 'ListResponse{itemCount: ${items.length}, pagination: $pagination}';
  }
}