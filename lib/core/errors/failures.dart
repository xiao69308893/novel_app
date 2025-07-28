import 'package:equatable/equatable.dart';

/// 失败类基类
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  List<Object?> get props => [message, code, details];
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 网络连接失败
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    String message = '网络连接失败，请检查网络设置',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    String message = '权限不足',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 数据解析失败
class ParseFailure extends Failure {
  const ParseFailure({
    String message = '数据解析失败',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 文件操作失败
class FileFailure extends Failure {
  const FileFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 章节不存在失败
class ChapterNotFoundFailure extends Failure {
  const ChapterNotFoundFailure({
    String message = '章节不存在或已被删除',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 章节需要付费失败
class ChapterPaymentRequiredFailure extends Failure {
  const ChapterPaymentRequiredFailure({
    String message = '该章节需要付费阅读',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 用户未登录失败
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = '用户未登录，请先登录',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 请求超时失败
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = '请求超时，请稍后重试',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 书签操作失败
class BookmarkFailure extends Failure {
  const BookmarkFailure({
    required String message,
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 阅读进度保存失败
class ProgressFailure extends Failure {
  const ProgressFailure({
    String message = '阅读进度保存失败',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 配置保存失败
class ConfigFailure extends Failure {
  const ConfigFailure({
    String message = '配置保存失败',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 存储空间不足失败
class StorageFailure extends Failure {
  const StorageFailure({
    String message = '存储空间不足',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 版本不匹配失败
class VersionMismatchFailure extends Failure {
  const VersionMismatchFailure({
    String message = '应用版本过低，请更新到最新版本',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 内容审核失败
class ContentModerationFailure extends Failure {
  const ContentModerationFailure({
    String message = '内容正在审核中，暂时无法访问',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 地区限制失败
class RegionRestrictedFailure extends Failure {
  const RegionRestrictedFailure({
    String message = '该内容在您的地区不可用',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = '发生未知错误，请稍后重试',
    String? code,
    dynamic details,
  }) : super(message: message, code: code, details: details);
}