import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/chapter_model.dart';
import '../repositories/reader_repository.dart';

/// 加载章节用例
class LoadChapter extends UseCase<ChapterModel, LoadChapterParams> {
  final ReaderRepository repository;

  const LoadChapter(this.repository);

  @override
  ResultFuture<ChapterModel> call(LoadChapterParams params) async {
    return await repository.loadChapter(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
  }
}

/// 加载章节参数
class LoadChapterParams extends Equatable {
  final String novelId;
  final String chapterId;

  const LoadChapterParams({
    required this.novelId,
    required this.chapterId,
  });

  @override
  List<Object> get props => [novelId, chapterId];
}

/// 获取章节列表用例
class GetChapterList extends UseCase<List<ChapterSimpleModel>, GetChapterListParams> {
  final ReaderRepository repository;

  const GetChapterList(this.repository);

  @override
  ResultFuture<List<ChapterSimpleModel>> call(GetChapterListParams params) async {
    return await repository.getChapterList(novelId: params.novelId);
  }
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
  final ReaderRepository repository;

  const GetAdjacentChapters(this.repository);

  @override
  ResultFuture<Map<String, ChapterSimpleModel?>> call(GetAdjacentChaptersParams params) async {
    return await repository.getAdjacentChapters(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
  }
}

/// 获取相邻章节参数
class GetAdjacentChaptersParams extends Equatable {
  final String novelId;
  final String chapterId;

  const GetAdjacentChaptersParams({
    required this.novelId,
    required this.chapterId,
  });

  @override
  List<Object> get props => [novelId, chapterId];
}

/// 搜索章节用例
class SearchChapters extends UseCase<List<ChapterSimpleModel>, SearchChaptersParams> {
  final ReaderRepository repository;

  const SearchChapters(this.repository);

  @override
  ResultFuture<List<ChapterSimpleModel>> call(SearchChaptersParams params) async {
    return await repository.searchChapters(
      novelId: params.novelId,
      keyword: params.keyword,
    );
  }
}

/// 搜索章节参数
class SearchChaptersParams extends Equatable {
  final String novelId;
  final String keyword;

  const SearchChaptersParams({
    required this.novelId,
    required this.keyword,
  });

  @override
  List<Object> get props => [novelId, keyword];
}

/// 购买章节用例
class PurchaseChapter extends UseCase<void, PurchaseChapterParams> {
  final ReaderRepository repository;

  const PurchaseChapter(this.repository);

  @override
  ResultFuture<void> call(PurchaseChapterParams params) async {
    return await repository.purchaseChapter(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
  }
}

/// 购买章节参数
class PurchaseChapterParams extends Equatable {
  final String novelId;
  final String chapterId;

  const PurchaseChapterParams({
    required this.novelId,
    required this.chapterId,
  });

  @override
  List<Object> get props => [novelId, chapterId];
}