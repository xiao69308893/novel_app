// 获取排行榜用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ranking.dart';
import '../repositories/home_repository.dart';

class GetRankingUseCase implements UseCase<Ranking, GetRankingParams> {

  GetRankingUseCase(this.repository);
  final HomeRepository repository;

  @override
  Future<Either<AppError, Ranking>> call(GetRankingParams params) async => repository.getRanking(
      type: params.type,
      period: params.period,
      limit: params.limit,
    );
}

class GetRankingParams extends Equatable {

  const GetRankingParams({
    required this.type,
    this.period = RankingPeriod.weekly,
    this.limit = 50,
  });
  final RankingType type;
  final RankingPeriod period;
  final int limit;

  @override
  List<Object> get props => <Object>[type, period, limit];
}
