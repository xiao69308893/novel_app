import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_widget.dart';
import '../../../home/presentation/cubit/search_cubit.dart';
import '../widgets/book_search_item.dart';

/// 图书搜索页面
class BookSearchPage extends StatefulWidget {
  final String? initialKeyword;

  const BookSearchPage({
    Key? key,
    this.initialKeyword,
  }) : super(key: key);

  @override
  State<BookSearchPage> createState() => _BookSearchPageState();
}

class _BookSearchPageState extends State<BookSearchPage> {
  late TextEditingController _searchController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialKeyword);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    if (widget.initialKeyword?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SearchCubit>().searchNovels(keyword: widget.initialKeyword!);
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final state = context.read<SearchCubit>().state;
      if (state is SearchLoaded && state.hasMore) {
        context.read<SearchCubit>().searchNovels(
          keyword: state.keyword,
          loadMore: true,
        );
      }
    }
  }

  void _onSearch() {
    final keyword = _searchController.text.trim();
    if (keyword.isNotEmpty) {
      context.read<SearchCubit>().searchNovels(keyword: keyword);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: '搜索图书',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // 搜索框
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingRegular),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: '请输入书名、作者或关键词',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundColor,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingRegular,
                        vertical: AppTheme.spacingSmall,
                      ),
                    ),
                    onSubmitted: (_) => _onSearch(),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSmall),
                ElevatedButton(
                  onPressed: _onSearch,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(AppTheme.spacingSmall),
                  ),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          // 搜索结果
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchInitial) {
                  return const EmptyWidget(
                    icon: Icons.search,
                    message: '输入关键词开始搜索',
                  );
                }
                
                if (state is SearchLoading && state is! SearchLoaded) {
                  return const LoadingWidget();
                }
                
                if (state is SearchError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => _onSearch(),
                  );
                }
                
                if (state is SearchLoaded) {
                  if (state.novels.isEmpty) {
                    return const EmptyWidget(
                      icon: Icons.search_off,
                      message: '没有找到相关图书',
                    );
                  }
                  
                  return RefreshIndicator(
                    onRefresh: () async => _onSearch(),
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppTheme.spacingRegular),
                      itemCount: state.novels.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.novels.length) {
                          return const Padding(
                            padding: EdgeInsets.all(AppTheme.spacingRegular),
                            child: LoadingWidget(),
                          );
                        }
                        
                        final novel = state.novels[index];
                        return BookSearchItem(
                          novel: novel,
                          keyword: state.keyword,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/book/detail',
                              arguments: {'bookId': novel.id},
                            );
                          },
                        );
                      },
                    ),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}