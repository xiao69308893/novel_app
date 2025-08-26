// 认证本地数据源
import 'dart:convert';
import '../../../../core/utils/preferences_helper.dart';
import '../models/auth_user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthLocalDataSource {
  Future<AuthUserModel?> getUser();
  Future<void> saveUser(AuthUserModel user);
  Future<AuthTokenModel?> getToken();
  Future<void> saveToken(AuthTokenModel token);
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';

  @override
  Future<AuthUserModel?> getUser() async {
    try {
      final String? userJson = PreferencesHelper.getString(_userKey);
      if (userJson != null) {
        final Map<String, dynamic> userMap = json.decode(userJson) as Map<String, dynamic>;
        return AuthUserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(AuthUserModel user) async {
    final String userJson = json.encode(user.toJson());
    await PreferencesHelper.setString(_userKey, userJson);
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    try {
      final String? tokenJson = PreferencesHelper.getString(_tokenKey);
      if (tokenJson != null) {
        final Map<String, dynamic> tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    final String tokenJson = json.encode(token.toJson());
    await PreferencesHelper.setString(_tokenKey, tokenJson);
  }

  @override
  Future<void> clearAll() async {
    await PreferencesHelper.remove(_userKey);
    await PreferencesHelper.remove(_tokenKey);
  }
}