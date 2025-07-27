// 小说操作区域组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../domain/entities/book_detail.dart';

class BookActionSection extends StatelessWidget {
  final BookDetail bookDetail;
  final VoidCallback? onStartReading;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDownload;

  const BookActionSection({
    Key? key,
    required this.bookDetail,
    this.onStartReading,
    this.onToggleFavorite,
    this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      child: Column(
        children: [
          // 统计信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.visibility,
                label: '阅读',
                value: bookDetail.stats.formattedViews,
              ),
              _buildStatItem(
                icon: Icons.favorite,
                label: '收藏',
                value: bookDetail.stats.formattedFavorites,
              ),
              _buildStatItem(
                icon: Icons.comment,
                label: '评论',
                value: '${bookDetail.stats.commentCount}',
              ),
              _buildStatItem(
                icon: Icons.share,
                label: '分享',
                value: '${bookDetail.stats.shareCount}',
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingLarge),

          // 操作按钮
          Row(
            children: [
              // 开始阅读
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  onPressed: onStartReading,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow),
                      const SizedBox(width: AppTheme.spacingSmall),
                      Text(
                        bookDetail.hasProgress ? '继续阅读' : '开始阅读',
                        style: const TextStyle(
                          fontSize: AppTheme.fontSizeMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingRegular),

              // 收藏按钮
              _buildActionButton(
                icon: bookDetail.isFavorited ? Icons.favorite : Icons.favorite_border,
                color: bookDetail.isFavorited ? Colors.red : Colors.grey,
                onTap: onToggleFavorite,
              ),

              const SizedBox(width: AppTheme.spacingRegular),

              // 下载按钮
              _buildActionButton(
                icon: bookDetail.isDownloaded ? Icons.download_done : Icons.download,
                color: bookDetail.isDownloaded ? Colors.green : Colors.grey,
                onTap: onDownload,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: AppTheme.fontSizeSmall,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.fontSizeXSmall,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}
