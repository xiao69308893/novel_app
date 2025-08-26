import 'package:flutter/material.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../../../app/themes/app_theme.dart';

/// 书签对话框组件
class BookmarkDialog extends StatefulWidget {

  const BookmarkDialog({
    required this.novelTitle, required this.chapterTitle, required this.content, super.key,
    this.initialNote,
    this.onSave,
  });
  final String novelTitle;
  final String chapterTitle;
  final String content;
  final String? initialNote;
  final ValueChanged<String?>? onSave;

  @override
  State<BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<BookmarkDialog> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      title: const Text('添加书签'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // 位置信息
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    widget.novelTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.chapterTitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSmall),
                  Text(
                    widget.content,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingRegular),
            
            // 备注输入
            const Text(
              '备注（可选）',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSmall),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: '为这个书签添加备注...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onSave?.call(_noteController.text.trim().isEmpty 
                ? null 
                : _noteController.text.trim());
            Navigator.pop(context);
          },
          child: const Text('保存'),
        ),
      ],
    );
}

/// 书签列表对话框
class BookmarkListDialog extends StatelessWidget {

  const BookmarkListDialog({
    required this.bookmarks, super.key,
    this.onBookmarkTap,
    this.onBookmarkDelete,
  });
  final List<BookmarkModel> bookmarks;
  final ValueChanged<BookmarkModel>? onBookmarkTap;
  final ValueChanged<BookmarkModel>? onBookmarkDelete;

  @override
  Widget build(BuildContext context) => Dialog(
      child: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: <Widget>[
            // 头部
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: <Widget>[
                  const Text(
                    '书签列表',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // 书签列表
            Expanded(
              child: bookmarks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.bookmark_border,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: AppTheme.spacingRegular),
                          Text(
                            '还没有添加任何书签',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: bookmarks.length,
                      itemBuilder: (BuildContext context, int index) {
                        final BookmarkModel bookmark = bookmarks[index];
                        return _buildBookmarkItem(context, bookmark);
                      },
                    ),
            ),
          ],
        ),
      ),
    );

  Widget _buildBookmarkItem(BuildContext context, BookmarkModel bookmark) => Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingRegular,
        vertical: AppTheme.spacingSmall,
      ),
      child: ListTile(
        title: Text(
          bookmark.locationText,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (bookmark.content != null)
              Text(
                bookmark.content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (bookmark.note != null) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                '备注：${bookmark.note}',
                style: TextStyle(
                  color: Colors.blue[600],
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              bookmark.createdTimeText,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (String value) {
            switch (value) {
              case 'jump':
                onBookmarkTap?.call(bookmark);
                Navigator.pop(context);
                break;
              case 'delete':
                _showDeleteDialog(context, bookmark);
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem(
              value: 'jump',
              child: Text('跳转到此处'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('删除书签'),
            ),
          ],
        ),
        onTap: () {
          onBookmarkTap?.call(bookmark);
          Navigator.pop(context);
        },
      ),
    );

  void _showDeleteDialog(BuildContext context, BookmarkModel bookmark) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('删除书签'),
        content: const Text('确定要删除这个书签吗？'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onBookmarkDelete?.call(bookmark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}