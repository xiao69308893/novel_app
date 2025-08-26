import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/features/auth/domain/entities/auth_user.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthToken, LoginParams> {

  LoginUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<AppError, AuthToken>> call(LoginParams params) async {
    // 参数验证
    if (params.username.isEmpty) {
      return Left(DataError.validation(message: '用户名不能为空'));
    }
    if (params.password.isEmpty) {
      return Left(DataError.validation(message: '密码不能为空'));
    }

    // 执行登录
    final Either<AppError, AuthToken> result = await repository.loginWithPassword(
      username: params.username,
      password: params.password,
    );

    return result.fold(
      Left.new,
      (AuthToken token) async {
        // 保存令牌到本地
        await repository.saveLocalToken(token);
        
        // 获取并保存用户信息
        final Either<AppError, AuthUser> userResult = await repository.getCurrentUser();
        userResult.fold(
          (AppError error) => null, // 用户信息获取失败不影响登录
          repository.saveLocalUser,
        );
        
        return Right(token);
      },
    );
  }
}

class LoginParams extends Equatable {

  const LoginParams({
    required this.username,
    required this.password,
  });
  final String username;
  final String password;

  @override
  List<Object> get props => <Object>[username, password];
}