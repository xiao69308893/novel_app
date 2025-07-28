import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/bookshelf_repository.dart';

/// 添加收藏用例
class AddToFavorites implements UseCase<void, String> {
  final BookshelfRepository repository;

  const AddToFavorites(this.repository);

  @override
  Future<Either<Failure, void>> call(String novelId) async {
    return await repository.addToFavorites(novelId);
  }
}

/// 移除收藏用例
class RemoveFromFavorites implements UseCase<void, String> {
  final BookshelfRepository repository;

  const RemoveFromFavorites(this.repository);

  @override
  Future<Either<Failure, void>> call(String novelId) async {
    return await repository.removeFromFavorites(novelId);
  }
}

/// 检查收藏状态用例
class CheckFavoriteStatus implements UseCase<bool, String> {
  final BookshelfRepository repository;

  const CheckFavoriteStatus(this.repository);

  @override
  Future<Either<Failure, bool>> call(String novelId) async {
    return await repository.isFavorite(novelId);
  }
}

/// 批量收藏操作参数
class BatchFavoriteParams extends Equatable {
  final List<String>? addIds;
  final List<String>? removeIds;

  const BatchFavoriteParams({
    this.addIds,
    this.removeIds,
  });

  @override
  List<Object?> get props => [addIds, removeIds];
}

/// 批量收藏操作用例
class BatchFavoriteOperation implements UseCase<void, BatchFavoriteParams> {
  final BookshelfRepository repository;

  const BatchFavoriteOperation(this.repository);

  @override
  Future<Either<Failure, void>> call(BatchFavoriteParams params) async {
    return await repository.batchFavoriteOperation(
      addIds: params.addIds,
      removeIds: params.removeIds,
    );
  }
}
