// 管理阅读进度用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/book_repository.dart';

class UpdateReadingProgressUseCase implements UseCase<bool, UpdateReadingProgressParams> {
  final BookRepository repository;

  UpdateReadingProgressUseCase(this.repository);

  @override
  Future<Either<AppError, bool>> call(UpdateReadingProgressParams params) async {
    // 参数验证
    if (params.bookId.isEmpty) {
      return Left(DataError.validation(message: '小说ID不能为空'));
    }
    if (params.chapterId.isEmpty) {
      return Left(DataError.validation(message: '章节ID不能为空'));
    }
    if (params.position < 0) {
      return Left(DataError.validation(message: '阅读位置不能为负数'));
    }
    if (params.progress < 0 || params.progress > 1) {
      return Left(DataError.validation(message: '阅读进度必须在0-1之间'));
    }

    return await repository.updateReadingProgress(
      bookId: params.bookId,
      chapterId: params.chapterId,
      position: params.position,
      progress: params.progress,
    );
  }
}

class UpdateReadingProgressParams extends Equatable {
  final String bookId;
  final String chapterId;
  final int position;
  final double progress;

  const UpdateReadingProgressParams({
    required this.bookId,
    required this.chapterId,
    required this.position,
    required this.progress,
  });

  @override
  List<Object> get props => [bookId, chapterId, position, progress];
}

class GetReadingProgressUseCase implements UseCase<ReadingProgress?, GetReadingProgressParams> {
  final BookRepository repository;

  GetReadingProgressUseCase(this.repository);

  @override
  Future<Either<AppError, ReadingProgress?>> call(GetReadingProgressParams params) async {
    if (params.bookId.isEmpty) {
      return Left(DataError.validation(message: '小说ID不能为空'));
    }

    return await repository.getReadingProgress(params.bookId);
  }
}

class GetReadingProgressParams extends Equatable {
  final String bookId;

  const GetReadingProgressParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}