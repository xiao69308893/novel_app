/// 自定义异常类
abstract class AppException implements Exception {

  const AppException({
    required this.message,
    this.code,
    this.details,
  });
  final String message;
  final String? code;
  final dynamic details;

  @override
  String toString() => 'AppException: $message';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.details,
  });
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.details,
  });
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
  });
}

/// 数据解析异常
class ParseException extends AppException {
  const ParseException({
    required super.message,
    super.code,
    super.details,
  });
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.details,
  });
}

/// 存储异常
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.details,
  });
}