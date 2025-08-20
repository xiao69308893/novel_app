import 'package:flutter/material.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../app/themes/app_theme.dart';

/// 章节列表抽屉组件
class ChapterListDrawer extends StatefulWidget {
  final NovelModel novel;
  final List<ChapterSimpleModel> chapters;
  final String currentChapterId;
  final ValueChanged<String>? onChapterSelected;

  const ChapterListDrawer({
    Key? key,
    required this.novel,
    required this.chapters,
    required this.currentChapterId,
    this.onChapterSelected,
  }) : super(key: key);

  @override
  State<ChapterListDrawer> createState() => _ChapterListDrawerState();
}

class _ChapterListDrawerState extends State<ChapterListDrawer> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  List<ChapterSimpleModel> _filteredChapters = [];
  bool _isReverse = false;

  @override
  void initState() {
    super.initState();
    _filteredChapters = widget.chapters;
    
    // 滚动到当前章节
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentChapter();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollToCurrentChapter() {
    final currentIndex = _filteredChapters.indexWhere(
      (chapter) => chapter.id == widget.currentChapterId,
    );
    
    if (currentIndex != -1) {
      final offset = currentIndex * 60.0; // 估算每个项目的高度
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _filterChapters(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChapters = widget.chapters;
      } else {
        _filteredChapters = widget.chapters
            .where((chapter) =>
                chapter.title.toLowerCase().contains(query.toLowerCase()) ||
                chapter.chapterNumber.toString().contains(query))
            .toList();
      }
    });
  }

  void _toggleOrder() {
    setState(() {
      _isReverse = !_isReverse;
      _filteredChapters = _filteredChapters.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // 头部
          _buildHeader(),
          
          // 搜索栏
          _buildSearchBar(),
          
          // 章节列表
          Expanded(
            child: _buildChapterList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppTheme.spacingRegular,
        left: AppTheme.spacingRegular,
        right: AppTheme.spacingRegular,
        bottom: AppTheme.spacingRegular,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.novel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  _isReverse ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                onPressed: _toggleOrder,
                tooltip: _isReverse ? '正序' : '倒序',
              ),
            ],
          ),
          Text(
            '共${widget.chapters.length}章',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索章节...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterChapters('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingRegular,
            vertical: AppTheme.spacingSmall,
          ),
        ),
        onChanged: _filterChapters,
      ),
    );
  }

  Widget _buildChapterList() {
    if (_filteredChapters.isEmpty) {
      return const Center(
        child: Text('没有找到匹配的章节'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _filteredChapters.length,
      itemBuilder: (context, index) {
        final chapter = _filteredChapters[index];
        return _buildChapterItem(chapter);
      },
    );
  }

  Widget _buildChapterItem(ChapterSimpleModel chapter) {
    final isCurrentChapter = chapter.id == widget.currentChapterId;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isCurrentChapter
            ? theme.primaryColor.withValues(alpha: 0.1)
            : null,
        border: Border(
          left: BorderSide(
            color: isCurrentChapter
                ? theme.primaryColor
                : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          chapter.title,
          style: TextStyle(
            fontWeight: isCurrentChapter ? FontWeight.bold : FontWeight.normal,
            color: isCurrentChapter ? theme.primaryColor : null,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              chapter.chapterNumberText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            if (chapter.needPurchase)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chapter.priceText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              )
            else if (!chapter.canRead)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '锁定',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            const Spacer(),
            if (chapter.isCached)
              const Icon(
                Icons.download_done,
                size: 16,
                color: Colors.green,
              ),
          ],
        ),
        trailing: isCurrentChapter
            ? Icon(
                Icons.play_arrow,
                color: theme.primaryColor,
              )
            : null,
        onTap: chapter.canRead
            ? () => widget.onChapterSelected?.call(chapter.id)
            : () => _showPurchaseDialog(chapter),
      ),
    );
  }

  void _showPurchaseDialog(ChapterSimpleModel chapter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('章节购买'),
        content: Text('《${chapter.title}》需要${chapter.priceText}才能阅读'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 实现购买逻辑
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('购买功能开发中...')),
              );
            },
            child: const Text('购买'),
          ),
        ],
      ),
    );
  }
}