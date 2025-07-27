import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<AuthToken, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<Either<AppError, AuthToken>> call(LoginParams params) async {
    // 参数验证
    if (params.username.isEmpty) {
      return Left(AppError.validation('用户名不能为空'));
    }
    if (params.password.isEmpty) {
      return Left(AppError.validation('密码不能为空'));
    }

    // 执行登录
    final result = await repository.loginWithPassword(
      username: params.username,
      password: params.password,
    );

    return result.fold(
      (error) => Left(error),
      (token) async {
        // 保存令牌到本地
        await repository.saveLocalToken(token);
        
        // 获取并保存用户信息
        final userResult = await repository.getCurrentUser();
        userResult.fold(
          (error) => null, // 用户信息获取失败不影响登录
          (user) => repository.saveLocalUser(user),
        );
        
        return Right(token);
      },
    );
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;

  const LoginParams({
    required this.username,
    required this.password,
  });

  @override
  List<Object> get props => [username, password];
}