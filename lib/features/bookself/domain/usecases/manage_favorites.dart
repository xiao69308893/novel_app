import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/bookshelf_repository.dart';

/// 添加到收藏用例
class AddToFavorites implements UseCase<void, AddToFavoritesParams> {

  AddToFavorites(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(AddToFavoritesParams params) async => repository.addToFavorites(params.novelId);
}

/// 从收藏移除用例
class RemoveFromFavorites implements UseCase<void, RemoveFromFavoritesParams> {

  RemoveFromFavorites(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(RemoveFromFavoritesParams params) async => repository.removeFromFavorites(params.novelId);
}

/// 检查收藏状态用例
class CheckFavoriteStatus implements UseCase<bool, CheckFavoriteStatusParams> {

  CheckFavoriteStatus(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, bool>> call(CheckFavoriteStatusParams params) async => repository.isFavorite(params.novelId);
}

/// 添加到收藏参数
class AddToFavoritesParams extends Equatable {

  const AddToFavoritesParams({required this.novelId});
  final String novelId;

  @override
  List<Object> get props => <Object>[novelId];
}

/// 从收藏移除参数
class RemoveFromFavoritesParams extends Equatable {

  const RemoveFromFavoritesParams({required this.novelId});
  final String novelId;

  @override
  List<Object> get props => <Object>[novelId];
}

/// 检查收藏状态参数
class CheckFavoriteStatusParams extends Equatable {

  const CheckFavoriteStatusParams({required this.novelId});
  final String novelId;

  @override
  List<Object> get props => <Object>[novelId];
}

/// 批量收藏操作参数
class BatchFavoriteParams extends Equatable {

  const BatchFavoriteParams({
    this.addIds,
    this.removeIds,
  });
  final List<String>? addIds;
  final List<String>? removeIds;

  @override
  List<Object?> get props => <Object?>[addIds, removeIds];
}

/// 批量收藏操作用例
class BatchFavoriteOperation implements UseCase<void, BatchFavoriteParams> {

  const BatchFavoriteOperation(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(BatchFavoriteParams params) async => repository.batchFavoriteOperation(
      addIds: params.addIds,
      removeIds: params.removeIds,
    );
}
