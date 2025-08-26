import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import 'bookshelf_item.dart';

/// 书架筛选栏组件
class BookshelfFilterBar extends StatelessWidget {

  const BookshelfFilterBar({
    required this.sortType, required this.viewType, required this.onSortChanged, required this.onViewChanged, super.key,
  });
  final BookshelfSortType sortType;
  final BookshelfViewType viewType;
  final Function(BookshelfSortType) onSortChanged;
  final Function(BookshelfViewType) onViewChanged;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingRegular,
        vertical: AppTheme.spacingSmall,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          // 排序按钮
          Expanded(
            child: GestureDetector(
              onTap: () => _showSortOptions(context),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.sort,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: AppTheme.spacingSmall),
                  Text(
                    _getSortTypeName(sortType),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
          
          // 分隔线
          Container(
            width: 1,
            height: 20,
            color: Colors.grey[300],
          ),
          
          // 视图切换按钮
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.grid_view,
                  color: viewType == BookshelfViewType.grid
                      ? AppTheme.primaryColor
                      : Colors.grey[600],
                ),
                onPressed: () => onViewChanged(BookshelfViewType.grid),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.list,
                  color: viewType == BookshelfViewType.list
                      ? AppTheme.primaryColor
                      : Colors.grey[600],
                ),
                onPressed: () => onViewChanged(BookshelfViewType.list),
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );

  String _getSortTypeName(BookshelfSortType sortType) {
    switch (sortType) {
      case BookshelfSortType.recentRead:
        return '最近阅读';
      case BookshelfSortType.addTime:
        return '添加时间';
      case BookshelfSortType.updateTime:
        return '更新时间';
      case BookshelfSortType.name:
        return '书名';
    }
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              '排序方式',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            
            _buildSortOption(
              context,
              BookshelfSortType.recentRead,
              Icons.access_time,
              '最近阅读',
            ),
            _buildSortOption(
              context,
              BookshelfSortType.addTime,
              Icons.add,
              '添加时间',
            ),
            _buildSortOption(
              context,
              BookshelfSortType.updateTime,
              Icons.update,
              '更新时间',
            ),
            _buildSortOption(
              context,
              BookshelfSortType.name,
              Icons.sort_by_alpha,
              '书名',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    BookshelfSortType type,
    IconData icon,
    String title,
  ) {
    final bool isSelected = sortType == type;
    
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(
              Icons.check,
              color: AppTheme.primaryColor,
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        onSortChanged(type);
      },
    );
  }
}