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
      final userJson = await PreferencesHelper.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return AuthUserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveUser(AuthUserModel user) async {
    final userJson = json.encode(user.toJson());
    await PreferencesHelper.setString(_userKey, userJson);
  }

  @override
  Future<AuthTokenModel?> getToken() async {
    try {
      final tokenJson = await PreferencesHelper.getString(_tokenKey);
      if (tokenJson != null) {
        final tokenMap = json.decode(tokenJson) as Map<String, dynamic>;
        return AuthTokenModel.fromJson(tokenMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveToken(AuthTokenModel token) async {
    final tokenJson = json.encode(token.toJson());
    await PreferencesHelper.setString(_tokenKey, tokenJson);
  }

  @override
  Future<void> clearAll() async {
    await PreferencesHelper.remove(_userKey);
    await PreferencesHelper.remove(_tokenKey);
  }
}