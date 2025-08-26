// lib/features/auth/auth_module.dart
// 认证模块主入口
import 'package:get_it/get_it.dart';
import '../../core/network/api_client.dart';
import '../../core/network/network_info.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/auto_login_usecase.dart';
import 'presentation/cubit/auth_cubit.dart';
import 'presentation/cubit/verification_cubit.dart';

/// 认证模块配置类
class AuthModule {
  static final GetIt _getIt = GetIt.instance;

  /// 初始化认证模块
  static Future<void> init() async {
    // ===================================
    // Data Sources - 数据源
    // ===================================
    _getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        apiClient: _getIt<ApiClient>(),
      ),
    );

    _getIt.registerLazySingleton<AuthLocalDataSource>(
      AuthLocalDataSourceImpl.new,
    );

    // ===================================
    // Repository - 仓储
    // ===================================
    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: _getIt<AuthRemoteDataSource>(),
        localDataSource: _getIt<AuthLocalDataSource>(),
        networkInfo: _getIt<NetworkInfo>(),
      ),
    );

    // ===================================
    // Use Cases - 用例
    // ===================================
    _getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(_getIt<AuthRepository>()));
    _getIt.registerLazySingleton<RegisterUseCase>(() => RegisterUseCase(_getIt<AuthRepository>()));
    _getIt.registerLazySingleton<LogoutUseCase>(() => LogoutUseCase(_getIt<AuthRepository>()));
    _getIt.registerLazySingleton<AutoLoginUseCase>(() => AutoLoginUseCase(_getIt<AuthRepository>()));

    // ===================================
    // Presentation - 表现层
    // ===================================
    _getIt.registerFactory<AuthCubit>(
      () => AuthCubit(
        loginUseCase: _getIt<LoginUseCase>(),
        registerUseCase: _getIt<RegisterUseCase>(),
        logoutUseCase: _getIt<LogoutUseCase>(),
        autoLoginUseCase: _getIt<AutoLoginUseCase>(), // 使用 AutoLoginUseCase 进行自动登录
      ),
    );

    _getIt.registerFactory<VerificationCubit>(
      () => VerificationCubit(
        authRepository: _getIt<AuthRepository>(),
      ),
    );
  }

  /// 获取认证Cubit
  static AuthCubit getAuthCubit() => _getIt<AuthCubit>();

  /// 获取验证码Cubit
  static VerificationCubit getVerificationCubit() => _getIt<VerificationCubit>();

  /// 获取认证仓储
  static AuthRepository getAuthRepository() => _getIt<AuthRepository>();
}