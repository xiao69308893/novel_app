import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../app/themes/app_theme.dart';

/// 阅读器顶部导航栏
class ReaderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final NovelModel novel;
  final ChapterModel chapter;
  final bool isVisible;
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onBookmarkPressed;
  final bool hasBookmark;

  const ReaderAppBar({
    Key? key,
    required this.novel,
    required this.chapter,
    this.isVisible = true,
    this.onBackPressed,
    this.onMenuPressed,
    this.onBookmarkPressed,
    this.hasBookmark = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isVisible ? 0 : -100, 0),
      child: AppBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: onBackPressed ?? () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              novel.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              chapter.title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              hasBookmark ? Icons.bookmark : Icons.bookmark_border,
              color: hasBookmark ? Colors.amber : Colors.white,
            ),
            onPressed: onBookmarkPressed,
          ),
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: onMenuPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);
}
