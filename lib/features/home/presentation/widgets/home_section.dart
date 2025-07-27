// 首页区块组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../shared/models/novel_model.dart';
import 'novel_card.dart';

class HomeSection extends StatelessWidget {
  final String title;
  final List<NovelSimpleModel> novels;
  final VoidCallback? onMoreTap;
  final int maxItems;

  const HomeSection({
    Key? key,
    required this.title,
    required this.novels,
    this.onMoreTap,
    this.maxItems = 6,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final displayNovels = novels.take(maxItems).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingRegular,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onMoreTap != null)
                  GestureDetector(
                    onTap: onMoreTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '更多',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
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

          const SizedBox(height: AppTheme.spacingRegular),

          // 小说列表
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingRegular,
              ),
              itemCount: displayNovels.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(
                    right: AppTheme.spacingRegular,
                  ),
                  child: NovelCard(
                    novel: displayNovels[index],
                    showAuthor: true,
                    onTap: () => _handleNovelTap(context, displayNovels[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleNovelTap(BuildContext context, NovelSimpleModel novel) {
    Navigator.pushNamed(
      context,
      '/novel/detail',
      arguments: {'novelId': novel.id},
    );
  }
}
