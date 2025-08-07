import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../shared/models/user_model.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取用户信息用例
class GetUserProfile extends UseCase<UserModel, NoParams> {
  final BookshelfRepository repository;

  const GetUserProfile(this.repository);

  @override
  ResultFuture<UserModel> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}

/// 更新用户信息用例
class UpdateUserProfile extends UseCase<UserModel, UpdateUserProfileParams> {
  final BookshelfRepository repository;

  const UpdateUserProfile(this.repository);

  @override
  ResultFuture<UserModel> call(UpdateUserProfileParams params) async {
    // 需要先获取当前用户信息，然后更新
    final currentUserResult = await repository.getUserProfile();
    return currentUserResult.fold(
      (error) => Left(error),
      (userProfile) {
        // 创建更新后的UserModel
        final updatedUser = UserModel(
          id: userProfile.user.id,
          username: userProfile.user.username,
          email: params.email ?? userProfile.user.email,
          phone: params.phone ?? userProfile.user.phone,
          nickname: params.nickname ?? userProfile.user.nickname,
          avatar: params.avatar ?? userProfile.user.avatar,
          bio: params.bio ?? userProfile.user.bio,
          gender: userProfile.user.gender,
          birthday: userProfile.user.birthday,
          status: userProfile.user.status,
          vipLevel: userProfile.user.vipLevel,
          vipExpiredAt: userProfile.user.vipExpiredAt,
          createdAt: userProfile.user.createdAt,
          updatedAt: DateTime.now(),
        );
        return repository.updateUserProfile(updatedUser);
      },
    );
  }
}

/// 更新用户信息参数
class UpdateUserProfileParams extends Equatable {
  final String? nickname;
  final String? avatar;
  final String? bio;
  final String? email;
  final String? phone;

  const UpdateUserProfileParams({
    this.nickname,
    this.avatar,
    this.bio,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [nickname, avatar, bio, email, phone];
}

/// 获取用户统计用例
class GetUserStats extends UseCase<UserStats, NoParams> {
  final BookshelfRepository repository;

  const GetUserStats(this.repository);

  @override
  ResultFuture<UserStats> call(NoParams params) async {
    return await repository.getUserStats();
  }
}

/// 获取用户设置用例
class GetUserSettings extends UseCase<UserSettings, NoParams> {
  final BookshelfRepository repository;

  const GetUserSettings(this.repository);

  @override
  ResultFuture<UserSettings> call(NoParams params) async {
    return await repository.getUserSettings();
  }
}

/// 更新用户设置用例
class UpdateUserSettings extends UseCase<void, UpdateUserSettingsParams> {
  final BookshelfRepository repository;

  const UpdateUserSettings(this.repository);

  @override
  ResultFuture<void> call(UpdateUserSettingsParams params) async {
    // 需要先获取当前设置，然后更新
    final currentSettingsResult = await repository.getUserSettings();
    return currentSettingsResult.fold(
      (error) => Left(error),
      (currentSettings) {
        // 创建更新后的UserSettings
        final updatedSettings = UserSettings(
          notifications: params.notifications ?? currentSettings.notifications,
          reader: params.reader ?? currentSettings.reader,
          privacy: params.privacy ?? currentSettings.privacy,
          other: currentSettings.other,
        );
        return repository.updateUserSettings(updatedSettings);
      },
    );
  }
}

/// 更新用户设置参数
class UpdateUserSettingsParams extends Equatable {
  final ReaderSettings? reader;
  final NotificationSettings? notifications;
  final PrivacySettings? privacy;

  const UpdateUserSettingsParams({
    this.reader,
    this.notifications,
    this.privacy,
  });

  @override
  List<Object?> get props => [reader, notifications, privacy];
}

/// 签到用例
class Checkin extends UseCase<Map<String, dynamic>, NoParams> {
  final BookshelfRepository repository;

  const Checkin(this.repository);

  @override
  ResultFuture<Map<String, dynamic>> call(NoParams params) async {
    return await repository.checkIn();
  }
}

/// 获取签到状态用例
class GetCheckinStatus extends UseCase<bool, NoParams> {
  final BookshelfRepository repository;

  const GetCheckinStatus(this.repository);

  @override
  ResultFuture<bool> call(NoParams params) async {
    return await repository.getCheckInStatus();
  }
}

/// 同步数据用例
class SyncUserData extends UseCase<void, NoParams> {
  final BookshelfRepository repository;

  const SyncUserData(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    return await repository.syncData();
  }
}

/// 导出用户数据用例
class ExportUserData extends UseCase<String, NoParams> {
  final BookshelfRepository repository;

  const ExportUserData(this.repository);

  @override
  ResultFuture<String> call(NoParams params) async {
    return await repository.exportUserData();
  }
}

/// 导入用户数据用例
class ImportUserData extends UseCase<void, String> {
  final BookshelfRepository repository;

  const ImportUserData(this.repository);

  @override
  ResultFuture<void> call(String dataPath) async {
    return await repository.importUserData(dataPath: dataPath);
  }
}

/// 删除账户用例
class DeleteAccount extends UseCase<void, NoParams> {
  final BookshelfRepository repository;

  const DeleteAccount(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    return await repository.deleteAccount();
  }
}

/// 修改密码用例
class ChangePassword extends UseCase<void, ChangePasswordParams> {
  final BookshelfRepository repository;

  const ChangePassword(this.repository);

  @override
  ResultFuture<void> call(ChangePasswordParams params) async {
    return await repository.changePassword(
      oldPassword: params.oldPassword,
      newPassword: params.newPassword,
    );
  }
}

/// 修改密码参数
class ChangePasswordParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordParams({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];
}