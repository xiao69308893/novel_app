import 'package:dartz/dartz.dart';
import '../errors/app_error.dart';

/// 通用结果类型定义
typedef ResultFuture<T> = Future<Either<AppError, T>>;
typedef ResultVoid = Future<Either<AppError, void>>;
typedef DataMap = Map<String, dynamic>;