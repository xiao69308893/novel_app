import 'package:equatable/equatable.dart';
import '../../../../shared/models/user_model.dart';

/// 用户档案实体（扩展用户信息）
class UserProfile extends Equatable {

  const UserProfile({
    required this.user,
    this.followingCount = 0,
    this.followersCount = 0,
    this.likesReceived = 0,
    this.reviewsCount = 0,
    this.level = 1,
    this.experience = 0,
    this.points = 0,
    this.badges = const <String>[],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      followingCount: json['following_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      likesReceived: json['likes_received'] as int? ?? 0,
      reviewsCount: json['reviews_count'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      badges: (json['badges'] as List<dynamic>?)?.cast<String>() ?? <String>[],
    );
  /// 基础用户信息
  final UserModel user;
  
  /// 关注数
  final int followingCount;
  
  /// 粉丝数
  final int followersCount;
  
  /// 获得的点赞数
  final int likesReceived;
  
  /// 书评数
  final int reviewsCount;
  
  /// 等级
  final int level;
  
  /// 经验值
  final int experience;
  
  /// 积分
  final int points;
  
  /// 成就徽章
  final List<String> badges;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'user': user.toJson(),
      'following_count': followingCount,
      'followers_count': followersCount,
      'likes_received': likesReceived,
      'reviews_count': reviewsCount,
      'level': level,
      'experience': experience,
      'points': points,
      'badges': badges,
    };

  /// 下一级所需经验值
  int get nextLevelExperience {
    return level * 1000; // 简单的等级计算公式
  }

  /// 当前等级进度百分比
  double get levelProgress {
    final int currentLevelExp = (level - 1) * 1000;
    final int nextLevelExp = level * 1000;
    final int progressExp = experience - currentLevelExp;
    final int totalExp = nextLevelExp - currentLevelExp;
    
    if (totalExp <= 0) return 1.0;
    return (progressExp / totalExp).clamp(0.0, 1.0);
  }

  @override
  List<Object> get props => <Object>[
        user,
        followingCount,
        followersCount,
        likesReceived,
        reviewsCount,
        level,
        experience,
        points,
        badges,
      ];
}