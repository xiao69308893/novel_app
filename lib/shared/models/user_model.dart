import 'package:equatable/equatable.dart';

/// 用户性别枚举
enum Gender {
  unknown(0, '未知'),
  male(1, '男'),
  female(2, '女');

  const Gender(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static Gender fromValue(int? value) => Gender.values.firstWhere(
      (Gender g) => g.value == value,
      orElse: () => Gender.unknown,
    );
}

/// 用户状态枚举
enum UserStatus {
  normal(0, '正常'),
  banned(1, '封禁'),
  locked(2, '锁定'),
  deleted(3, '已删除');

  const UserStatus(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static UserStatus fromValue(int? value) => UserStatus.values.firstWhere(
      (UserStatus s) => s.value == value,
      orElse: () => UserStatus.normal,
    );
}

/// VIP等级枚举
enum VipLevel {
  none(0, '普通用户', null),
  bronze(1, '青铜会员', 30),
  silver(2, '白银会员', 90),
  gold(3, '黄金会员', 180),
  platinum(4, '铂金会员', 365),
  diamond(5, '钻石会员', 999);

  const VipLevel(this.value, this.displayName, this.validDays);
  
  final int value;
  final String displayName;
  final int? validDays; // VIP有效天数

  static VipLevel fromValue(int? value) => VipLevel.values.firstWhere(
      (VipLevel v) => v.value == value,
      orElse: () => VipLevel.none,
    );

  bool get isVip => this != VipLevel.none;
}

/// 用户模型
class UserModel extends Equatable {

  const UserModel({
    required this.id,
    required this.username,
    required this.createdAt, required this.updatedAt, this.email,
    this.phone,
    this.nickname,
    this.avatar,
    this.gender = Gender.unknown,
    this.birthday,
    this.bio,
    this.status = UserStatus.normal,
    this.vipLevel = VipLevel.none,
    this.vipExpiredAt,
    this.lastLoginAt,
    this.stats,
    this.settings,
    this.extra,
  });

  /// 从JSON创建用户模型
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      nickname: json['nickname'] as String?,
      avatar: json['avatar'] as String?,
      gender: Gender.fromValue(json['gender'] as int?),
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday'] as String)
          : null,
      bio: json['bio'] as String?,
      status: UserStatus.fromValue(json['status'] as int?),
      vipLevel: VipLevel.fromValue(json['vip_level'] as int?),
      vipExpiredAt: json['vip_expired_at'] != null
          ? DateTime.parse(json['vip_expired_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'] as String)
          : null,
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'] as Map<String, dynamic>)
          : null,
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'] as Map<String, dynamic>)
          : null,
      extra: json['extra'] as Map<String, dynamic>?,
    );
  /// 用户ID
  final String id;
  
  /// 用户名
  final String username;
  
  /// 邮箱
  final String? email;
  
  /// 手机号
  final String? phone;
  
  /// 昵称
  final String? nickname;
  
  /// 头像URL
  final String? avatar;
  
  /// 性别
  final Gender gender;
  
  /// 生日
  final DateTime? birthday;
  
  /// 个人简介
  final String? bio;
  
  /// 用户状态
  final UserStatus status;
  
  /// VIP等级
  final VipLevel vipLevel;
  
  /// VIP到期时间
  final DateTime? vipExpiredAt;
  
  /// 注册时间
  final DateTime createdAt;
  
  /// 更新时间
  final DateTime updatedAt;
  
  /// 最后登录时间
  final DateTime? lastLoginAt;
  
  /// 用户统计信息
  final UserStats? stats;
  
  /// 用户设置
  final UserSettings? settings;
  
  /// 扩展字段
  final Map<String, dynamic>? extra;

  /// 转换为JSON
  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'nickname': nickname,
      'avatar': avatar,
      'gender': gender.value,
      'birthday': birthday?.toIso8601String(),
      'bio': bio,
      'status': status.value,
      'vip_level': vipLevel.value,
      'vip_expired_at': vipExpiredAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
      'stats': stats?.toJson(),
      'settings': settings?.toJson(),
      'extra': extra,
    };

  /// 复制并修改用户信息
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? nickname,
    String? avatar,
    Gender? gender,
    DateTime? birthday,
    String? bio,
    UserStatus? status,
    VipLevel? vipLevel,
    DateTime? vipExpiredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    UserStats? stats,
    UserSettings? settings,
    Map<String, dynamic>? extra,
  }) => UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      bio: bio ?? this.bio,
      status: status ?? this.status,
      vipLevel: vipLevel ?? this.vipLevel,
      vipExpiredAt: vipExpiredAt ?? this.vipExpiredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      stats: stats ?? this.stats,
      settings: settings ?? this.settings,
      extra: extra ?? this.extra,
    );

  /// 显示名称（优先昵称，其次用户名）
  String get displayName => nickname ?? username;

  /// 是否为VIP用户
  bool get isVip => vipLevel.isVip && (vipExpiredAt?.isAfter(DateTime.now()) ?? false);

  /// VIP是否即将过期（7天内）
  bool get isVipExpiringSoon {
    if (!isVip || vipExpiredAt == null) return false;
    final DateTime now = DateTime.now();
    final Duration diff = vipExpiredAt!.difference(now);
    return diff.inDays <= 7;
  }

  /// 年龄
  int? get age {
    if (birthday == null) return null;
    final DateTime now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  /// 注册天数
  int get registeredDays => DateTime.now().difference(createdAt).inDays;

  /// 是否活跃用户（最近30天内登录）
  bool get isActiveUser {
    if (lastLoginAt == null) return false;
    return DateTime.now().difference(lastLoginAt!).inDays <= 30;
  }

  /// 用户等级标签
  String get levelLabel {
    if (isVip) return vipLevel.displayName;
    return '普通用户';
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        username,
        email,
        phone,
        nickname,
        avatar,
        gender,
        birthday,
        bio,
        status,
        vipLevel,
        vipExpiredAt,
        createdAt,
        updatedAt,
        lastLoginAt,
        stats,
        settings,
        extra,
      ];

  @override
  String toString() => 'UserModel{id: $id, username: $username, nickname: $nickname}';
}

/// 用户统计信息
class UserStats extends Equatable {

  const UserStats({
    this.totalReadingTime = 0,
    this.booksRead = 0,
    this.chaptersRead = 0,
    this.wordsRead = 0,
    this.favoritesCount = 0,
    this.commentsCount = 0,
    this.checkinDays = 0,
    this.consecutiveCheckinDays = 0,
    this.shareCount = 0,
    this.inviteCount = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
      totalReadingTime: json['total_reading_time'] as int? ?? 0,
      booksRead: json['books_read'] as int? ?? 0,
      chaptersRead: json['chapters_read'] as int? ?? 0,
      wordsRead: json['words_read'] as int? ?? 0,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      checkinDays: json['checkin_days'] as int? ?? 0,
      consecutiveCheckinDays: json['consecutive_checkin_days'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      inviteCount: json['invite_count'] as int? ?? 0,
    );
  /// 阅读总时长（秒）
  final int totalReadingTime;
  
  /// 已读小说数
  final int booksRead;
  
  /// 已读章节数
  final int chaptersRead;
  
  /// 已读字数
  final int wordsRead;
  
  /// 收藏数
  final int favoritesCount;
  
  /// 评论数
  final int commentsCount;
  
  /// 签到天数
  final int checkinDays;
  
  /// 连续签到天数
  final int consecutiveCheckinDays;
  
  /// 分享次数
  final int shareCount;
  
  /// 邀请人数
  final int inviteCount;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'total_reading_time': totalReadingTime,
      'books_read': booksRead,
      'chapters_read': chaptersRead,
      'words_read': wordsRead,
      'favorites_count': favoritesCount,
      'comments_count': commentsCount,
      'checkin_days': checkinDays,
      'consecutive_checkin_days': consecutiveCheckinDays,
      'share_count': shareCount,
      'invite_count': inviteCount,
    };

  UserStats copyWith({
    int? totalReadingTime,
    int? booksRead,
    int? chaptersRead,
    int? wordsRead,
    int? favoritesCount,
    int? commentsCount,
    int? checkinDays,
    int? consecutiveCheckinDays,
    int? shareCount,
    int? inviteCount,
  }) => UserStats(
      totalReadingTime: totalReadingTime ?? this.totalReadingTime,
      booksRead: booksRead ?? this.booksRead,
      chaptersRead: chaptersRead ?? this.chaptersRead,
      wordsRead: wordsRead ?? this.wordsRead,
      favoritesCount: favoritesCount ?? this.favoritesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      checkinDays: checkinDays ?? this.checkinDays,
      consecutiveCheckinDays: consecutiveCheckinDays ?? this.consecutiveCheckinDays,
      shareCount: shareCount ?? this.shareCount,
      inviteCount: inviteCount ?? this.inviteCount,
    );

  /// 平均阅读时长（小时）
  double get averageReadingHours {
    if (booksRead == 0) return 0;
    return (totalReadingTime / 3600) / booksRead;
  }

  /// 平均阅读速度（字/分钟）
  double get averageReadingSpeed {
    if (totalReadingTime == 0) return 0;
    return wordsRead / (totalReadingTime / 60);
  }

  @override
  List<Object> get props => <Object>[
        totalReadingTime,
        booksRead,
        chaptersRead,
        wordsRead,
        favoritesCount,
        commentsCount,
        checkinDays,
        consecutiveCheckinDays,
        shareCount,
        inviteCount,
      ];
}

/// 用户设置
class UserSettings extends Equatable {

  const UserSettings({
    required this.notifications,
    required this.reader,
    required this.privacy,
    this.other,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
      notifications: NotificationSettings.fromJson(
        json['notifications'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      reader: ReaderSettings.fromJson(
        json['reader'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      privacy: PrivacySettings.fromJson(
        json['privacy'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      other: json['other'] as Map<String, dynamic>?,
    );
  /// 通知设置
  final NotificationSettings notifications;
  
  /// 阅读器设置
  final ReaderSettings reader;
  
  /// 隐私设置
  final PrivacySettings privacy;
  
  /// 其他设置
  final Map<String, dynamic>? other;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'notifications': notifications.toJson(),
      'reader': reader.toJson(),
      'privacy': privacy.toJson(),
      'other': other,
    };

  UserSettings copyWith({
    NotificationSettings? notifications,
    ReaderSettings? reader,
    PrivacySettings? privacy,
    Map<String, dynamic>? other,
  }) => UserSettings(
      notifications: notifications ?? this.notifications,
      reader: reader ?? this.reader,
      privacy: privacy ?? this.privacy,
      other: other ?? this.other,
    );

  @override
  List<Object?> get props => <Object?>[notifications, reader, privacy, other];
}

/// 通知设置
class NotificationSettings extends Equatable {

  const NotificationSettings({
    this.enabled = true,
    this.updateNotification = true,
    this.recommendationNotification = true,
    this.commentNotification = true,
    this.systemNotification = true,
    this.marketingNotification = false,
    this.doNotDisturbStart,
    this.doNotDisturbEnd,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      updateNotification: json['update_notification'] as bool? ?? true,
      recommendationNotification: json['recommendation_notification'] as bool? ?? true,
      commentNotification: json['comment_notification'] as bool? ?? true,
      systemNotification: json['system_notification'] as bool? ?? true,
      marketingNotification: json['marketing_notification'] as bool? ?? false,
      doNotDisturbStart: json['do_not_disturb_start'] as String?,
      doNotDisturbEnd: json['do_not_disturb_end'] as String?,
    );
  /// 推送通知总开关
  final bool enabled;
  
  /// 更新通知
  final bool updateNotification;
  
  /// 推荐通知
  final bool recommendationNotification;
  
  /// 评论通知
  final bool commentNotification;
  
  /// 系统通知
  final bool systemNotification;
  
  /// 营销通知
  final bool marketingNotification;
  
  /// 免打扰时间段开始
  final String? doNotDisturbStart;
  
  /// 免打扰时间段结束
  final String? doNotDisturbEnd;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'enabled': enabled,
      'update_notification': updateNotification,
      'recommendation_notification': recommendationNotification,
      'comment_notification': commentNotification,
      'system_notification': systemNotification,
      'marketing_notification': marketingNotification,
      'do_not_disturb_start': doNotDisturbStart,
      'do_not_disturb_end': doNotDisturbEnd,
    };

  NotificationSettings copyWith({
    bool? enabled,
    bool? updateNotification,
    bool? recommendationNotification,
    bool? commentNotification,
    bool? systemNotification,
    bool? marketingNotification,
    String? doNotDisturbStart,
    String? doNotDisturbEnd,
  }) => NotificationSettings(
      enabled: enabled ?? this.enabled,
      updateNotification: updateNotification ?? this.updateNotification,
      recommendationNotification: recommendationNotification ?? this.recommendationNotification,
      commentNotification: commentNotification ?? this.commentNotification,
      systemNotification: systemNotification ?? this.systemNotification,
      marketingNotification: marketingNotification ?? this.marketingNotification,
      doNotDisturbStart: doNotDisturbStart ?? this.doNotDisturbStart,
      doNotDisturbEnd: doNotDisturbEnd ?? this.doNotDisturbEnd,
    );

  @override
  List<Object?> get props => <Object?>[
        enabled,
        updateNotification,
        recommendationNotification,
        commentNotification,
        systemNotification,
        marketingNotification,
        doNotDisturbStart,
        doNotDisturbEnd,
      ];
}

/// 阅读器设置
class ReaderSettings extends Equatable {

  const ReaderSettings({
    this.fontSize = 16.0,
    this.lineSpacing = 1.5,
    this.pageMargin = 24.0,
    this.theme = 'light',
    this.pageMode = 'slide',
    this.keepScreenOn = false,
    this.volumeKeyTurnPage = false,
    this.autoBrightness = true,
    this.brightness = 0.5,
  });

  factory ReaderSettings.fromJson(Map<String, dynamic> json) => ReaderSettings(
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      lineSpacing: (json['line_spacing'] as num?)?.toDouble() ?? 1.5,
      pageMargin: (json['page_margin'] as num?)?.toDouble() ?? 24.0,
      theme: json['theme'] as String? ?? 'light',
      pageMode: json['page_mode'] as String? ?? 'slide',
      keepScreenOn: json['keep_screen_on'] as bool? ?? false,
      volumeKeyTurnPage: json['volume_key_turn_page'] as bool? ?? false,
      autoBrightness: json['auto_brightness'] as bool? ?? true,
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.5,
    );
  /// 字体大小
  final double fontSize;
  
  /// 行间距
  final double lineSpacing;
  
  /// 页边距
  final double pageMargin;
  
  /// 阅读主题
  final String theme;
  
  /// 翻页模式
  final String pageMode;
  
  /// 屏幕常亮
  final bool keepScreenOn;
  
  /// 音量键翻页
  final bool volumeKeyTurnPage;
  
  /// 自动亮度
  final bool autoBrightness;
  
  /// 手动亮度值
  final double brightness;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'font_size': fontSize,
      'line_spacing': lineSpacing,
      'page_margin': pageMargin,
      'theme': theme,
      'page_mode': pageMode,
      'keep_screen_on': keepScreenOn,
      'volume_key_turn_page': volumeKeyTurnPage,
      'auto_brightness': autoBrightness,
      'brightness': brightness,
    };

  ReaderSettings copyWith({
    double? fontSize,
    double? lineSpacing,
    double? pageMargin,
    String? theme,
    String? pageMode,
    bool? keepScreenOn,
    bool? volumeKeyTurnPage,
    bool? autoBrightness,
    double? brightness,
  }) => ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      pageMargin: pageMargin ?? this.pageMargin,
      theme: theme ?? this.theme,
      pageMode: pageMode ?? this.pageMode,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      volumeKeyTurnPage: volumeKeyTurnPage ?? this.volumeKeyTurnPage,
      autoBrightness: autoBrightness ?? this.autoBrightness,
      brightness: brightness ?? this.brightness,
    );

  @override
  List<Object> get props => <Object>[
        fontSize,
        lineSpacing,
        pageMargin,
        theme,
        pageMode,
        keepScreenOn,
        volumeKeyTurnPage,
        autoBrightness,
        brightness,
      ];
}

/// 隐私设置
class PrivacySettings extends Equatable {

  const PrivacySettings({
    this.profileVisible = true,
    this.readingHistoryVisible = false,
    this.bookshelfVisible = false,
    this.allowSearch = true,
    this.allowFriendRequest = true,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
      profileVisible: json['profile_visible'] as bool? ?? true,
      readingHistoryVisible: json['reading_history_visible'] as bool? ?? false,
      bookshelfVisible: json['bookshelf_visible'] as bool? ?? false,
      allowSearch: json['allow_search'] as bool? ?? true,
      allowFriendRequest: json['allow_friend_request'] as bool? ?? true,
    );
  /// 个人资料可见性
  final bool profileVisible;
  
  /// 阅读记录可见性
  final bool readingHistoryVisible;
  
  /// 书架可见性
  final bool bookshelfVisible;
  
  /// 允许搜索
  final bool allowSearch;
  
  /// 允许好友申请
  final bool allowFriendRequest;

  Map<String, dynamic> toJson() => <String, dynamic>{
      'profile_visible': profileVisible,
      'reading_history_visible': readingHistoryVisible,
      'bookshelf_visible': bookshelfVisible,
      'allow_search': allowSearch,
      'allow_friend_request': allowFriendRequest,
    };

  PrivacySettings copyWith({
    bool? profileVisible,
    bool? readingHistoryVisible,
    bool? bookshelfVisible,
    bool? allowSearch,
    bool? allowFriendRequest,
  }) => PrivacySettings(
      profileVisible: profileVisible ?? this.profileVisible,
      readingHistoryVisible: readingHistoryVisible ?? this.readingHistoryVisible,
      bookshelfVisible: bookshelfVisible ?? this.bookshelfVisible,
      allowSearch: allowSearch ?? this.allowSearch,
      allowFriendRequest: allowFriendRequest ?? this.allowFriendRequest,
    );

  @override
  List<Object> get props => <Object>[
        profileVisible,
        readingHistoryVisible,
        bookshelfVisible,
        allowSearch,
        allowFriendRequest,
      ];
}