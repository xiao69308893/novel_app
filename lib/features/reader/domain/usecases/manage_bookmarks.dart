import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/reader_repository.dart';

/// 添加书签用例
class AddBookmark extends UseCase<BookmarkModel, AddBookmarkParams> {

  AddBookmark(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<BookmarkModel> call(AddBookmarkParams params) async =>  repository.addBookmark(
      novelId: params.novelId,
      chapterId: params.chapterId,
      position: params.position,
      note: params.note,
      content: params.content,
    );
}

/// 添加书签参数
class AddBookmarkParams extends Equatable {

  const AddBookmarkParams({
    required this.novelId,
    required this.chapterId,
    required this.position,
    this.note,
    this.content,
  });
  final String novelId;
  final String chapterId;
  final int position;
  final String? note;
  final String? content;

  @override
  List<Object?> get props => <Object?>[novelId, chapterId, position, note, content];
}

/// 删除书签用例
class DeleteBookmark extends UseCase<void, String> {

  DeleteBookmark(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(String bookmarkId) async =>  repository.deleteBookmark(bookmarkId: bookmarkId);
}

/// 获取书签列表用例
class GetBookmarks extends UseCase<List<BookmarkModel>, GetBookmarksParams> {

  GetBookmarks(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<List<BookmarkModel>> call(GetBookmarksParams params) async =>  repository.getBookmarks(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
}

/// 获取书签参数
class GetBookmarksParams extends Equatable {

  const GetBookmarksParams({
    required this.novelId,
    this.chapterId,
  });
  final String novelId;
  final String? chapterId;

  @override
  List<Object?> get props => <Object?>[novelId, chapterId];
}

/// 更新书签用例
class UpdateBookmark extends UseCase<BookmarkModel, UpdateBookmarkParams> {

  UpdateBookmark(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<BookmarkModel> call(UpdateBookmarkParams params) async {
    // 这里需要在repository中添加updateBookmark方法
    throw UnimplementedError('UpdateBookmark not implemented yet');
  }
}

/// 更新书签参数
class UpdateBookmarkParams extends Equatable {

  const UpdateBookmarkParams({
    required this.bookmarkId,
    this.note,
  });
  final String bookmarkId;
  final String? note;

  @override
  List<Object?> get props => <Object?>[bookmarkId, note];
}

/// 获取书签详情用例
class GetBookmarkDetail extends UseCase<BookmarkModel, String> {

  GetBookmarkDetail(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<BookmarkModel> call(String bookmarkId) async {
    // 这里需要在repository中添加getBookmarkDetail方法
    throw UnimplementedError('GetBookmarkDetail not implemented yet');
  }
}

/// 批量删除书签用例
class BatchDeleteBookmarks extends UseCase<void, List<String>> {

  BatchDeleteBookmarks(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(List<String> bookmarkIds) async {
    // 批量删除书签
    for (final String bookmarkId in bookmarkIds) {
      await repository.deleteBookmark(bookmarkId: bookmarkId);
    }
    return Future.value();

  }
}

/// 检查位置是否有书签用例
class CheckBookmarkAtPosition extends UseCase<BookmarkModel?, CheckBookmarkParams> {

  CheckBookmarkAtPosition(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<BookmarkModel?> call(CheckBookmarkParams params) async {
    final Either<AppError, List<BookmarkModel>> result = await repository.getBookmarks(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
    
    return result.fold(
      (AppError failure) => Future.value(),
      (List<BookmarkModel> bookmarks) {
        for (final BookmarkModel bookmark in bookmarks) {
          if (bookmark.position == params.position) {
            return Future.value(Right(bookmark));
          }
        }
        return Future.value();
      },
    );
  }
}

/// 检查书签参数
class CheckBookmarkParams extends Equatable {

  const CheckBookmarkParams({
    required this.novelId,
    required this.chapterId,
    required this.position,
  });
  final String novelId;
  final String chapterId;
  final int position;

  @override
  List<Object> get props => <Object>[novelId, chapterId, position];
}