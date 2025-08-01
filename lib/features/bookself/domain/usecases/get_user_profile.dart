import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile.dart';
import '../repositories/bookshelf_repository.dart';

/// 获取用户资料用例
class GetUserProfile implements UseCase<UserProfile, NoParams> {
  final BookshelfRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<AppError, UserProfile>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}