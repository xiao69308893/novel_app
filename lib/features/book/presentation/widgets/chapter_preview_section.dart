// 章节预览区域组件
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/models/chapter_model.dart';

class ChapterPreviewSection extends StatelessWidget {
  final List<ChapterSimpleModel> chapters;
  final ReadingProgress? readingProgress;
  final VoidCallback? onViewAllChapters;
  final Function(ChapterSimpleModel)? onChapterTap;

  const ChapterPreviewSection({
    Key? key,
    required this.chapters,
    this.readingProgress,
    this.onViewAllChapters,
    this.onChapterTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (chapters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingRegular),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingRegular),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目录',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: onViewAllChapters,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '查看全部',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: AppTheme.fontSizeSmall,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 章节列表（显示前几章）
          ...chapters.take(5).map((chapter) {
            final isCurrentChapter = readingProgress?.chapterId == chapter.id;
            
            return ListTile(
              title: Text(
                chapter.fullTitle,
                style: TextStyle(
                  color: isCurrentChapter ? theme.primaryColor : null,
                  fontWeight: isCurrentChapter ? FontWeight.w600 : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  Text(
                    chapter.formattedWordCount,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Text(
                    chapter.priceText,
                    style: TextStyle(
                      color: chapter.isFree ? Colors.green : Colors.orange,
                      fontSize: AppTheme.fontSizeXSmall,
                    ),
                  ),
                  if (isCurrentChapter) ...[
                    const SizedBox(width: AppTheme.spacingSmall),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        '正在阅读',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailing: chapter.isCached
                  ? const Icon(Icons.download_done, size: 16, color: Colors.green)
                  : null,
              onTap: () => onChapterTap?.call(chapter),
            );
          }).toList(),

          if (chapters.length > 5)
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              child: Center(
                child: GestureDetector(
                  onTap: onViewAllChapters,
                  child: Text(
                    '还有${chapters.length - 5}章，点击查看全部',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: AppTheme.fontSizeSmall,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
