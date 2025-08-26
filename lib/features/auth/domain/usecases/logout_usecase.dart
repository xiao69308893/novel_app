import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<bool, NoParams> {

  LogoutUseCase(this.repository);
  final AuthRepository repository;

  @override
  Future<Either<AppError, bool>> call(NoParams params) async {
    // 执行远程登出
    final Either<AppError, bool> result = await repository.logout();
    
    // 无论远程登出是否成功，都清除本地数据
    await repository.clearLocalData();
    
    return result;
  }
}