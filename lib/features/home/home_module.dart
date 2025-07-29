// 首页模块配置
import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/home_remote_datasource.dart';
import 'data/datasources/home_local_datasource.dart';
import 'data/repositories/home_repository_impl.dart';
import 'domain/repositories/home_repository.dart';
import 'domain/usecases/get_home_data_usecase.dart';
import 'domain/usecases/search_novels_usecase.dart';
import 'domain/usecases/get_recommendations_usecase.dart';
import 'domain/usecases/get_ranking_usecase.dart';
import 'presentation/cubit/home_cubit.dart';
import 'presentation/cubit/search_cubit.dart';
import 'presentation/cubit/ranking_cubit.dart';

/// 首页模块配置类
class HomeModule {
  static final GetIt _getIt = GetIt.instance;

  /// 初始化首页模块
  static Future<void> init() async {
    // ===================================
    // Data Sources - 数据源
    // ===================================
    _getIt.registerLazySingleton<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(
        apiClient: _getIt<ApiClient>(),
      ),
    );

    _getIt.registerLazySingleton<HomeLocalDataSource>(
      () => HomeLocalDataSourceImpl(),
    );

    // ===================================
    // Repository - 仓储
    // ===================================
    _getIt.registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: _getIt<HomeRemoteDataSource>(),
        localDataSource: _getIt<HomeLocalDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    // ===================================
    // Use Cases - 用例
    // ===================================
    _getIt.registerLazySingleton(() => GetHomeDataUseCase(_getIt<HomeRepository>()));
    _getIt.registerLazySingleton(() => SearchNovelsUseCase(_getIt<HomeRepository>()));
    _getIt.registerLazySingleton(() => GetRecommendationsUseCase(_getIt<HomeRepository>()));
    _getIt.registerLazySingleton(() => GetRankingUseCase(_getIt<HomeRepository>()));

    // ===================================
    // Presentation - 表现层
    // ===================================
    _getIt.registerFactory(
      () => HomeCubit(
        getHomeDataUseCase: _getIt<GetHomeDataUseCase>(),
      ),
    );

    _getIt.registerFactory(
      () => SearchCubit(
        searchNovelsUseCase: _getIt<SearchNovelsUseCase>(),
        homeRepository: _getIt<HomeRepository>(),
      ),
    );

    _getIt.registerFactory(
      () => RankingCubit(
        getRankingUseCase: _getIt<GetRankingUseCase>(),
      ),
    );
  }

  /// 获取首页Cubit
  static HomeCubit getHomeCubit() => _getIt<HomeCubit>();

  /// 获取搜索Cubit
  static SearchCubit getSearchCubit() => _getIt<SearchCubit>();

  /// 获取排行榜Cubit
  static RankingCubit getRankingCubit() => _getIt<RankingCubit>();

  /// 获取首页仓储
  static HomeRepository getHomeRepository() => _getIt<HomeRepository>();
}