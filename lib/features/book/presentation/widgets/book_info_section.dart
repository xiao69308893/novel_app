// 小说信息区域组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../domain/entities/book_detail.dart';

class BookInfoSection extends StatelessWidget {
  final BookDetail bookDetail;

  const BookInfoSection({
    Key? key,
    required this.bookDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final novel = bookDetail.novel;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withValues(alpha: 0.8),
            theme.primaryColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingRegular),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 56), // AppBar height
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 封面
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                    child: SizedBox(
                      width: 120,
                      height: 160,
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
                  ),

                  const SizedBox(width: AppTheme.spacingRegular),

                  // 小说信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 标题
                        Text(
                          novel.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeLarge,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: AppTheme.spacingSmall),

                        // 作者
                        Text(
                          novel.author.name,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSizeMedium,
                          ),
                        ),

                        const SizedBox(height: AppTheme.spacingSmall),

                        // 分类和状态
                        Wrap(
                          spacing: AppTheme.spacingSmall,
                          children: [
                            if (novel.category != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  novel.category!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.fontSizeSmall,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: novel.isFinished 
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.orange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                novel.status.displayName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: AppTheme.fontSizeSmall,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppTheme.spacingSmall),

                        // 统计信息
                        Row(
                          children: [
                            Text(
                              novel.formattedWordCount,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: AppTheme.fontSizeSmall,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingRegular),
                            if (novel.rating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    novel.rating!.average.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: AppTheme.fontSizeSmall,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingRegular),

              // 简介
              if (novel.description != null)
                Text(
                  novel.description!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppTheme.fontSizeSmall,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.white.withValues(alpha: 0.2),
      child: const Icon(
        Icons.book,
        color: Colors.white,
        size: 40,
      ),
    );
  }
}
