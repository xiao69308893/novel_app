import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? avatar;
  final String? nickname;
  final DateTime? lastLoginAt;
  final bool isVerified;
  final Map<String, dynamic>? extra;

  const AuthUser({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.avatar,
    this.nickname,
    this.lastLoginAt,
    this.isVerified = false,
    this.extra,
  });

  @override
  List<Object?> get props => [
    id, username, email, phone, avatar, 
    nickname, lastLoginAt, isVerified, extra
  ];
}