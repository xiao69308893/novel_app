// 获取首页数据用例
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/banner.dart';
import '../entities/recommendation.dart';
import '../entities/home_config.dart';
import '../repositories/home_repository.dart';

class HomeData {

  const HomeData({
    required this.config,
    this.banners = const <Banner>[],
    this.recommendations = const <Recommendation>[],
  });
  final HomeConfig config;
  final List<Banner> banners;
  final List<Recommendation> recommendations;
}

class GetHomeDataUseCase implements UseCase<HomeData, NoParams> {

  GetHomeDataUseCase(this.repository);
  final HomeRepository repository;

  @override
  Future<Either<AppError, HomeData>> call(NoParams params) async {
    try {
      // 并行获取数据
      final List<Either<AppError, Object>> results = await Future.wait(<Future<Either<AppError, Object>>>[
        repository.getHomeConfig(),
        repository.getBanners(),
        repository.getRecommendations(),
      ]);

      // 检查结果
      final Either<AppError, HomeConfig> configResult = results[0] as Either<AppError, HomeConfig>;
      final Either<AppError, List<Banner>> bannersResult = results[1] as Either<AppError, List<Banner>>;
      final Either<AppError, List<Recommendation>> recommendationsResult = results[2] as Either<AppError, List<Recommendation>>;

      // 处理配置结果
      return configResult.fold(
        Left.new,
        (HomeConfig config) {
          final List<Banner> banners = bannersResult.fold(
            (AppError error) => <Banner>[],
            (List<Banner> banners) => banners.where((Banner b) => b.isValid).toList(),
          );

          final List<Recommendation> recommendations = recommendationsResult.fold(
            (AppError error) => <Recommendation>[],
            (List<Recommendation> recommendations) => recommendations.where((Recommendation r) => r.isActive).toList(),
          );

          return Right(HomeData(
            config: config,
            banners: banners,
            recommendations: recommendations,
          ));
        },
      );
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }
}