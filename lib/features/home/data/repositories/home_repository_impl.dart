// 首页仓储实现
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/network/network_info.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/entities/banner.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/ranking.dart';
import '../../domain/entities/home_config.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<AppError, HomeConfig>> getHomeConfig() async {
    if (await networkInfo.isConnected) {
      try {
        final configModel = await remoteDataSource.getHomeConfig();
        // 缓存到本地
        await localDataSource.saveHomeConfig(configModel);
        return Right(configModel.toEntity());
      } on AppError catch (e) {
        // 网络请求失败，尝试从本地获取
        final localConfig = await localDataSource.getHomeConfig();
        if (localConfig != null) {
          return Right(localConfig.toEntity());
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      // 无网络连接，从本地获取
      final localConfig = await localDataSource.getHomeConfig();
      if (localConfig != null) {
        return Right(localConfig.toEntity());
      }
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<Banner>>> getBanners() async {
    if (await networkInfo.isConnected) {
      try {
        final bannerModels = await remoteDataSource.getBanners();
        // 缓存到本地
        await localDataSource.saveBanners(bannerModels);
        return Right(bannerModels.map((model) => model.toEntity()).toList());
      } on AppError catch (e) {
        // 网络请求失败，尝试从本地获取
        final localBanners = await localDataSource.getBanners();
        if (localBanners != null) {
          return Right(localBanners.map((model) => model.toEntity()).toList());
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      // 无网络连接，从本地获取
      final localBanners = await localDataSource.getBanners();
      if (localBanners != null) {
        return Right(localBanners.map((model) => model.toEntity()).toList());
      }
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<Recommendation>>> getRecommendations({
    RecommendationType? type,
    int page = 1,
    int limit = 10,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final recommendationModels = await remoteDataSource.getRecommendations(
          type: type?.name,
          page: page,
          limit: limit,
        );
        
        // 首页数据缓存到本地
        if (page == 1) {
          await localDataSource.saveRecommendations(recommendationModels);
        }
        
        return Right(recommendationModels.map((model) => model.toEntity()).toList());
      } on AppError catch (e) {
        // 网络请求失败且是首页时，尝试从本地获取
        if (page == 1) {
          final localRecommendations = await localDataSource.getRecommendations();
          if (localRecommendations != null) {
            return Right(localRecommendations.map((model) => model.toEntity()).toList());
          }
        }
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      if (page == 1) {
        // 无网络连接，从本地获取首页数据
        final localRecommendations = await localDataSource.getRecommendations();
        if (localRecommendations != null) {
          return Right(localRecommendations.map((model) => model.toEntity()).toList());
        }
      }
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, Ranking>> getRanking({
    required RankingType type,
    RankingPeriod period = RankingPeriod.weekly,
    int limit = 50,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final rankingModel = await remoteDataSource.getRanking(
          type: type.name,
          period: period.name,
          limit: limit,
        );
        return Right(rankingModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getHotNovels({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getHotNovels(
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getNewNovels({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getNewNovels(
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getEditorRecommendations({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getEditorRecommendations(
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getPersonalizedRecommendations({
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getPersonalizedRecommendations(
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> getCategoryHotNovels({
    required String categoryId,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.getCategoryHotNovels(
          categoryId: categoryId,
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<NovelSimpleModel>>> searchNovels({
    required String keyword,
    String? categoryId,
    String? status,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final novels = await remoteDataSource.searchNovels(
          keyword: keyword,
          categoryId: categoryId,
          status: status,
          sortBy: sortBy,
          page: page,
          limit: limit,
        );
        return Right(novels);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<String>>> getHotSearchKeywords() async {
    if (await networkInfo.isConnected) {
      try {
        final keywords = await remoteDataSource.getHotSearchKeywords();
        return Right(keywords);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, List<String>>> getSearchSuggestions(String keyword) async {
    if (await networkInfo.isConnected) {
      try {
        final suggestions = await remoteDataSource.getSearchSuggestions(keyword);
        return Right(suggestions);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> recordSearchHistory(String keyword) async {
    try {
      await localDataSource.addSearchHistory(keyword);
      return const Right(true);
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<AppError, List<String>>> getSearchHistory() async {
    try {
      final history = await localDataSource.getSearchHistory() ?? [];
      return Right(history);
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }

  @override
  Future<Either<AppError, bool>> clearSearchHistory() async {
    try {
      await localDataSource.clearSearchHistory();
      return const Right(true);
    } catch (e) {
      return Left(AppError.unknown(e.toString()));
    }
  }
}