// 认证用户数据模型
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.username,
    super.email,
    super.phone,
    super.avatar,
    super.nickname,
    super.lastLoginAt,
    super.isVerified,
    super.extra,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      nickname: json['nickname'] as String?,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      isVerified: json['is_verified'] as bool? ?? false,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'nickname': nickname,
      'last_login_at': lastLoginAt?.toIso8601String(),
      'is_verified': isVerified,
      'extra': extra,
    };
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      username: username,
      email: email,
      phone: phone,
      avatar: avatar,
      nickname: nickname,
      lastLoginAt: lastLoginAt,
      isVerified: isVerified,
      extra: extra,
    );
  }
}
