// 认证状态管理
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import 'package:novel_app/features/auth/domain/entities/auth_token.dart';
import '../../../../core/usecases/usecase.dart';
import '../domain/entities/auth_user.dart';
import '../domain/usecases/auto_login_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';

// 认证状态
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {

  const AuthAuthenticated(this.user);
  final AuthUser user;

  @override
  List<Object> get props => <Object>[user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {

  const AuthError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

// 认证Cubit
class AuthCubit extends Cubit<AuthState> {

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.autoLoginUseCase,
  }) : super(AuthInitial());
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final AutoLoginUseCase autoLoginUseCase;

  /// 自动登录检查
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final Either<AppError, AuthUser> result = await autoLoginUseCase(const NoParams());

    result.fold(
      (AppError error) => emit(AuthUnauthenticated()),
      (AuthUser user) => emit(AuthAuthenticated(user)),
    );
  }

  /// 用户名密码登录
  Future<void> login({
    required String username,
    required String password,
  }) async {
    emit(AuthLoading());

    final Either<AppError, AuthToken> result = await loginUseCase(
      LoginParams(username: username, password: password),
    );

    result.fold(
      (AppError error) => emit(AuthError(error.message)),
      (AuthToken token) async {
        // 登录成功后再次检查认证状态获取用户信息
        await checkAuthStatus();
      },
    );
  }

  /// 注册账号
  Future<void> register({
    required String username,
    required String password,
    String? email,
    String? phone,
    String? inviteCode,
  }) async {
    emit(AuthLoading());

    final Either<AppError, AuthUser> result = await registerUseCase(
      RegisterParams(
        username: username,
        password: password,
        email: email,
        phone: phone,
        inviteCode: inviteCode,
      ),
    );

    result.fold(
      (AppError error) => emit(AuthError(error.message)),
      (AuthUser user) => emit(AuthAuthenticated(user)),
    );
  }

  /// 登出
  Future<void> logout() async {
    emit(AuthLoading());

    final Either<AppError, bool> result = await logoutUseCase(const NoParams());

    result.fold(
      (AppError error) => emit(AuthError(error.message)),
      (bool success) => emit(AuthUnauthenticated()),
    );
  }

  /// 清除错误状态
  void clearError() {
    if (state is AuthError) {
      emit(AuthUnauthenticated());
    }
  }
}
