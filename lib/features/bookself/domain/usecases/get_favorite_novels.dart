import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/favorite_novel.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取收藏小说用例
class GetFavoriteNovels implements UseCase<List<FavoriteNovel>, NoParams> {

  GetFavoriteNovels(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, List<FavoriteNovel>>> call(NoParams params) async => repository.getFavoriteNovels();
}
