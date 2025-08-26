// 首页状态管理
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../domain/entities/banner.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/entities/home_config.dart';
import '../../domain/usecases/get_home_data_usecase.dart';
import '../../../../core/usecases/usecase.dart';

// 首页状态
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => <Object?>[];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {

  const HomeLoaded({
    required this.config,
    this.banners = const <Banner>[],
    this.recommendations = const <Recommendation>[],
  });
  final HomeConfig config;
  final List<Banner> banners;
  final List<Recommendation> recommendations;

  @override
  List<Object> get props => <Object>[config, banners, recommendations];
}

class HomeError extends HomeState {

  const HomeError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

// 首页Cubit
class HomeCubit extends Cubit<HomeState> {

  HomeCubit({
    required this.getHomeDataUseCase,
  }) : super(HomeInitial());
  final GetHomeDataUseCase getHomeDataUseCase;

  /// 加载首页数据
  Future<void> loadHomeData() async {
    emit(HomeLoading());

    final Either<AppError, HomeData> result = await getHomeDataUseCase(const NoParams());

    result.fold(
      (AppError error) => emit(HomeError(error.message)),
      (HomeData homeData) => emit(HomeLoaded(
        config: homeData.config,
        banners: homeData.banners,
        recommendations: homeData.recommendations,
      )),
    );
  }

  /// 刷新首页数据
  Future<void> refreshHomeData() async {
    // 保持当前状态，在后台刷新
    final Either<AppError, HomeData> result = await getHomeDataUseCase(const NoParams());

    result.fold(
      (AppError error) => emit(HomeError(error.message)),
      (HomeData homeData) => emit(HomeLoaded(
        config: homeData.config,
        banners: homeData.banners,
        recommendations: homeData.recommendations,
      )),
    );
  }
}
