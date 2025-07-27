// 评论状态管理
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/post_comment_usecase.dart';
import '../../domain/repositories/book_repository.dart';

// 评论状态
abstract class CommentState extends Equatable {
  const CommentState();

  @override
  List<Object?> get props => [];
}

class CommentInitial extends CommentState {}

class CommentLoading extends CommentState {}

class CommentLoaded extends CommentState {
  final List<Comment> comments;
  final bool hasMore;
  final int currentPage;

  const CommentLoaded({
    required this.comments,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object> get props => [comments, hasMore, currentPage];
}

class CommentError extends CommentState {
  final String message;

  const CommentError(this.message);

  @override
  List<Object> get props => [message];
}

class CommentPosting extends CommentState {}

class CommentPosted extends CommentState {
  final Comment comment;

  const CommentPosted(this.comment);

  @override
  List<Object> get props => [comment];
}

// 评论Cubit
class CommentCubit extends Cubit<CommentState> {
  final PostCommentUseCase postCommentUseCase;
  final BookRepository bookRepository;

  CommentCubit({
    required this.postCommentUseCase,
    required this.bookRepository,
  }) : super(CommentInitial());

  /// 加载评论
  Future<void> loadComments({
    required String targetId,
    required CommentType type,
    bool loadMore = false,
  }) async {
    if (!loadMore) {
      emit(CommentLoading());
    }

    final currentState = state;
    final page = loadMore && currentState is CommentLoaded 
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
      (error) => emit(CommentError(error.message)),
      (comments) {
        if (loadMore && currentState is CommentLoaded) {
          // 加载更多
          final allComments = [...currentState.comments, ...comments];
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

    final result = await postCommentUseCase(
      PostCommentParams(
        targetId: targetId,
        type: type,
        content: content,
        parentId: parentId,
      ),
    );

    result.fold(
      (error) => emit(CommentError(error.message)),
      (comment) {
        emit(CommentPosted(comment));
        
        // 重新加载评论列表
        loadComments(targetId: targetId, type: type);
      },
    );
  }

  /// 点赞评论
  Future<void> likeComment(String commentId) async {
    final currentState = state;
    if (currentState is CommentLoaded) {
      final result = await bookRepository.likeComment(commentId);
      
      result.fold(
        (error) => emit(CommentError(error.message)),
        (success) {
          // 更新评论点赞状态
          final updatedComments = currentState.comments.map((comment) {
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
    final currentState = state;
    if (currentState is CommentLoaded) {
      final result = await bookRepository.unlikeComment(commentId);
      
      result.fold(
        (error) => emit(CommentError(error.message)),
        (success) {
          // 更新评论点赞状态
          final updatedComments = currentState.comments.map((comment) {
            if (comment.id == commentId) {
              return Comment(
                id: comment.id,
                targetId: comment.targetId,
                type: comment.type,
                author: comment.author,
                content: comment.content,
                likeCount: comment.likeCount - 1,
                replyCount: comment.replyCount,
                isLiked: false,
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
    final result = await bookRepository.deleteComment(commentId);
    
    result.fold(
      (error) => emit(CommentError(error.message)),
      (success) {
        final currentState = state;
        if (currentState is CommentLoaded) {
          // 从列表中移除评论
          final updatedComments = currentState.comments
              .where((comment) => comment.id != commentId)
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