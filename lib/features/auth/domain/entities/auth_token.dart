import 'package:equatable/equatable.dart';
class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
  final String tokenType;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType = 'Bearer',
  });

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// 即将过期（15分钟内）
  bool get willExpireSoon {
    final now = DateTime.now();
    final threshold = expiresAt.subtract(const Duration(minutes: 15));
    return now.isAfter(threshold);
  }

  @override
  List<Object> get props => [accessToken, refreshToken, expiresAt, tokenType];
}