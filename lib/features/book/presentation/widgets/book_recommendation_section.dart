// 推荐小说组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/widgets/novel_card.dart';

class BookRecommendationSection extends StatelessWidget {

  const BookRecommendationSection({
    required this.title, required this.books, super.key,
  });
  final String title;
  final List<NovelSimpleModel> books;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    if (books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingRegular,
        vertical: AppTheme.spacingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSmall,
            ),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.spacingRegular),

          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSmall,
              ),
              itemCount: books.length,
              itemBuilder: (BuildContext context, int index) => Container(
                  width: 120,
                  margin: const EdgeInsets.only(
                    right: AppTheme.spacingRegular,
                  ),
                  child: NovelCard(
                    novel: books[index],
                    onTap: () => _handleBookTap(context, books[index]),
                  ),
                ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleBookTap(BuildContext context, NovelSimpleModel book) {
    Navigator.pushNamed(
      context,
      '/book/detail',
      arguments: <String, String>{'bookId': book.id},
    );
  }
}