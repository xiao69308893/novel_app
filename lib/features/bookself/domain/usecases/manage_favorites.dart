import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/bookshelf_repository.dart';

/// 添加到收藏用例
class AddToFavorites implements UseCase<void, AddToFavoritesParams> {
  final BookshelfRepository repository;

  AddToFavorites(this.repository);

  @override
  Future<Either<AppError, void>> call(AddToFavoritesParams params) async {
    return await repository.addToFavorites(params.novelId);
  }
}

/// 从收藏移除用例
class RemoveFromFavorites implements UseCase<void, RemoveFromFavoritesParams> {
  final BookshelfRepository repository;

  RemoveFromFavorites(this.repository);

  @override
  Future<Either<AppError, void>> call(RemoveFromFavoritesParams params) async {
    return await repository.removeFromFavorites(params.novelId);
  }
}

/// 检查收藏状态用例
class CheckFavoriteStatus implements UseCase<bool, CheckFavoriteStatusParams> {
  final BookshelfRepository repository;

  CheckFavoriteStatus(this.repository);

  @override
  Future<Either<AppError, bool>> call(CheckFavoriteStatusParams params) async {
    return await repository.isFavorite(params.novelId);
  }
}

/// 添加到收藏参数
class AddToFavoritesParams extends Equatable {
  final String novelId;

  const AddToFavoritesParams({required this.novelId});

  @override
  List<Object> get props => [novelId];
}

/// 从收藏移除参数
class RemoveFromFavoritesParams extends Equatable {
  final String novelId;

  const RemoveFromFavoritesParams({required this.novelId});

  @override
  List<Object> get props => [novelId];
}

/// 检查收藏状态参数
class CheckFavoriteStatusParams extends Equatable {
  final String novelId;

  const CheckFavoriteStatusParams({required this.novelId});

  @override
  List<Object> get props => [novelId];
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
  Future<Either<AppError, void>> call(BatchFavoriteParams params) async {
    return await repository.batchFavoriteOperation(
      addIds: params.addIds,
      removeIds: params.removeIds,
    );
  }
}
