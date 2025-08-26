// 发表评论用例
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/app_error.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/book_repository.dart';

class PostCommentUseCase implements UseCase<Comment, PostCommentParams> {

  PostCommentUseCase(this.repository);
  final BookRepository repository;

  @override
  Future<Either<AppError, Comment>> call(PostCommentParams params) async {
    // 参数验证
    if (params.targetId.trim().isEmpty) {
      return Left(DataError.validation(message: '目标ID不能为空'));
    }
    if (params.content.trim().isEmpty) {
      return Left(DataError.validation(message: '评论内容不能为空'));
    }
    if (params.content.length > 500) {
      return Left(DataError.validation(message: '评论内容不能超过500字'));
    }

    return repository.postComment(
      targetId: params.targetId,
      type: params.type,
      content: params.content.trim(),
      parentId: params.parentId,
    );
  }
}

class PostCommentParams extends Equatable {

  const PostCommentParams({
    required this.targetId,
    required this.type,
    required this.content,
    this.parentId,
  });
  final String targetId;
  final CommentType type;
  final String content;
  final String? parentId;

  @override
  List<Object?> get props => <Object?>[targetId, type, content, parentId];
}
