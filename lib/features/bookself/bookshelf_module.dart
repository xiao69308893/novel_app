import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/cache/cache_manager.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/bookshelf_remote_data_source.dart';
import 'data/datasources/bookshelf_local_data_source.dart';
import 'data/repositories/bookshelf_repository_impl.dart';
import 'domain/repositories/bookshelf_repository.dart';
import 'domain/usecases/get_favorite_novels.dart';
import 'domain/usecases/manage_favorites.dart';
import 'presentation/blocs/bookshelf/bookshelf_bloc.dart';

/// 书架模块依赖注入
class BookshelfModule {
  static void init() {
    final getIt = GetIt.instance;

    // 数据源
    getIt.registerLazySingleton<BookshelfRemoteDataSource>(
      () => BookshelfRemoteDataSourceImpl(apiClient: getIt()),
    );

    getIt.registerLazySingleton<BookshelfLocalDataSource>(
      () => BookshelfLocalDataSourceImpl(cacheManager: getIt()),
    );

    // 仓储
    getIt.registerLazySingleton<BookshelfRepository>(
      () => BookshelfRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    // 用例
    getIt.registerLazySingleton(() => GetFavoriteNovels(getIt()));
    getIt.registerLazySingleton(() => AddToFavorites(getIt()));
    getIt.registerLazySingleton(() => RemoveFromFavorites(getIt()));
    getIt.registerLazySingleton(() => CheckFavoriteStatus(getIt()));

    // BLoC
    getIt.registerFactory(
      () => BookshelfBloc(
        getFavoriteNovels: getIt(),
        addToFavorites: getIt(),
        removeFromFavorites: getIt(),
      ),
    );
  }
}