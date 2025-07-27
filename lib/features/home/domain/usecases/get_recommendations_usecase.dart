// 获取推荐内容用例
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../shared/models/novel_model.dart';
import '../entities/recommendation.dart';
import '../repositories/home_repository.dart';

class GetRecommendationsUseCase implements UseCase<List<NovelSimpleModel>, GetRecommendationsParams> {
  final HomeRepository repository;

  GetRecommendationsUseCase(this.repository);

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> call(GetRecommendationsParams params) async {
    switch (params.type) {
      case RecommendationType.hot:
        return await repository.getHotNovels(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.new_:
        return await repository.getNewNovels(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.editor:
        return await repository.getEditorRecommendations(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.personalized:
        return await repository.getPersonalizedRecommendations(
          page: params.page,
          limit: params.limit,
        );
      
      case RecommendationType.category:
        if (params.categoryId == null) {
          return Left(AppError.validation('分类推荐需要指定分类ID'));
        }
        return await repository.getCategoryHotNovels(
          categoryId: params.categoryId!,
          page: params.page,
          limit: params.limit,
        );
      
      default:
        return await repository.getHotNovels(
          page: params.page,
          limit: params.limit,
        );
    }
  }
}

class GetRecommendationsParams extends Equatable {
  final RecommendationType type;
  final String? categoryId;
  final int page;
  final int limit;

  const GetRecommendationsParams({
    required this.type,
    this.categoryId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [type, categoryId, page, limit];
}