// 认证远程数据源
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/app_error.dart';
import '../models/auth_user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokenModel> loginWithPassword({
    required String username,
    required String password,
  });

  Future<AuthTokenModel> loginWithPhone({
    required String phone,
    required String verificationCode,
  });

  Future<AuthUserModel> register({
    required String username,
    required String password,
    String? email,
    String? phone,
    String? inviteCode,
  });

  Future<bool> sendSmsCode({
    required String phone,
    required String type,
  });

  Future<bool> sendEmailCode({
    required String email,
    required String type,
  });

  Future<bool> forgotPassword({
    required String account,
    required String verificationCode,
    required String newPassword,
  });

  Future<AuthTokenModel> refreshToken(String refreshToken);

  Future<AuthUserModel> getCurrentUser();

  Future<bool> logout();

  Future<bool> deleteAccount();

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<bool> bindPhone({
    required String phone,
    required String verificationCode,
  });

  Future<bool> bindEmail({
    required String email,
    required String verificationCode,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthTokenModel> loginWithPassword({
    required String username,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      return AuthTokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthTokenModel> loginWithPhone({
    required String phone,
    required String verificationCode,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login/phone',
        data: {
          'phone': phone,
          'verification_code': verificationCode,
        },
      );

      return AuthTokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthUserModel> register({
    required String username,
    required String password,
    String? email,
    String? phone,
    String? inviteCode,
  }) async {
    try {
      final data = {
        'username': username,
        'password': password,
      };

      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (inviteCode != null) data['invite_code'] = inviteCode;

      final response = await apiClient.post('/auth/register', data: data);

      return AuthUserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> sendSmsCode({
    required String phone,
    required String type,
  }) async {
    try {
      await apiClient.post(
        '/auth/sms/send',
        data: {
          'phone': phone,
          'type': type,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> sendEmailCode({
    required String email,
    required String type,
  }) async {
    try {
      await apiClient.post(
        '/auth/email/send',
        data: {
          'email': email,
          'type': type,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> forgotPassword({
    required String account,
    required String verificationCode,
    required String newPassword,
  }) async {
    try {
      await apiClient.post(
        '/auth/password/forgot',
        data: {
          'account': account,
          'verification_code': verificationCode,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        '/auth/token/refresh',
        data: {
          'refresh_token': refreshToken,
        },
      );

      return AuthTokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/user');
      return AuthUserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await apiClient.post('/auth/logout');
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      await apiClient.delete('/auth/account');
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await apiClient.put(
        '/auth/password/change',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> bindPhone({
    required String phone,
    required String verificationCode,
  }) async {
    try {
      await apiClient.post(
        '/auth/phone/bind',
        data: {
          'phone': phone,
          'verification_code': verificationCode,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> bindEmail({
    required String email,
    required String verificationCode,
  }) async {
    try {
      await apiClient.post(
        '/auth/email/bind',
        data: {
          'email': email,
          'verification_code': verificationCode,
        },
      );
      return true;
    } on DioException catch (e) {
      throw AppError.fromDioException(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }
}