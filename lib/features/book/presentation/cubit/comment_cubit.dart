// 评论状态管理
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/repositories/book_repository.dart';

// 评论状态
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => <Object?>[];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {

  const CommentLoaded({
    required this.comments,
    this.hasMore = true,
    this.currentPage = 1,
  });
  final List<Comment> comments;
  final bool hasMore;
  final int currentPage;

  @override
  List<Object> get props => <Object>[comments, hasMore, currentPage];
}

class CommentError extends CommentState {

  const CommentError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

class CommentPosting extends CommentState {}

class CommentPosted extends CommentState {

  const CommentPosted(this.comment);
  final Comment comment;

  @override
  List<Object> get props => <Object>[comment];
}

// 评论Cubit
class CommentCubit extends Cubit<CommentState> {

  CommentCubit({
    required this.postCommentUseCase,
    required this.bookRepository,
  }) : super(CommentInitial());
  final PostCommentUseCase postCommentUseCase;
  final BookRepository bookRepository;

  /// 加载评论
  Future<void> loadComments({
    required String targetId,
    required CommentType type,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      emit(CommentLoading());
    }

    final CommentState currentState = state;
    final int page = loadMore && currentState is CommentLoaded 
        ? currentState.currentPage + 1 
        : 1;

    Either result;
    if (type == CommentType.book) {
      result = await bookRepository.getBookComments(
        bookId: targetId,
        page: page,
      );
    } else {
      result = await bookRepository.getChapterComments(
        chapterId: targetId,
        page: page,
      );
    }

    result.fold(
      (error) => emit(CommentError(error.toString())),
      (comments) {
        if (comments is! List<Comment>) {
          emit(const CommentError('评论数据格式错误'));
          return;
        }
        if (loadMore && currentState is CommentLoaded) {
          // 加载更多
          final List<Comment> allComments = <Comment>[...currentState.comments, ...comments];
          emit(CommentLoaded(
            comments: allComments,
            hasMore: comments.length >= 20,
            currentPage: page,
          ));
        } else {
          // 新加载
          emit(CommentLoaded(
            comments: comments,
            hasMore: comments.length >= 20,
            currentPage: page,
          ));
        }
      },
    );
  }

  /// 发表评论
  Future<void> postComment({
    required String targetId,
    required CommentType type,
    required String content,
    String? parentId,
  }) async {
    emit(CommentPosting());

    final Either<AppError, Comment> result = await postCommentUseCase(
      PostCommentParams(
        targetId: targetId,
        type: type,
        content: content,
        parentId: parentId,
      ),
    );

    result.fold(
      (AppError error) => emit(CommentError(error.message)),
      (Comment comment) {
        emit(CommentPosted(comment));
        
        // 重新加载评论列表
        loadComments(targetId: targetId, type: type);
      },
    );
  }

  /// 点赞评论
  Future<void> likeComment(String commentId) async {
    final CommentState currentState = state;
    if (currentState is CommentLoaded) {
      final Either<AppError, bool> result = await bookRepository.likeComment(commentId);
      
      result.fold(
        (AppError error) => emit(CommentError(error.message)),
        (bool success) {
          // 更新评论点赞状态
          final List<Comment> updatedComments = currentState.comments.map((Comment comment) {
            if (comment.id == commentId) {
              return Comment(
                id: comment.id,
                targetId: comment.targetId,
                type: comment.type,
                author: comment.author,
                content: comment.content,
                likeCount: comment.likeCount + 1,
                replyCount: comment.replyCount,
                isLiked: true,
                isPinned: comment.isPinned,
                parentId: comment.parentId,
                createdAt: comment.createdAt,
                updatedAt: comment.updatedAt,
                replies: comment.replies,
              );
            }
            return comment;
          }).toList();

          emit(CommentLoaded(
            comments: updatedComments,
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
          ));
        },
      );
    }
  }

  /// 取消点赞评论
  Future<void> unlikeComment(String commentId) async {
    final CommentState currentState = state;
    if (currentState is CommentLoaded) {
      final Either<AppError, bool> result = await bookRepository.unlikeComment(commentId);
      
      result.fold(
        (AppError error) => emit(CommentError(error.message)),
        (bool success) {
          // 更新评论点赞状态
          final List<Comment> updatedComments = currentState.comments.map((Comment comment) {
            if (comment.id == commentId) {
              return Comment(
                id: comment.id,
                targetId: comment.targetId,
                type: comment.type,
                author: comment.author,
                content: comment.content,
                likeCount: comment.likeCount - 1,
                replyCount: comment.replyCount,
                isPinned: comment.isPinned,
                parentId: comment.parentId,
                createdAt: comment.createdAt,
                updatedAt: comment.updatedAt,
                replies: comment.replies,
              );
            }
            return comment;
          }).toList();

          emit(CommentLoaded(
            comments: updatedComments,
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
          ));
        },
      );
    }
  }

  /// 删除评论
  Future<void> deleteComment(String commentId) async {
    final Either<AppError, bool> result = await bookRepository.deleteComment(commentId);
    
    result.fold(
      (AppError error) => emit(CommentError(error.message)),
      (bool success) {
        final CommentState currentState = state;
        if (currentState is CommentLoaded) {
          // 从列表中移除评论
          final List<Comment> updatedComments = currentState.comments
              .where((Comment comment) => comment.id != commentId)
              .toList();

          emit(CommentLoaded(
            comments: updatedComments,
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
          ));
        }
      },
    );
  }

  /// 重置状态
  void reset() {
    emit(CommentInitial());
  }
}