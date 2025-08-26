import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取书签列表参数
class GetBookmarksParams extends Equatable {

  const GetBookmarksParams({
    this.novelId,
    this.page = 1,
    this.limit = 20,
  });
  final String? novelId;
  final int page;
  final int limit;

  @override
  List<Object?> get props => <Object?>[novelId, page, limit];
}

/// 获取书签列表用例
class GetBookmarks implements UseCase<List<BookmarkModel>, GetBookmarksParams> {

  GetBookmarks(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, List<BookmarkModel>>> call(GetBookmarksParams params) async => repository.getBookmarks(
      novelId: params.novelId,
      page: params.page,
      limit: params.limit,
    );
}

/// 添加书签参数
class AddBookmarkParams extends Equatable {

  const AddBookmarkParams({
    required this.novelId,
    required this.chapterId,
    required this.position,
    this.note,
  });
  final String novelId;
  final String chapterId;
  final int position;
  final String? note;

  @override
  List<Object?> get props => <Object?>[novelId, chapterId, position, note];
}

/// 添加书签用例
class AddBookmark implements UseCase<BookmarkModel, AddBookmarkParams> {

  AddBookmark(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, BookmarkModel>> call(AddBookmarkParams params) async => repository.addBookmark(
      novelId: params.novelId,
      chapterId: params.chapterId,
      position: params.position,
      note: params.note,
    );
}

/// 删除书签用例
class DeleteBookmark implements UseCase<void, String> {

  DeleteBookmark(this.repository);
  final BookshelfRepository repository;

  @override
  Future<Either<AppError, void>> call(String bookmarkId) async => repository.deleteBookmark(bookmarkId);
}