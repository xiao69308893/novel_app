import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_history.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取阅读历史参数
class GetReadingHistoryParams extends Equatable {

  const GetReadingHistoryParams({
    this.page = 1,
    this.limit = 20,
  });
  final int page;
  final int limit;

  @override
  List<Object> get props => <Object>[page, limit];
}

/// 获取阅读历史用例
class GetReadingHistory implements UseCase<List<ReadingHistory>, GetReadingHistoryParams> {

  GetReadingHistory(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, List<ReadingHistory>>> call(GetReadingHistoryParams params) async => repository.getReadingHistory(
      page: params.page,
      limit: params.limit,
    );
}

/// 清空阅读历史用例
class ClearReadingHistory implements UseCase<void, NoParams> {

  ClearReadingHistory(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(NoParams params) async => repository.clearReadingHistory();
}

/// 删除历史记录项用例
class DeleteHistoryItem implements UseCase<void, String> {

  DeleteHistoryItem(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(String historyId) async => repository.deleteHistoryItem(historyId);
}