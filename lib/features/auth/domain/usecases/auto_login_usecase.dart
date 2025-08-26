import 'package:dartz/dartz.dart';
import 'package:novel_app/features/auth/domain/entities/auth_token.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class AutoLoginUseCase implements UseCase<AuthUser, NoParams> {

  AutoLoginUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<AppError, AuthUser>> call(NoParams params) async {
    // 获取本地令牌
    final AuthToken? token = await repository.getLocalToken();
    if (token == null) {
      return Left(AuthError(message: '未找到本地令牌'));
    }

    // 检查令牌是否过期
    if (token.isExpired) {
      // 尝试刷新令牌
      final Either<AppError, AuthToken> refreshResult = await repository.refreshToken(token.refreshToken);
      
      return refreshResult.fold(
        (AppError error) {
          // 刷新失败，清除本地数据
          repository.clearLocalData();
          return Left(error);
        },
        (AuthToken newToken) async {
          // 保存新令牌
          await repository.saveLocalToken(newToken);
          
          // 获取用户信息
          final Either<AppError, AuthUser> userResult = await repository.getCurrentUser();
          return userResult.fold(
            Left.new,
            (AuthUser user) async {
              await repository.saveLocalUser(user);
              return Right(user);
            },
          );
        },
      );
    }

    // 令牌有效，直接获取用户信息
    final AuthUser? localUser = await repository.getLocalUser();
    if (localUser != null) {
      return Right(localUser);
    }

    // 本地用户信息不存在，从服务器获取
    final Either<AppError, AuthUser> userResult = await repository.getCurrentUser();
    return userResult.fold(
      Left.new,
      (AuthUser user) async {
        await repository.saveLocalUser(user);
        return Right(user);
      },
    );
  }
}
