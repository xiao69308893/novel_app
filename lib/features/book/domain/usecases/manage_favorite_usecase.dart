// 管理收藏用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/book_repository.dart';

class ManageFavoriteUseCase implements UseCase<bool, ManageFavoriteParams> {
  final BookRepository repository;

  ManageFavoriteUseCase(this.repository);

  @override
  Future<Either<AppError, bool>> call(ManageFavoriteParams params) async {
    if (params.bookId.isEmpty) {
      return Left(DataError.validation(message: '小说ID不能为空'));
    }

    if (params.isFavorite) {
      return await repository.favoriteBook(params.bookId);
    } else {
      return await repository.unfavoriteBook(params.bookId);
    }
  }
}

class ManageFavoriteParams extends Equatable {
  final String bookId;
  final bool isFavorite;

  const ManageFavoriteParams({
    required this.bookId,
    required this.isFavorite,
  });

  @override
  List<Object> get props => [bookId, isFavorite];
}
