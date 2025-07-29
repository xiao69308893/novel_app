/// 自定义异常类
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message';
}

/// 服务器异常
class ServerException extends AppException {
  const ServerException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 缓存异常
class CacheException extends AppException {
  const CacheException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 网络异常
class NetworkException extends AppException {
  const NetworkException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 数据解析异常
class ParseException extends AppException {
  const ParseException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 权限异常
class PermissionException extends AppException {
  const PermissionException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 存储异常
class StorageException extends AppException {
  const StorageException({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}