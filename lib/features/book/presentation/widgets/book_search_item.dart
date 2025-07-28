import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/cached_image.dart';
import '../../../../shared/models/novel_model.dart';

/// 图书搜索项组件
class BookSearchItem extends StatelessWidget {
  final NovelSimpleModel novel;
  final String keyword;
  final VoidCallback onTap;

  const BookSearchItem({
    Key? key,
    required this.novel,
    required this.keyword,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingRegular),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingRegular),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 封面图片
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedImage(
                  imageUrl: novel.coverUrl ?? '',
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: AppTheme.spacingRegular),
              
              // 书籍信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 书名
                    _buildHighlightText(
                      novel.title,
                      keyword,
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // 作者
                    Text(
                      '作者：${novel.authorName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // 分类和状态
                    Row(
                      children: [
                        if (novel.categoryName != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              novel.categoryName!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        if (novel.categoryName != null)
                          const SizedBox(width: AppTheme.spacingSmall),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: novel.isFinished 
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            novel.isFinished ? '完结' : '连载中',
                            style: TextStyle(
                              fontSize: 12,
                              color: novel.isFinished 
                                  ? Colors.green 
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    
                    // 统计信息
                    Row(
                      children: [
                        Icon(
                          Icons.book,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          novel.formattedWordCount,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacingRegular),
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          novel.updateStatusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHighlightText(String text, String keyword, TextStyle style) {
    if (keyword.isEmpty) {
      return Text(text, style: style);
    }

    final lowerText = text.toLowerCase();
    final lowerKeyword = keyword.toLowerCase();
    final index = lowerText.indexOf(lowerKeyword);

    if (index == -1) {
      return Text(text, style: style);
    }

    return RichText(
      text: TextSpan(
        style: style,
        children: [
          if (index > 0)
            TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + keyword.length),
            style: style.copyWith(
              backgroundColor: Colors.yellow.withOpacity(0.3),
            ),
          ),
          if (index + keyword.length < text.length)
            TextSpan(text: text.substring(index + keyword.length)),
        ],
      ),
    );
  }
}