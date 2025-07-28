import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_novel.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取收藏列表用例参数
class GetFavoriteNovelsParams extends Equatable {
  final int page;
  final int limit;
  final String? sortBy;

  const GetFavoriteNovelsParams({
    this.page = 1,
    this.limit = 20,
    this.sortBy,
  });

  @override
  List<Object?> get props => [page, limit, sortBy];
}

/// 获取收藏列表用例
class GetFavoriteNovels implements UseCase<List<FavoriteNovel>, GetFavoriteNovelsParams> {
  final BookshelfRepository repository;

  const GetFavoriteNovels(this.repository);

  @override
  Future<Either<Failure, List<FavoriteNovel>>> call(GetFavoriteNovelsParams params) async {
    return await repository.getFavoriteNovels(
      page: params.page,
      limit: params.limit,
      sortBy: params.sortBy,
    );
  }
}
