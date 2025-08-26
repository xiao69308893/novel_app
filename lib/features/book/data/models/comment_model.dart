// 评论数据模型
import '../../../../shared/models/user_model.dart';
import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.targetId,
    required super.author, required super.content, required super.createdAt, required super.updatedAt, super.type,
    super.likeCount,
    super.replyCount,
    super.isLiked,
    super.isPinned,
    super.parentId,
    super.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) => CommentModel(
      id: json['id'] as String,
      targetId: json['target_id'] as String,
      type: CommentType.fromValue(json['type'] as int?),
      author: UserModel.fromJson(json['author'] as Map<String, dynamic>),
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      replyCount: json['reply_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      parentId: json['parent_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      replies: (json['replies'] as List?)
          ?.map((reply) => CommentModel.fromJson(reply as Map<String, dynamic>))
          .cast<Comment>()
          .toList() ?? <Comment>[],
    );

  Map<String, dynamic> toJson() => <String, dynamic>{
      'id': id,
      'target_id': targetId,
      'type': type.value,
      'author': author.toJson(),
      'content': content,
      'like_count': likeCount,
      'reply_count': replyCount,
      'is_liked': isLiked,
      'is_pinned': isPinned,
      'parent_id': parentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'replies': replies.map((Comment reply) {
        if (reply is CommentModel) {
          return reply.toJson();
        } else {
          return CommentModel(
            id: reply.id,
            targetId: reply.targetId,
            type: reply.type,
            author: reply.author,
            content: reply.content,
            likeCount: reply.likeCount,
            replyCount: reply.replyCount,
            isLiked: reply.isLiked,
            isPinned: reply.isPinned,
            parentId: reply.parentId,
            createdAt: reply.createdAt,
            updatedAt: reply.updatedAt,
            replies: reply.replies,
          ).toJson();
        }
      }).toList(),
    };

  Comment toEntity() => Comment(
      id: id,
      targetId: targetId,
      type: type,
      author: author,
      content: content,
      likeCount: likeCount,
      replyCount: replyCount,
      isLiked: isLiked,
      isPinned: isPinned,
      parentId: parentId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      replies: replies,
    );
}