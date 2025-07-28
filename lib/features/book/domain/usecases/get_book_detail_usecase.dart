// 获取小说详情用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/book_detail.dart';
import '../repositories/book_repository.dart';

class GetBookDetailUseCase implements UseCase<BookDetail, GetBookDetailParams> {
  final BookRepository repository;

  GetBookDetailUseCase(this.repository);

  @override
  Future<Either<AppError, BookDetail>> call(GetBookDetailParams params) async {
    // 参数验证
    if (params.bookId.isEmpty) {
      return Left(DataError.validation(message: '小说ID不能为空'));
    }

    return await repository.getBookDetail(params.bookId);
  }
}

class GetBookDetailParams extends Equatable {
  final String bookId;

  const GetBookDetailParams({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
