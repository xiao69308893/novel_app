class RegisterUseCase implements UseCase<AuthUser, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<AppError, AuthUser>> call(RegisterParams params) async {
    // 参数验证
    if (params.username.isEmpty) {
      return Left(AppError.validation('用户名不能为空'));
    }
    if (params.password.isEmpty) {
      return Left(AppError.validation('密码不能为空'));
    }
    if (params.password.length < 6) {
      return Left(AppError.validation('密码长度不能少于6位'));
    }

    // 执行注册
    final result = await repository.register(
      username: params.username,
      password: params.password,
      email: params.email,
      phone: params.phone,
      inviteCode: params.inviteCode,
    );

    return result.fold(
      (error) => Left(error),
      (user) async {
        // 保存用户信息到本地
        await repository.saveLocalUser(user);
        return Right(user);
      },
    );
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String password;
  final String? email;
  final String? phone;
  final String? inviteCode;

  const RegisterParams({
    required this.username,
    required this.password,
    this.email,
    this.phone,
    this.inviteCode,
  });

  @override
  List<Object?> get props => [username, password, email, phone, inviteCode];
}