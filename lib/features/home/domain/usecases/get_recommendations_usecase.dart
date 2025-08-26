// 获取推荐内容用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/models/novel_model.dart';
import '../entities/recommendation.dart';
import '../repositories/home_repository.dart';

class GetRecommendationsUseCase implements UseCase<List<NovelSimpleModel>, GetRecommendationsParams> {

  GetRecommendationsUseCase(this.repository);
  final HomeRepository repository;

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> call(GetRecommendationsParams params) async {
    switch (params.type) {
      case RecommendationType.hot:
        return repository.getHotNovels(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.new_:
        return repository.getNewNovels(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.editor:
        return repository.getEditorRecommendations(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.personalized:
        return repository.getPersonalizedRecommendations(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.category:
        if (params.categoryId == null) {
          return Left(DataError.validation(message: '分类推荐需要指定分类ID'));
        }
        return repository.getCategoryHotNovels(
          categoryId: params.categoryId!,
          page: params.page,
          limit: params.limit,
        );
      
      default:
        return repository.getHotNovels(
          page: params.page,
          limit: params.limit,
        );
    }
  }
}

class GetRecommendationsParams extends Equatable {

  const GetRecommendationsParams({
    required this.type,
    this.categoryId,
    this.page = 1,
    this.limit = 20,
  });
  final RecommendationType type;
  final String? categoryId;
  final int page;
  final int limit;

  @override
  List<Object?> get props => <Object?>[type, categoryId, page, limit];
}