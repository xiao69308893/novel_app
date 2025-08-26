// 认证远程数据源
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/errors/error_handler.dart';
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

  AuthRemoteDataSourceImpl({required this.apiClient});
  final ApiClient apiClient;

  @override
  Future<AuthTokenModel> loginWithPassword({
    required String username,
    required String password,
  }) async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login',
        data: <String, String>{
          'username': username,
          'password': password,
        },
      );

      return AuthTokenModel.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      final ApiResponse<Map<String, dynamic>> response = await apiClient.post<Map<String, dynamic>>(
        '/auth/login/phone',
        data: <String, String>{
          'phone': phone,
          'verification_code': verificationCode,
        },
      );

      return AuthTokenModel.fromJson(response.data?['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      final Map<String, dynamic> data = <String, dynamic>{
        'username': username,
        'password': password,
      };

      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (inviteCode != null) data['invite_code'] = inviteCode;

      final ApiResponse<Map<String, dynamic>> response = await apiClient.post<Map<String, dynamic>>(
        '/auth/register', 
        data: data,
      );

      return AuthUserModel.fromJson(
        response.data?['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.post<Map<String, dynamic>>(
        '/auth/sms/send',
        data: <String, String>{
          'phone': phone,
          'type': type,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.post<Map<String, dynamic>>(
        '/auth/email/send',
        data: <String, String>{
          'email': email,
          'type': type,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.post<Map<String, dynamic>>(
        '/auth/password/forgot',
        data: <String, String>{
          'account': account,
          'verification_code': verificationCode,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthTokenModel> refreshToken(String refreshToken) async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.post<Map<String, dynamic>>(
        '/auth/token/refresh',
        data: <String, String>{
          'refresh_token': refreshToken,
        },
      );

      return AuthTokenModel.fromJson(
        response.data?['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<AuthUserModel> getCurrentUser() async {
    try {
      final ApiResponse<Map<String, dynamic>> response = await apiClient.get<Map<String, dynamic>>('/auth/user');
      return AuthUserModel.fromJson(
        response.data?['data'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await apiClient.post<Map<String, dynamic>>('/auth/logout');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }

  @override
  Future<bool> deleteAccount() async {
    try {
      await apiClient.delete<Map<String, dynamic>>('/auth/account');
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.put<Map<String, dynamic>>(
        '/auth/password/change',
        data: <String, String>{
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.post<Map<String, dynamic>>(
        '/auth/phone/bind',
        data: <String, String>{
          'phone': phone,
          'verification_code': verificationCode,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
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
      await apiClient.post<Map<String, dynamic>>(
        '/auth/email/bind',
        data: <String, String>{
          'email': email,
          'verification_code': verificationCode,
        },
      );
      return true;
    } on DioException catch (e) {
      throw DefaultErrorHandler.convertToAppError(e);
    } catch (e) {
      throw AppError.unknown(e.toString());
    }
  }
}