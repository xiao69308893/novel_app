import 'package:equatable/equatable.dart';

/// 失败类基类
abstract class Failure extends Equatable {

  const Failure({
    required this.message,
    this.code,
    this.details,
  });
  final String message;
  final String? code;
  final dynamic details;

  @override
  List<Object?> get props => <Object?>[message, code, details];
}

/// 服务器失败
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 网络连接失败
class ConnectionFailure extends Failure {
  const ConnectionFailure({
    super.message = '网络连接失败，请检查网络设置',
    super.code,
    super.details,
  });
}

/// 缓存失败
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 权限失败
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = '权限不足',
    super.code,
    super.details,
  });
}

/// 数据解析失败
class ParseFailure extends Failure {
  const ParseFailure({
    super.message = '数据解析失败',
    super.code,
    super.details,
  });
}

/// 文件操作失败
class FileFailure extends Failure {
  const FileFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 章节不存在失败
class ChapterNotFoundFailure extends Failure {
  const ChapterNotFoundFailure({
    super.message = '章节不存在或已被删除',
    super.code,
    super.details,
  });
}

/// 章节需要付费失败
class ChapterPaymentRequiredFailure extends Failure {
  const ChapterPaymentRequiredFailure({
    super.message = '该章节需要付费阅读',
    super.code,
    super.details,
  });
}

/// 用户未登录失败
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = '用户未登录，请先登录',
    super.code,
    super.details,
  });
}

/// 请求超时失败
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = '请求超时，请稍后重试',
    super.code,
    super.details,
  });
}

/// 书签操作失败
class BookmarkFailure extends Failure {
  const BookmarkFailure({
    required super.message,
    super.code,
    super.details,
  });
}

/// 阅读进度保存失败
class ProgressFailure extends Failure {
  const ProgressFailure({
    super.message = '阅读进度保存失败',
    super.code,
    super.details,
  });
}

/// 配置保存失败
class ConfigFailure extends Failure {
  const ConfigFailure({
    super.message = '配置保存失败',
    super.code,
    super.details,
  });
}

/// 存储空间不足失败
class StorageFailure extends Failure {
  const StorageFailure({
    super.message = '存储空间不足',
    super.code,
    super.details,
  });
}

/// 版本不匹配失败
class VersionMismatchFailure extends Failure {
  const VersionMismatchFailure({
    super.message = '应用版本过低，请更新到最新版本',
    super.code,
    super.details,
  });
}

/// 内容审核失败
class ContentModerationFailure extends Failure {
  const ContentModerationFailure({
    super.message = '内容正在审核中，暂时无法访问',
    super.code,
    super.details,
  });
}

/// 地区限制失败
class RegionRestrictedFailure extends Failure {
  const RegionRestrictedFailure({
    super.message = '该内容在您的地区不可用',
    super.code,
    super.details,
  });
}

/// 未知失败
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = '发生未知错误，请稍后重试',
    super.code,
    super.details,
  });
}