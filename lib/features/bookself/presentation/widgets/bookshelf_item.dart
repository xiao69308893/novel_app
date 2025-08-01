import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/cached_image.dart';

/// 书架视图类型
enum BookshelfViewType { grid, list }

/// 书架排序类型
enum BookshelfSortType { recentRead, addTime, updateTime, name }

/// 书架项组件
class BookshelfItem extends StatelessWidget {
  final dynamic book; // 使用dynamic因为具体的Book模型可能还未定义
  final BookshelfViewType viewType;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const BookshelfItem({
    Key? key,
    required this.book,
    required this.viewType,
    required this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return viewType == BookshelfViewType.grid
        ? _buildGridItem(context)
        : _buildListItem(context);
  }

  Widget _buildGridItem(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 封面
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedImage(
                      imageUrl: book.coverUrl ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // 阅读进度指示器
                  if (book.readingProgress != null && book.readingProgress > 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: book.readingProgress / 100,
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // 更新标识
                  if (book.hasUpdate == true)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          
          // 书名
          Text(
            book.title ?? '',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSmall),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingRegular),
          child: Row(
            children: [
              // 封面
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: CachedImage(
                      imageUrl: book.coverUrl ?? '',
                      width: 50,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // 更新标识
                  if (book.hasUpdate == true)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: AppTheme.spacingRegular),
              
              // 书籍信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 书名
                    Text(
                      book.title ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // 作者
                    Text(
                      book.author ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // 阅读进度
                    if (book.lastChapterTitle != null)
                      Text(
                        '读到：${book.lastChapterTitle}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    // 阅读进度条
                    if (book.readingProgress != null && book.readingProgress > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTheme.spacingSmall),
                        child: Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: book.readingProgress / 100,
                                backgroundColor: Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingSmall),
                            Text(
                              '${book.readingProgress.toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // 操作按钮
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: onLongPress,
              ),
            ],
          ),
        ),
      ),
    );
  }
}