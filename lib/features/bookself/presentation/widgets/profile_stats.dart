import 'package:flutter/material.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../app/themes/app_theme.dart';

/// 个人统计组件
class ProfileStats extends StatelessWidget {
  final UserStats stats;

  const ProfileStats({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingRegular),
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '我的统计',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // 第一行统计
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.book_outlined,
                  label: '已读小说',
                  value: stats.booksRead.toString(),
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time_outlined,
                  label: '阅读时长',
                  value: _formatReadingTime(stats.totalReadingTime),
                  color: Colors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // 第二行统计
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite_outline,
                  label: '收藏数',
                  value: stats.favoritesCount.toString(),
                  color: Colors.red,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.comment_outlined,
                  label: '评论数',
                  value: stats.commentsCount.toString(),
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // 第三行统计
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.checklist_outlined,
                  label: '签到天数',
                  value: stats.checkinDays.toString(),
                  color: Colors.purple,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.share_outlined,
                  label: '分享次数',
                  value: stats.shareCount.toString(),
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingRegular),
          
          // 阅读统计
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingRegular),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '平均阅读时长',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${stats.averageReadingHours.toStringAsFixed(1)}小时/本',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingSmall),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '平均阅读速度',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${stats.averageReadingSpeed.toStringAsFixed(0)}字/分钟',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: AppTheme.spacingSmall),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _formatReadingTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 24) {
      final days = hours ~/ 24;
      final remainingHours = hours % 24;
      return '${days}天${remainingHours}小时';
    } else if (hours > 0) {
      return '${hours}小时${minutes}分钟';
    } else {
      return '${minutes}分钟';
    }
  }
}