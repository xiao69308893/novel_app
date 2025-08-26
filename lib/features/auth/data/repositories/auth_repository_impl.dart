// 认证仓储实现
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/auth_user_model.dart';
import '../models/auth_token_model.dart';

class AuthRepositoryImpl implements AuthRepository {

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  @override
  Future<Either<AppError, AuthToken>> loginWithPassword({
    required String username,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final AuthTokenModel tokenModel = await remoteDataSource.loginWithPassword(
          username: username,
          password: password,
        );
        return Right(tokenModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, AuthToken>> loginWithPhone({
    required String phone,
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final AuthTokenModel tokenModel = await remoteDataSource.loginWithPhone(
          phone: phone,
          verificationCode: verificationCode,
        );
        return Right(tokenModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, AuthUser>> register({
    required String username,
    required String password,
    String? email,
    String? phone,
    String? inviteCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final AuthUserModel userModel = await remoteDataSource.register(
          username: username,
          password: password,
          email: email,
          phone: phone,
          inviteCode: inviteCode,
        );
        return Right(userModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> sendSmsCode({
    required String phone,
    required String type,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.sendSmsCode(
          phone: phone,
          type: type,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> sendEmailCode({
    required String email,
    required String type,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.sendEmailCode(
          email: email,
          type: type,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> forgotPassword({
    required String account,
    required String verificationCode,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.forgotPassword(
          account: account,
          verificationCode: verificationCode,
          newPassword: newPassword,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, AuthToken>> refreshToken(String refreshToken) async {
    if (await networkInfo.isConnected) {
      try {
        final AuthTokenModel tokenModel = await remoteDataSource.refreshToken(refreshToken);
        return Right(tokenModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, AuthUser>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final AuthUserModel userModel = await remoteDataSource.getCurrentUser();
        return Right(userModel.toEntity());
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> logout() async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.logout();
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.deleteAccount();
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> bindPhone({
    required String phone,
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.bindPhone(
          phone: phone,
          verificationCode: verificationCode,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<Either<AppError, bool>> bindEmail({
    required String email,
    required String verificationCode,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final bool result = await remoteDataSource.bindEmail(
          email: email,
          verificationCode: verificationCode,
        );
        return Right(result);
      } on AppError catch (e) {
        return Left(e);
      } catch (e) {
        return Left(AppError.unknown(e.toString()));
      }
    } else {
      return Left(NoInternetError());
    }
  }

  @override
  Future<AuthUser?> getLocalUser() async {
    final AuthUserModel? userModel = await localDataSource.getUser();
    return userModel?.toEntity();
  }

  @override
  Future<AuthToken?> getLocalToken() async {
    final AuthTokenModel? tokenModel = await localDataSource.getToken();
    return tokenModel?.toEntity();
  }

  @override
  Future<void> saveLocalUser(AuthUser user) async {
    final AuthUserModel userModel = AuthUserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      phone: user.phone,
      avatar: user.avatar,
      nickname: user.nickname,
      lastLoginAt: user.lastLoginAt,
      isVerified: user.isVerified,
      extra: user.extra,
    );
    await localDataSource.saveUser(userModel);
  }

  @override
  Future<void> saveLocalToken(AuthToken token) async {
    final AuthTokenModel tokenModel = AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      tokenType: token.tokenType,
    );
    await localDataSource.saveToken(tokenModel);
  }

  @override
  Future<void> clearLocalData() async {
    await localDataSource.clearAll();
  }
}