// 评论实体
import 'package:equatable/equatable.dart';
import '../../../shared/models/user_model.dart';

enum CommentType {
  book(0, '书评'),
  chapter(1, '章节评论'),
  reply(2, '回复');

  const CommentType(this.value, this.displayName);
  
  final int value;
  final String displayName;

  static CommentType fromValue(int? value) {
    return CommentType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => CommentType.book,
    );
  }
}

class Comment extends Equatable {
  final String id;
  final String targetId; // 小说ID或章节ID
  final CommentType type;
  final UserModel author;
  final String content;
  final int likeCount;
  final int replyCount;
  final bool isLiked;
  final bool isPinned;
  final String? parentId; // 父评论ID（用于回复）
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> replies;

  const Comment({
    required this.id,
    required this.targetId,
    this.type = CommentType.book,
    required this.author,
    required this.content,
    this.likeCount = 0,
    this.replyCount = 0,
    this.isLiked = false,
    this.isPinned = false,
    this.parentId,
    required this.createdAt,
    required this.updatedAt,
    this.replies = const [],
  });

  /// 是否为回复
  bool get isReply => parentId != null;

  /// 发布时间显示
  String get timeDisplay {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    
    if (diff.inMinutes < 1) {
      return '刚刚';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}分钟前';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}小时前';
    } else if (diff.inDays < 30) {
      return '${diff.inDays}天前';
    } else {
      return '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [
    id, targetId, type, author, content, likeCount, 
    replyCount, isLiked, isPinned, parentId, 
    createdAt, updatedAt, replies
  ];
}