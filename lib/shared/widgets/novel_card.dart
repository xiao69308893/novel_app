import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/themes/app_theme.dart';
import '../models/novel_model.dart';
import 'cached_image.dart';

/// 小说卡片组件
class NovelCard extends StatelessWidget {
  final NovelSimpleModel novel;
  final bool showAuthor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const NovelCard({
    Key? key,
    required this.novel,
    this.showAuthor = true,
    this.onTap,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? 120.w,
        height: height ?? 200.h,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图片
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppTheme.radiusSmall),
                ),
                child: CachedImage(
                  imageUrl: novel.coverUrl ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.book,
                      size: 40.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            
            // 信息区域
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(AppTheme.spacingSmall.sp),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(AppTheme.radiusSmall),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 标题
                    Text(
                      novel.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (showAuthor) ...[
                      SizedBox(height: 4.h),
                      // 作者
                      Text(
                        novel.authorName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // 状态信息
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(novel.status),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            _getStatusText(novel.status),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontSize: 10.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        
                        Expanded(
                          child: Text(
                            '${novel.wordCount}字',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(NovelStatus status) {
    switch (status) {
      case NovelStatus.serializing:
        return Colors.green;
      case NovelStatus.completed:
        return Colors.blue;
      case NovelStatus.paused:
        return Colors.orange;
      case NovelStatus.dropped:
        return Colors.red;
    }
  }

  String _getStatusText(NovelStatus status) {
    switch (status) {
      case NovelStatus.serializing:
        return '连载';
      case NovelStatus.completed:
        return '完结';
      case NovelStatus.paused:
        return '暂停';
      case NovelStatus.dropped:
        return '太监';
    }
  }
}