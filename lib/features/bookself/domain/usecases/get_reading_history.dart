import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reading_history.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取阅读历史参数
class GetReadingHistoryParams extends Equatable {
  final int page;
  final int limit;

  const GetReadingHistoryParams({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object> get props => [page, limit];
}

/// 获取阅读历史用例
class GetReadingHistory implements UseCase<List<ReadingHistory>, GetReadingHistoryParams> {
  final BookshelfRepository repository;

  const GetReadingHistory(this.repository);

  @override
  Future<Either<Failure, List<ReadingHistory>>> call(GetReadingHistoryParams params) async {
    return await repository.getReadingHistory(
      page: params.page,
      limit: params.limit,
    );
  }
}

/// 清空阅读历史用例
class ClearReadingHistory implements UseCase<void, NoParams> {
  final BookshelfRepository repository;

  const ClearReadingHistory(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearReadingHistory();
  }
}

/// 删除历史记录用例
class DeleteHistoryItem implements UseCase<void, String> {
  final BookshelfRepository repository;

  const DeleteHistoryItem(this.repository);

  @override
  Future<Either<Failure, void>> call(String historyId) async {
    return await repository.deleteHistoryItem(historyId);
  }
}