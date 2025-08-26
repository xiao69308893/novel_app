// 验证码状态管理
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// 需要先运行 flutter pub add equatable 添加依赖
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../domain/repositories/auth_repository.dart';

// 验证码状态
abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object> get props => <Object>[];
}

class VerificationInitial extends VerificationState {}

class VerificationSending extends VerificationState {}

class VerificationSent extends VerificationState {

  const VerificationSent(this.countdown);
  final int countdown;

  @override
  List<Object> get props => <Object>[countdown];
}

class VerificationError extends VerificationState {

  const VerificationError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

// 验证码Cubit
class VerificationCubit extends Cubit<VerificationState> {

  VerificationCubit({required this.authRepository}) : super(VerificationInitial());
  final AuthRepository authRepository;
  Timer? _timer;
  int _countdown = 0;

  /// 发送手机验证码
  Future<void> sendSmsCode({
    required String phone,
    required String type,
  }) async {
    if (state is VerificationSent) return; // 防止重复发送

    emit(VerificationSending());

    final Either<AppError, bool> result = await authRepository.sendSmsCode(
      phone: phone,
      type: type,
    );

    result.fold(
      (AppError error) => emit(VerificationError(error.message)),
      (bool success) => _startCountdown(),
    );
  }

  /// 发送邮箱验证码
  Future<void> sendEmailCode({
    required String email,
    required String type,
  }) async {
    if (state is VerificationSent) return; // 防止重复发送

    emit(VerificationSending());

    final Either<AppError, bool> result = await authRepository.sendEmailCode(
      email: email,
      type: type,
    );

    result.fold(
      (AppError error) => emit(VerificationError(error.message)),
      (bool success) => _startCountdown(),
    );
  }

  /// 开始倒计时
  void _startCountdown() {
    _countdown = 60;
    emit(VerificationSent(_countdown));

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      _countdown--;
      if (_countdown <= 0) {
        timer.cancel();
        emit(VerificationInitial());
      } else {
        emit(VerificationSent(_countdown));
      }
    });
  }

  /// 重置状态
  void reset() {
    _timer?.cancel();
    _countdown = 0;
    emit(VerificationInitial());
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}