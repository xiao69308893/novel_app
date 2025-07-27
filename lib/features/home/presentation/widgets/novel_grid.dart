// 小说网格组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../shared/models/novel_model.dart';
import 'novel_card.dart';

class NovelGrid extends StatelessWidget {
  final List<NovelSimpleModel> novels;
  final int crossAxisCount;
  final double childAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const NovelGrid({
    Key? key,
    required this.novels,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.6,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingRegular),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppTheme.spacingRegular,
        mainAxisSpacing: AppTheme.spacingRegular,
      ),
      itemCount: novels.length,
      itemBuilder: (context, index) {
        return NovelCard(
          novel: novels[index],
          showAuthor: true,
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