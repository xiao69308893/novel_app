import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../errors/app_error.dart';

abstract class UseCase<Type, Params> {
  Future<Either<AppError, Type>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();
  
  @override
  List<Object> get props => [];
}