// 搜索状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/usecases/search_novels_usecase.dart';
import '../../domain/repositories/home_repository.dart';

// 搜索状态
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => <Object?>[];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {

  const SearchLoaded({
    required this.novels,
    required this.keyword,
    this.hasMore = true,
    this.currentPage = 1,
  });
  final List<NovelSimpleModel> novels;
  final String keyword;
  final bool hasMore;
  final int currentPage;

  @override
  List<Object> get props => <Object>[novels, keyword, hasMore, currentPage];
}

class SearchError extends SearchState {

  const SearchError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

class SearchSuggestions extends SearchState {

  const SearchSuggestions({
    this.suggestions = const <String>[],
    this.hotKeywords = const <String>[],
    this.history = const <String>[],
  });
  final List<String> suggestions;
  final List<String> hotKeywords;
  final List<String> history;

  @override
  List<Object> get props => <Object>[suggestions, hotKeywords, history];
}

// 搜索Cubit
class SearchCubit extends Cubit<SearchState> {

  SearchCubit({
    required this.searchNovelsUseCase,
    required this.homeRepository,
  }) : super(SearchInitial());
  final SearchNovelsUseCase searchNovelsUseCase;
  final HomeRepository homeRepository;

  /// 搜索小说
  Future<void> searchNovels({
    required String keyword,
    String? categoryId,
    String? status,
    String? sortBy,
    bool loadMore = false,
  }) async {
    if (keyword.trim().isEmpty) {
      emit(const SearchError('请输入搜索关键词'));
      return;
    }

    if (!loadMore) {
      emit(SearchLoading());
    }

    final SearchState currentState = state;
    final int page = loadMore && currentState is SearchLoaded 
        ? currentState.currentPage + 1 
        : 1;

    final Either<AppError, List<NovelSimpleModel>> result = await searchNovelsUseCase(
      SearchNovelsParams(
        keyword: keyword.trim(),
        categoryId: categoryId,
        status: status,
        sortBy: sortBy,
        page: page,
        recordHistory: !loadMore, // 只在首次搜索时记录历史
      ),
    );

    result.fold(
      (AppError error) => emit(SearchError(error.message)),
      (List<NovelSimpleModel> novels) {
        if (loadMore && currentState is SearchLoaded) {
          // 加载更多
          final List<NovelSimpleModel> allNovels = <NovelSimpleModel>[...currentState.novels, ...novels];
          emit(SearchLoaded(
            novels: allNovels,
            keyword: keyword.trim(),
            hasMore: novels.length >= 20, // 假设每页20条
            currentPage: page,
          ));
        } else {
          // 新搜索
          emit(SearchLoaded(
            novels: novels,
            keyword: keyword.trim(),
            hasMore: novels.length >= 20,
            currentPage: page,
          ));
        }
      },
    );
  }

  /// 获取搜索建议
  Future<void> getSearchSuggestions({String? keyword}) async {
    try {
      // 并行获取数据
      final Future<Object> suggestionsFuture = keyword != null && keyword.isNotEmpty
          ? homeRepository.getSearchSuggestions(keyword)
          : Future.value(const Right(<String>[]));
      final Future<Either<AppError, List<String>>> hotKeywordsFuture = homeRepository.getHotSearchKeywords();
      final Future<Either<AppError, List<String>>> historyFuture = homeRepository.getSearchHistory();

      final List<Object> results = await Future.wait(<Future<Object>>[
        suggestionsFuture,
        hotKeywordsFuture,
        historyFuture,
      ]);

      final List<String> suggestions = (results[0] as Either).fold(
        (error) => <String>[],
        (suggestions) => suggestions as List<String>,
      );

      final List<String> hotKeywords = (results[1] as Either).fold(
        (error) => <String>[],
        (keywords) => keywords as List<String>,
      );

      final List<String> history = (results[2] as Either).fold(
        (error) => <String>[],
        (history) => history as List<String>,
      );

      emit(SearchSuggestions(
        suggestions: suggestions,
        hotKeywords: hotKeywords,
        history: history,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  /// 清除搜索历史
  Future<void> clearSearchHistory() async {
    final Either<AppError, bool> result = await homeRepository.clearSearchHistory();
    result.fold(
      (AppError error) => emit(SearchError(error.message)),
      (bool success) => getSearchSuggestions(), // 重新获取建议
    );
  }

  /// 重置状态
  void reset() {
    emit(SearchInitial());
  }
}
