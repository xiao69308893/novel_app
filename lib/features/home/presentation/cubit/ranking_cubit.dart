// 排行榜状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/ranking.dart';
import '../../domain/usecases/get_ranking_usecase.dart';

// 排行榜状态
abstract class RankingState extends Equatable {
  const RankingState();

  @override
  List<Object?> get props => [];
}

class RankingInitial extends RankingState {}

class RankingLoading extends RankingState {}

class RankingLoaded extends RankingState {
  final Map<RankingType, Ranking> rankings;
  final RankingType currentType;
  final RankingPeriod currentPeriod;

  const RankingLoaded({
    required this.rankings,
    required this.currentType,
    required this.currentPeriod,
  });

  @override
  List<Object> get props => [rankings, currentType, currentPeriod];
}

class RankingError extends RankingState {
  final String message;

  const RankingError(this.message);

  @override
  List<Object> get props => [message];
}

// 排行榜Cubit
class RankingCubit extends Cubit<RankingState> {
  final GetRankingUseCase getRankingUseCase;

  RankingCubit({
    required this.getRankingUseCase,
  }) : super(RankingInitial());

  /// 加载排行榜
  Future<void> loadRanking({
    required RankingType type,
    RankingPeriod period = RankingPeriod.weekly,
  }) async {
    emit(RankingLoading());

    final result = await getRankingUseCase(
      GetRankingParams(type: type, period: period),
    );

    result.fold(
      (error) => emit(RankingError(error.message)),
      (ranking) {
        final currentState = state;
        Map<RankingType, Ranking> rankings = {};
        
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
    final currentState = state;
    if (currentState is RankingLoaded) {
      final currentPeriod = currentState.currentPeriod;
      
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
    final currentState = state;
    if (currentState is RankingLoaded) {
      await loadRanking(
        type: currentState.currentType,
        period: period,
      );
    }
  }
}