// 首页状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/banner.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/home_config.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../../../core/usecases/usecase.dart';

// 首页状态
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final HomeConfig config;
  final List<Banner> banners;
  final List<Recommendation> recommendations;

  const HomeLoaded({
    required this.config,
    this.banners = const [],
    this.recommendations = const [],
  });

  @override
  List<Object> get props => [config, banners, recommendations];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}

// 首页Cubit
class HomeCubit extends Cubit<HomeState> {
  final GetHomeDataUseCase getHomeDataUseCase;

  HomeCubit({
    required this.getHomeDataUseCase,
  }) : super(HomeInitial());

  /// 加载首页数据
  Future<void> loadHomeData() async {
    emit(HomeLoading());

    final result = await getHomeDataUseCase(const NoParams());

    result.fold(
      (error) => emit(HomeError(error.message)),
      (homeData) => emit(HomeLoaded(
        config: homeData.config,
        banners: homeData.banners,
        recommendations: homeData.recommendations,
      )),
    );
  }

  /// 刷新首页数据
  Future<void> refreshHomeData() async {
    // 保持当前状态，在后台刷新
    final result = await getHomeDataUseCase(const NoParams());

    result.fold(
      (error) => emit(HomeError(error.message)),
      (homeData) => emit(HomeLoaded(
        config: homeData.config,
        banners: homeData.banners,
        recommendations: homeData.recommendations,
      )),
    );
  }
}
