// 认证状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/features/auth/domain/usecases/auto_login_usecase.dart';
import 'package:novel_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:novel_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:novel_app/features/auth/domain/usecases/register_usecase.dart';
import '../../../../shared/models/user_model.dart';

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
  final UserModel user;

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

// 认证事件
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthLoginRequested extends AuthEvent {

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object> get props => <Object>[email, password];
}

class AuthRegisterRequested extends AuthEvent {

  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.username,
  });
  final String email;
  final String password;
  final String username;

  @override
  List<Object> get props => <Object>[email, password, username];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

// 认证Cubit
class AuthCubit extends Cubit<AuthState> {
  AuthCubit({required RegisterUseCase registerUseCase, required LoginUseCase loginUseCase, required LogoutUseCase logoutUseCase, required AutoLoginUseCase autoLoginUseCase}) : super(AuthInitial());

  /// 登录
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    
    try {
      // 模拟登录逻辑
      await Future.delayed(const Duration(seconds: 1));
      
      // 创建模拟用户
      final UserModel user = UserModel(
        id: '1',
        username: 'test_user',
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('登录失败: ${e.toString()}'));
    }
  }

  /// 注册
  Future<void> register(String email, String password, String username) async {
    emit(AuthLoading());
    
    try {
      // 模拟注册逻辑
      await Future.delayed(const Duration(seconds: 1));
      
      // 创建新用户
      final UserModel user = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('注册失败: ${e.toString()}'));
    }
  }

  /// 登出
  void logout() {
    emit(AuthUnauthenticated());
  }

  /// 检查认证状态
  void checkAuthStatus() {
    // 模拟检查逻辑
    emit(AuthUnauthenticated());
  }

  /// 忘记密码
  Future<void> forgotPassword(String email) async {
    emit(AuthLoading());
    
    try {
      // 模拟发送重置邮件
      await Future.delayed(const Duration(seconds: 1));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('发送重置邮件失败: ${e.toString()}'));
    }
  }
}