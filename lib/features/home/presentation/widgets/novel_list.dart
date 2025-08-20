// 小说列表组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/models/novel_model.dart';

class NovelList extends StatelessWidget {
  final List<NovelSimpleModel> novels;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const NovelList({
    Key? key,
    required this.novels,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingRegular),
      itemCount: novels.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return NovelListItem(
          novel: novels[index],
          onTap: () => _handleNovelTap(context, novels[index]),
        );
      },
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

class NovelListItem extends StatelessWidget {
  final NovelSimpleModel novel;
  final VoidCallback? onTap;

  const NovelListItem({
    Key? key,
    required this.novel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 60,
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          child: novel.coverUrl != null
              ? Image.network(
                  novel.coverUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.book, color: Colors.grey),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.book, color: Colors.grey),
                ),
        ),
      ),
      title: Text(
        novel.title,
        style: theme.textTheme.titleSmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            novel.authorName,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                novel.formattedWordCount,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                novel.updateStatusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (novel.isVip)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
          if (novel.isHot)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
        ],
      ),
    );
  }
}
