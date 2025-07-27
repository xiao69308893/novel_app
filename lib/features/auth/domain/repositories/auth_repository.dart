import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../entities/auth_user.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  /// 用户名密码登录
  Future<Either<AppError, AuthToken>> loginWithPassword({
    required String username,
    required String password,
  });

  /// 手机号验证码登录
  Future<Either<AppError, AuthToken>> loginWithPhone({
    required String phone,
    required String verificationCode,
  });

  /// 注册账号
  Future<Either<AppError, AuthUser>> register({
    required String username,
    required String password,
    String? email,
    String? phone,
    String? inviteCode,
  });

  /// 发送手机验证码
  Future<Either<AppError, bool>> sendSmsCode({
    required String phone,
    required String type, // login, register, forgot_password
  });

  /// 发送邮箱验证码
  Future<Either<AppError, bool>> sendEmailCode({
    required String email,
    required String type,
  });

  /// 忘记密码
  Future<Either<AppError, bool>> forgotPassword({
    required String account, // 手机号或邮箱
    required String verificationCode,
    required String newPassword,
  });

  /// 刷新令牌
  Future<Either<AppError, AuthToken>> refreshToken(String refreshToken);

  /// 获取当前用户信息
  Future<Either<AppError, AuthUser>> getCurrentUser();

  /// 登出
  Future<Either<AppError, bool>> logout();

  /// 注销账号
  Future<Either<AppError, bool>> deleteAccount();

  /// 修改密码
  Future<Either<AppError, bool>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  /// 绑定手机号
  Future<Either<AppError, bool>> bindPhone({
    required String phone,
    required String verificationCode,
  });

  /// 绑定邮箱
  Future<Either<AppError, bool>> bindEmail({
    required String email,
    required String verificationCode,
  });

  /// 获取本地存储的用户信息
  Future<AuthUser?> getLocalUser();

  /// 获取本地存储的令牌
  Future<AuthToken?> getLocalToken();

  /// 保存用户信息到本地
  Future<void> saveLocalUser(AuthUser user);

  /// 保存令牌到本地
  Future<void> saveLocalToken(AuthToken token);

  /// 清除本地数据
  Future<void> clearLocalData();
}