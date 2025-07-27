// 获取首页数据用例
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/banner.dart';
import '../entities/recommendation.dart';
import '../entities/home_config.dart';
import '../repositories/home_repository.dart';

class HomeData {
  final HomeConfig config;
  final List<Banner> banners;
  final List<Recommendation> recommendations;

  const HomeData({
    required this.config,
    this.banners = const [],
    this.recommendations = const [],
  });
}

class GetHomeDataUseCase implements UseCase<HomeData, NoParams> {
  final HomeRepository repository;

  GetHomeDataUseCase(this.repository);

  @override
  Future<Either<AppError, HomeData>> call(NoParams params) async {
    try {
      // 并行获取数据
      final results = await Future.wait([
        repository.getHomeConfig(),
        repository.getBanners(),
        repository.getRecommendations(),
      ]);

      // 检查结果
      final configResult = results[0] as Either<AppError, HomeConfig>;
      final bannersResult = results[1] as Either<AppError, List<Banner>>;
      final recommendationsResult = results[2] as Either<AppError, List<Recommendation>>;

      // 处理配置结果
      return configResult.fold(
        (error) => Left(error),
        (config) {
          final banners = bannersResult.fold(
            (error) => <Banner>[],
            (banners) => banners.where((b) => b.isValid).toList(),
          );

          final recommendations = recommendationsResult.fold(
            (error) => <Recommendation>[],
            (recommendations) => recommendations.where((r) => r.isActive).toList(),
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