// 小说详情页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/custom_dialog.dart';
import '../cubit/book_detail_cubit.dart';
import '../widgets/book_info_section.dart';
import '../widgets/book_action_section.dart';
import '../widgets/chapter_preview_section.dart';
import '../widgets/book_recommendation_section.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({
    Key? key,
    required this.bookId,
  }) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<BookDetailCubit>().loadBookDetail(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<BookDetailCubit, BookDetailState>(
        listener: (context, state) {
          if (state is BookDetailError) {
            DialogUtils.showError(
              context,
              content: state.message,
            );
          }
        },
        builder: (context, state) {
          if (state is BookDetailLoading) {
            return const Scaffold(
              appBar: CommonAppBar(title: '小说详情'),
              body: LoadingWidget(),
            );
          } else if (state is BookDetailError) {
            return Scaffold(
              appBar: const CommonAppBar(title: '小说详情'),
              body: AppErrorWidget(
                message: state.message,
                onRetry: () => context.read<BookDetailCubit>().loadBookDetail(widget.bookId),
              ),
            );
          } else if (state is BookDetailLoaded) {
            return _buildBookDetail(state);
          }
          
          return const Scaffold(
            appBar: CommonAppBar(title: '小说详情'),
            body: SizedBox.shrink(),
          );
        },
      ),
    );
  }

  Widget _buildBookDetail(BookDetailLoaded state) {
    final bookDetail = state.bookDetail;
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 自定义AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: BookInfoSection(bookDetail: bookDetail),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _showShareDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showMoreActions(context),
              ),
            ],
          ),

          // 操作按钮区域
          SliverToBoxAdapter(
            child: BookActionSection(
              bookDetail: bookDetail,
              onStartReading: () => _startReading(state),
              onToggleFavorite: () => context.read<BookDetailCubit>().toggleFavorite(),
              onDownload: () => context.read<BookDetailCubit>().downloadBook(),
            ),
          ),

          // 章节预览
          SliverToBoxAdapter(
            child: ChapterPreviewSection(
              chapters: state.chapters,
              readingProgress: bookDetail.readingProgress,
              onViewAllChapters: () => _viewAllChapters(context),
              onChapterTap: (chapter) => _readChapter(context, chapter),
            ),
          ),

          // 相似推荐
          if (state.similarBooks.isNotEmpty)
            SliverToBoxAdapter(
              child: BookRecommendationSection(
                title: '相似推荐',
                books: state.similarBooks,
              ),
            ),

          // 作者其他作品
          if (state.authorOtherBooks.isNotEmpty)
            SliverToBoxAdapter(
              child: BookRecommendationSection(
                title: '作者其他作品',
                books: state.authorOtherBooks,
              ),
            ),

          // 底部安全区域
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom),
          ),
        ],
      ),
    );
  }

  void _startReading(BookDetailLoaded state) {
    final chapters = state.chapters;
    final progress = state.bookDetail.readingProgress;
    
    if (chapters.isEmpty) {
      DialogUtils.showError(context, content: '暂无可阅读章节');
      return;
    }

    // 找到要阅读的章节
    String chapterId;
    if (progress != null) {
      chapterId = progress.chapterId;
    } else {
      chapterId = chapters.first.id;
    }

    // 更新阅读进度
    context.read<BookDetailCubit>().startReading(chapterId);
    
    // 跳转到阅读页面
    Navigator.pushNamed(
      context,
      '/reader',
      arguments: {
        'bookId': state.bookDetail.novel.id,
        'chapterId': chapterId,
      },
    );
  }

  void _viewAllChapters(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/book/chapters',
      arguments: {'bookId': widget.bookId},
    );
  }

  void _readChapter(BuildContext context, chapter) {
    Navigator.pushNamed(
      context,
      '/reader',
      arguments: {
        'bookId': widget.bookId,
        'chapterId': chapter.id,
      },
    );
  }

  void _showShareDialog(BuildContext context) {
    DialogUtils.showBottomSheet(
      context,
      title: '分享到',
      items: [
        BottomSheetItem(
          title: '微信',
          icon: const Icon(Icons.chat),
          onTap: () => context.read<BookDetailCubit>().shareBook('wechat'),
        ),
        BottomSheetItem(
          title: '朋友圈',
          icon: const Icon(Icons.share),
          onTap: () => context.read<BookDetailCubit>().shareBook('moments'),
        ),
        BottomSheetItem(
          title: '复制链接',
          icon: const Icon(Icons.link),
          onTap: () => context.read<BookDetailCubit>().shareBook('link'),
        ),
      ],
    );
  }

  void _showMoreActions(BuildContext context) {
    DialogUtils.showBottomSheet(
      context,
      title: '更多操作',
      items: [
        BottomSheetItem(
          title: '评分',
          icon: const Icon(Icons.star),
          onTap: () => _showRatingDialog(context),
        ),
        BottomSheetItem(
          title: '举报',
          icon: const Icon(Icons.report),
          onTap: () => _showReportDialog(context),
        ),
      ],
    );
  }

  void _showRatingDialog(BuildContext context) {
    // TODO: 实现评分对话框
    DialogUtils.showInfo(context, content: '评分功能开发中');
  }

  void _showReportDialog(BuildContext context) {
    // TODO: 实现举报对话框
    DialogUtils.showInfo(context, content: '举报功能开发中');
  }
}