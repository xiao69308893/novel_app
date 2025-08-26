import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/empty_widget.dart';
import '../blocs/bookshelf/bookshelf_bloc.dart';
import '../widgets/bookshelf_item.dart';
import '../widgets/bookshelf_filter_bar.dart';

/// 书架页面
class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadBookshelf();
  }

  void _loadBookshelf() {
    context.read<BookshelfBloc>().add(const LoadBookshelf());
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '排序方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('最近阅读'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const SortBookshelf(BookshelfSortType.recentRead),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('添加时间'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const SortBookshelf(BookshelfSortType.addTime),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('更新时间'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const SortBookshelf(BookshelfSortType.updateTime),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort_by_alpha),
              title: const Text('书名'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const SortBookshelf(BookshelfSortType.name),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showViewOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '显示方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('网格视图'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const ChangeViewType(BookshelfViewType.grid),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('列表视图'),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  const ChangeViewType(BookshelfViewType.list),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: AppBarUtils.simple(
        title: '我的书架',
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortOptions,
          ),
          IconButton(
            icon: const Icon(Icons.view_module),
            onPressed: _showViewOptions,
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/book/search');
            },
          ),
        ],
      ),
      body: BlocBuilder<BookshelfBloc, BookshelfState>(
        builder: (BuildContext context, BookshelfState state) {
          if (state is BookshelfLoading) {
            return const LoadingWidget();
          }
          
          if (state is BookshelfError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: _loadBookshelf,
            );
          }
          
          if (state is BookshelfLoaded) {
            if (state.books.isEmpty) {
              return EmptyWidget(
                icon: Icons.book,
                message: '书架空空如也',
                description: '快去添加一些喜欢的小说吧',
                actionText: '去发现',
                onAction: () {
                  Navigator.pushNamed(context, '/home');
                },
              );
            }
            
            return Column(
              children: <Widget>[
                // 筛选栏
                BookshelfFilterBar(
                  sortType: state.sortType,
                  viewType: state.viewType,
                  onSortChanged: (BookshelfSortType sortType) {
                    context.read<BookshelfBloc>().add(
                      SortBookshelf(sortType),
                    );
                  },
                  onViewChanged: (BookshelfViewType viewType) {
                    context.read<BookshelfBloc>().add(
                      ChangeViewType(viewType),
                    );
                  },
                ),
                
                // 书籍列表
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => _loadBookshelf(),
                    child: state.viewType == BookshelfViewType.grid
                        ? _buildGridView(state)
                        : _buildListView(state),
                  ),
                ),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildGridView(BookshelfLoaded state) => GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppTheme.spacingRegular,
        mainAxisSpacing: AppTheme.spacingRegular,
      ),
      itemCount: state.books.length,
      itemBuilder: (BuildContext context, int index) {
        final book = state.books[index];
        return BookshelfItem(
          book: book,
          viewType: BookshelfViewType.grid,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/book/detail',
              arguments: <String, dynamic>{'bookId': book.id},
            );
          },
          onLongPress: () {
            _showBookOptions(book);
          },
        );
      },
    );

  Widget _buildListView(BookshelfLoaded state) => ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      itemCount: state.books.length,
      itemBuilder: (BuildContext context, int index) {
        final book = state.books[index];
        return BookshelfItem(
          book: book,
          viewType: BookshelfViewType.list,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/book/detail',
              arguments: <String, dynamic>{'bookId': book.id},
            );
          },
          onLongPress: () {
            _showBookOptions(book);
          },
        );
      },
    );

  void _showBookOptions(dynamic book) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('继续阅读'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/reader',
                  arguments: <String, dynamic>{
                    'bookId': book.id,
                    'chapterId': book.lastChapterId,
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('查看详情'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/book/detail',
                  arguments: <String, dynamic>{'bookId': book.id},
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('移出书架', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                context.read<BookshelfBloc>().add(
                  RemoveFromBookshelf(book.id as String),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}