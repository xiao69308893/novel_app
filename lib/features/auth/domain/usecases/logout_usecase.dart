class LogoutUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  @override
  Future<Either<AppError, bool>> call(NoParams params) async {
    // 执行远程登出
    final result = await repository.logout();
    
    // 无论远程登出是否成功，都清除本地数据
    await repository.clearLocalData();
    
    return result;
  }
}

// ========================================
// lib/features/auth/domain/usecases/auto_login_usecase.dart
// 自动登录用例
class AutoLoginUseCase implements UseCase<AuthUser, NoParams> {
  final AuthRepository repository;

  AutoLoginUseCase(this.repository);

  @override
  Future<Either<AppError, AuthUser>> call(NoParams params) async {
    // 获取本地令牌
    final token = await repository.getLocalToken();
    if (token == null) {
      return Left(AppError.unauthorized('未找到本地令牌'));
    }

    // 检查令牌是否过期
    if (token.isExpired) {
      // 尝试刷新令牌
      final refreshResult = await repository.refreshToken(token.refreshToken);
      
      return refreshResult.fold(
        (error) {
          // 刷新失败，清除本地数据
          repository.clearLocalData();
          return Left(error);
        },
        (newToken) async {
          // 保存新令牌
          await repository.saveLocalToken(newToken);
          
          // 获取用户信息
          final userResult = await repository.getCurrentUser();
          return userResult.fold(
            (error) => Left(error),
            (user) async {
              await repository.saveLocalUser(user);
              return Right(user);
            },
          );
        },
      );
    }

    // 令牌有效，直接获取用户信息
    final localUser = await repository.getLocalUser();
    if (localUser != null) {
      return Right(localUser);
    }

    // 本地用户信息不存在，从服务器获取
    final userResult = await repository.getCurrentUser();
    return userResult.fold(
      (error) => Left(error),
      (user) async {
        await repository.saveLocalUser(user);
        return Right(user);
      },
    );
  }
}