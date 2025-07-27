// 获取排行榜用例
import 'package:dartz/dartz.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/ranking.dart';
import '../repositories/home_repository.dart';

class GetRankingUseCase implements UseCase<Ranking, GetRankingParams> {
  final HomeRepository repository;

  GetRankingUseCase(this.repository);

  @override
  Future<Either<AppError, Ranking>> call(GetRankingParams params) async {
    return await repository.getRanking(
      type: params.type,
      period: params.period,
      limit: params.limit,
    );
  }
}

class GetRankingParams extends Equatable {
  final RankingType type;
  final RankingPeriod period;
  final int limit;

  const GetRankingParams({
    required this.type,
    this.period = RankingPeriod.weekly,
    this.limit = 50,
  });

  @override
  List<Object> get props => [type, period, limit];
}
