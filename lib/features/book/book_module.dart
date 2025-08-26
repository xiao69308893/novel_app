// 小说详情模块配置
import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/book_remote_datasource.dart';
import 'data/datasources/book_local_datasource.dart';
import 'data/repositories/book_repository_impl.dart';
import 'domain/repositories/book_repository.dart';
import 'domain/usecases/get_book_detail_usecase.dart';
import 'domain/usecases/manage_favorite_usecase.dart';
import 'domain/usecases/post_comment_usecase.dart';
import 'domain/usecases/manage_reading_progress_usecase.dart';
import 'presentation/cubit/book_detail_cubit.dart';
import 'presentation/cubit/comment_cubit.dart';

/// 小说详情模块配置类
class BookModule {
  static final GetIt _getIt = GetIt.instance;

  /// 初始化小说详情模块
  static Future<void> init() async {
    // ===================================
    // Data Sources - 数据源
    // ===================================
    _getIt.registerLazySingleton<BookRemoteDataSource>(
      () => BookRemoteDataSourceImpl(
        apiClient: _getIt<ApiClient>(),
      ),
    );

    _getIt.registerLazySingleton<BookLocalDataSource>(
      BookLocalDataSourceImpl.new,
    );

    // ===================================
    // Repository - 仓储
    // ===================================
    _getIt.registerLazySingleton<BookRepository>(
      () => BookRepositoryImpl(
        remoteDataSource: _getIt<BookRemoteDataSource>(),
        localDataSource: _getIt<BookLocalDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    // ===================================
    // Use Cases - 用例
    // ===================================
    _getIt.registerLazySingleton(() => GetBookDetailUseCase(_getIt<BookRepository>()));
    _getIt.registerLazySingleton(() => ManageFavoriteUseCase(_getIt<BookRepository>()));
    _getIt.registerLazySingleton(() => PostCommentUseCase(_getIt<BookRepository>()));
    _getIt.registerLazySingleton(() => UpdateReadingProgressUseCase(_getIt<BookRepository>()));
    _getIt.registerLazySingleton(() => GetReadingProgressUseCase(_getIt<BookRepository>()));

    // ===================================
    // Presentation - 表现层
    // ===================================
    _getIt.registerFactory(
      () => BookDetailCubit(
        getBookDetailUseCase: _getIt<GetBookDetailUseCase>(),
        manageFavoriteUseCase: _getIt<ManageFavoriteUseCase>(),
        updateReadingProgressUseCase: _getIt<UpdateReadingProgressUseCase>(),
        bookRepository: _getIt<BookRepository>(),
      ),
    );

    _getIt.registerFactory(
      () => CommentCubit(
        postCommentUseCase: _getIt<PostCommentUseCase>(),
        bookRepository: _getIt<BookRepository>(),
      ),
    );
  }

  /// 获取小说详情Cubit
  static BookDetailCubit getBookDetailCubit() => _getIt<BookDetailCubit>();

  /// 获取评论Cubit
  static CommentCubit getCommentCubit() => _getIt<CommentCubit>();

  /// 获取小说仓储
  static BookRepository getBookRepository() => _getIt<BookRepository>();
}