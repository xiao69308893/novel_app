// 搜索状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../shared/models/novel_model.dart';
import '../../domain/usecases/search_novels_usecase.dart';
import '../../domain/repositories/home_repository.dart';

// 搜索状态
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<NovelSimpleModel> novels;
  final String keyword;
  final bool hasMore;
  final int currentPage;

  const SearchLoaded({
    required this.novels,
    required this.keyword,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [novels, keyword, hasMore, currentPage];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object> get props => [message];
}

class SearchSuggestions extends SearchState {
  final List<String> suggestions;
  final List<String> hotKeywords;
  final List<String> history;

  const SearchSuggestions({
    this.suggestions = const [],
    this.hotKeywords = const [],
    this.history = const [],
  });

  @override
  List<Object> get props => [suggestions, hotKeywords, history];
}

// 搜索Cubit
class SearchCubit extends Cubit<SearchState> {
  final SearchNovelsUseCase searchNovelsUseCase;
  final HomeRepository homeRepository;

  SearchCubit({
    required this.searchNovelsUseCase,
    required this.homeRepository,
  }) : super(SearchInitial());

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

    final currentState = state;
    final page = loadMore && currentState is SearchLoaded 
        ? currentState.currentPage + 1 
        : 1;

    final result = await searchNovelsUseCase(
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
      (error) => emit(SearchError(error.message)),
      (novels) {
        if (loadMore && currentState is SearchLoaded) {
          // 加载更多
          final allNovels = [...currentState.novels, ...novels];
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
      final suggestionsFuture = keyword != null && keyword.isNotEmpty
          ? homeRepository.getSearchSuggestions(keyword)
          : Future.value(const Right(<String>[]));
      final hotKeywordsFuture = homeRepository.getHotSearchKeywords();
      final historyFuture = homeRepository.getSearchHistory();

      final results = await Future.wait([
        suggestionsFuture,
        hotKeywordsFuture,
        historyFuture,
      ]);

      final suggestions = (results[0] as Either).fold(
        (error) => <String>[],
        (suggestions) => suggestions as List<String>,
      );

      final hotKeywords = (results[1] as Either).fold(
        (error) => <String>[],
        (keywords) => keywords as List<String>,
      );

      final history = (results[2] as Either).fold(
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
    final result = await homeRepository.clearSearchHistory();
    result.fold(
      (error) => emit(SearchError(error.message)),
      (success) => getSearchSuggestions(), // 重新获取建议
    );
  }

  /// 重置状态
  void reset() {
    emit(SearchInitial());
  }
}
