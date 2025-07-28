// 搜索小说用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/novel_model.dart';
import '../repositories/home_repository.dart';

class SearchNovelsUseCase implements UseCase<List<NovelSimpleModel>, SearchNovelsParams> {
  final HomeRepository repository;

  SearchNovelsUseCase(this.repository);

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> call(SearchNovelsParams params) async {
    // 参数验证
    if (params.keyword.trim().isEmpty) {
      return Left(DataError.validation(message: '搜索关键词不能为空'));
    }

    // 记录搜索历史
    if (params.recordHistory) {
      await repository.recordSearchHistory(params.keyword.trim());
    }

    // 执行搜索
    return await repository.searchNovels(
      keyword: params.keyword.trim(),
      categoryId: params.categoryId,
      status: params.status,
      sortBy: params.sortBy,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchNovelsParams extends Equatable {
  final String keyword;
  final String? categoryId;
  final String? status;
  final String? sortBy;
  final int page;
  final int limit;
  final bool recordHistory;

  const SearchNovelsParams({
    required this.keyword,
    this.categoryId,
    this.status,
    this.sortBy,
    this.page = 1,
    this.limit = 20,
    this.recordHistory = true,
  });

  @override
  List<Object?> get props => [
    keyword, categoryId, status, sortBy, 
    page, limit, recordHistory
  ];
}