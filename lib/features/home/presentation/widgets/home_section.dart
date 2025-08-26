// 首页区块组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/models/novel_model.dart';
import 'novel_card.dart';

class HomeSectionWidget extends StatelessWidget {

  const HomeSectionWidget({
    required this.title, required this.novels, super.key,
    this.onMoreTap,
    this.maxItems = 6,
  });
  final String title;
  final List<NovelSimpleModel> novels;
  final VoidCallback? onMoreTap;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    if (novels.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    final List<NovelSimpleModel> displayNovels = novels.take(maxItems).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // 标题栏
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingRegular,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
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
                      children: <Widget>[
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
              itemBuilder: (BuildContext context, int index) => Container(
                  width: 120,
                  margin: const EdgeInsets.only(
                    right: AppTheme.spacingRegular,
                  ),
                  child: NovelCard(
                    novel: displayNovels[index],
                    onTap: () => _handleNovelTap(context, displayNovels[index]),
                  ),
                ),
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
      arguments: <String, String>{'novelId': novel.id},
    );
  }
}
