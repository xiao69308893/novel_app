import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/bookshelf_repository.dart';

/// 用户签到用例
class UserCheckIn implements UseCase<Map<String, dynamic>, NoParams> {
  final BookshelfRepository repository;

  UserCheckIn(this.repository);

  @override
  Future<Either<AppError, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.checkIn();
  }
}

/// 获取签到状态用例
class GetCheckInStatus implements UseCase<bool, NoParams> {
  final BookshelfRepository repository;

  GetCheckInStatus(this.repository);

  @override
  Future<Either<AppError, bool>> call(NoParams params) async {
    return await repository.getCheckInStatus();
  }
}