// 推荐小说区域组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../shared/models/novel_model.dart';
import '../../../home/presentation/widgets/novel_card.dart';

class BookRecommendationSection extends StatelessWidget {
  final String title;
  final List<NovelSimpleModel> books;

  const BookRecommendationSection({
    Key? key,
    required this.title,
    required this.books,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        children: [
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
              itemBuilder: (context, index) {
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(
                    right: AppTheme.spacingRegular,
                  ),
                  child: NovelCard(
                    novel: books[index],
                    showAuthor: true,
                    onTap: () => _handleBookTap(context, books[index]),
                  ),
                );
              },
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
      arguments: {'bookId': book.id},
    );
  }
}