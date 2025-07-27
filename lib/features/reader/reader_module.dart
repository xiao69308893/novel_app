import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/cache/cache_manager.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/reader_remote_data_source.dart';
import 'data/datasources/reader_local_data_source.dart';
import 'data/repositories/reader_repository_impl.dart';
import 'domain/repositories/reader_repository.dart';
import 'domain/usecases/load_chapter.dart';
import 'domain/usecases/manage_reading_progress.dart';
import 'domain/usecases/manage_bookmarks.dart';
import 'domain/usecases/manage_reader_config.dart';
import 'presentation/blocs/reader/reader_bloc.dart';

/// 阅读器模块依赖注入
class ReaderModule {
  static void init() {
    final getIt = GetIt.instance;

    // 数据源
    getIt.registerLazySingleton<ReaderRemoteDataSource>(
      () => ReaderRemoteDataSourceImpl(apiClient: getIt()),
    );

    getIt.registerLazySingleton<ReaderLocalDataSource>(
      () => ReaderLocalDataSourceImpl(cacheManager: getIt()),
    );

    // 仓储
    getIt.registerLazySingleton<ReaderRepository>(
      () => ReaderRepositoryImpl(
        remoteDataSource: getIt(),
        localDataSource: getIt(),
        networkInfo: getIt(),
      ),
    );

    // 用例
    getIt.registerLazySingleton(() => LoadChapter(getIt()));
    getIt.registerLazySingleton(() => SaveReadingProgress(getIt()));
    getIt.registerLazySingleton(() => GetReadingProgress(getIt()));
    getIt.registerLazySingleton(() => AddBookmark(getIt()));
    getIt.registerLazySingleton(() => DeleteBookmark(getIt()));
    getIt.registerLazySingleton(() => GetBookmarks(getIt()));
    getIt.registerLazySingleton(() => SaveReaderConfig(getIt()));
    getIt.registerLazySingleton(() => GetReaderConfig(getIt()));

    // BLoC
    getIt.registerFactory(
      () => ReaderBloc(
        loadChapter: getIt(),
        saveReadingProgress: getIt(),
        getReadingProgress: getIt(),
        addBookmark: getIt(),
        getBookmarks: getIt(),
        saveReaderConfig: getIt(),
        getReaderConfig: getIt(),
      ),
    );
  }
}