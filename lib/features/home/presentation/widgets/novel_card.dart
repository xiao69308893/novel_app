// 小说卡片组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/models/novel_model.dart';

class NovelCard extends StatelessWidget {
  final NovelSimpleModel novel;
  final bool showAuthor;
  final bool showStats;
  final VoidCallback? onTap;

  const NovelCard({
    Key? key,
    required this.novel,
    this.showAuthor = true,
    this.showStats = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                child: Stack(
                  children: [
                    // 封面图片
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: novel.coverUrl != null
                          ? Image.network(
                              novel.coverUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder();
                              },
                            )
                          : _buildPlaceholder(),
                    ),
                    
                    // 状态标签
                    if (novel.isVip)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    if (novel.isHot)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const Text(
                            '热门',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingSmall),

          // 小说信息
          Text(
            novel.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          if (showAuthor) ...[
            const SizedBox(height: 2),
            Text(
              novel.authorName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          if (showStats) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 12,
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 2),
                Text(
                  '${novel.wordCount ~/ 10000}万字',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.book,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }
}