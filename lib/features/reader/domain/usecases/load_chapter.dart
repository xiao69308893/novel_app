import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/reader_repository.dart';

/// 加载章节用例
class LoadChapter extends UseCase<ChapterModel, LoadChapterParams> {

  LoadChapter(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<ChapterModel> call(LoadChapterParams params) async =>  repository.loadChapter(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
}

/// 加载章节参数
class LoadChapterParams extends Equatable {

  const LoadChapterParams({
    required this.novelId,
    required this.chapterId,
  });
  final String novelId;
  final String chapterId;

  @override
  List<Object> get props => [novelId, chapterId];
}

/// 获取章节列表用例
class GetChapterList extends UseCase<List<ChapterSimpleModel>, GetChapterListParams> {

  GetChapterList(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<List<ChapterSimpleModel>> call(GetChapterListParams params) async =>  repository.getChapterList(novelId: params.novelId);
}

/// 获取章节列表参数
class GetChapterListParams extends Equatable {
  final String novelId;

  const GetChapterListParams({required this.novelId});

  @override
  List<Object> get props => [novelId];
}

/// 获取相邻章节用例
class GetAdjacentChapters extends UseCase<Map<String, ChapterSimpleModel?>, GetAdjacentChaptersParams> {

  GetAdjacentChapters(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<Map<String, ChapterSimpleModel?>> call(GetAdjacentChaptersParams params) async =>  repository.getAdjacentChapters(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
}

/// 获取相邻章节参数
class GetAdjacentChaptersParams extends Equatable {

  const GetAdjacentChaptersParams({
    required this.novelId,
    required this.chapterId,
  });
  final String novelId;
  final String chapterId;

  @override
  List<Object> get props => [novelId, chapterId];
}

/// 搜索章节用例
class SearchChapters extends UseCase<List<ChapterSimpleModel>, SearchChaptersParams> {

  SearchChapters(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<List<ChapterSimpleModel>> call(SearchChaptersParams params) async => await repository.searchChapters(
      novelId: params.novelId,
      keyword: params.keyword,
    );
}

/// 搜索章节参数
class SearchChaptersParams extends Equatable {

  const SearchChaptersParams({
    required this.novelId,
    required this.keyword,
  });
  final String novelId;
  final String keyword;

  @override
  List<Object> get props => [novelId, keyword];
}

/// 购买章节用例
class PurchaseChapter extends UseCase<void, PurchaseChapterParams> {

  PurchaseChapter(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(PurchaseChapterParams params) async =>  repository.purchaseChapter(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
}

/// 购买章节参数
class PurchaseChapterParams extends Equatable {

  const PurchaseChapterParams({
    required this.novelId,
    required this.chapterId,
  });
  final String novelId;
  final String chapterId;

  @override
  List<Object> get props => [novelId, chapterId];
}