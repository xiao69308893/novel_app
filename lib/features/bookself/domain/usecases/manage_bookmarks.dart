import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取书签列表参数
class GetBookmarksParams extends Equatable {
  final String? novelId;
  final int page;
  final int limit;

  const GetBookmarksParams({
    this.novelId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [novelId, page, limit];
}

/// 获取书签列表用例
class GetBookmarks implements UseCase<List<BookmarkModel>, GetBookmarksParams> {
  final BookshelfRepository repository;

  GetBookmarks(this.repository);

  @override
  Future<Either<AppError, List<BookmarkModel>>> call(GetBookmarksParams params) async {
    return await repository.getBookmarks(
      novelId: params.novelId,
      page: params.page,
      limit: params.limit,
    );
  }
}

/// 添加书签参数
class AddBookmarkParams extends Equatable {
  final String novelId;
  final String chapterId;
  final int position;
  final String? note;

  const AddBookmarkParams({
    required this.novelId,
    required this.chapterId,
    required this.position,
    this.note,
  });

  @override
  List<Object?> get props => [novelId, chapterId, position, note];
}

/// 添加书签用例
class AddBookmark implements UseCase<BookmarkModel, AddBookmarkParams> {
  final BookshelfRepository repository;

  AddBookmark(this.repository);

  @override
  Future<Either<AppError, BookmarkModel>> call(AddBookmarkParams params) async {
    return await repository.addBookmark(
      novelId: params.novelId,
      chapterId: params.chapterId,
      position: params.position,
      note: params.note,
    );
  }
}

/// 删除书签用例
class DeleteBookmark implements UseCase<void, String> {
  final BookshelfRepository repository;

  DeleteBookmark(this.repository);

  @override
  Future<Either<AppError, void>> call(String bookmarkId) async {
    return await repository.deleteBookmark(bookmarkId);
  }
}