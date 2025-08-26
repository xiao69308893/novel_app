// 排行榜状态管理
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../domain/entities/ranking.dart';
import '../../domain/usecases/get_ranking_usecase.dart';

// 排行榜状态
abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => <Object?>[];
}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {

  const RankingLoaded({
    required this.rankings,
    required this.currentType,
    required this.currentPeriod,
  });
  final Map<RankingType, Ranking> rankings;
  final RankingType currentType;
  final RankingPeriod currentPeriod;

  @override
  List<Object> get props => <Object>[rankings, currentType, currentPeriod];
}

class RankingError extends RankingState {

  const RankingError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

// 排行榜Cubit
class RankingCubit extends Cubit<RankingState> {

  RankingCubit({
    required this.getRankingUseCase,
  }) : super(RankingInitial());
  final GetRankingUseCase getRankingUseCase;

  /// 加载排行榜
  Future<void> loadRanking({
    required RankingType type,
    RankingPeriod period = RankingPeriod.weekly,
  }) async {
    emit(RankingLoading());

    final Either<AppError, Ranking> result = await getRankingUseCase(
      GetRankingParams(type: type, period: period),
    );

    result.fold(
      (AppError error) => emit(RankingError(error.message)),
      (Ranking ranking) {
        final RankingState currentState = state;
        Map<RankingType, Ranking> rankings = <RankingType, Ranking>{};
        
        if (currentState is RankingLoaded) {
          rankings = Map.from(currentState.rankings);
        }
        
        rankings[type] = ranking;
        
        emit(RankingLoaded(
          rankings: rankings,
          currentType: type,
          currentPeriod: period,
        ));
      },
    );
  }

  /// 切换排行榜类型
  Future<void> switchRankingType(RankingType type) async {
    final RankingState currentState = state;
    if (currentState is RankingLoaded) {
      final RankingPeriod currentPeriod = currentState.currentPeriod;
      
      // 如果已有数据，直接切换
      if (currentState.rankings.containsKey(type)) {
        emit(RankingLoaded(
          rankings: currentState.rankings,
          currentType: type,
          currentPeriod: currentPeriod,
        ));
      } else {
        // 没有数据，需要加载
        await loadRanking(type: type, period: currentPeriod);
      }
    } else {
      // 初始加载
      await loadRanking(type: type);
    }
  }

  /// 切换时间周期
  Future<void> switchPeriod(RankingPeriod period) async {
    final RankingState currentState = state;
    if (currentState is RankingLoaded) {
      await loadRanking(
        type: currentState.currentType,
        period: period,
      );
    }
  }
}