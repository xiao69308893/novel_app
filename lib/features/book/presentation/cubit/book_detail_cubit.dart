// 小说详情状态管理
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../shared/models/chapter_model.dart';
import '../../domain/entities/book_detail.dart';
import '../../domain/usecases/get_book_detail_usecase.dart';
import '../../domain/usecases/manage_favorite_usecase.dart';
import '../../domain/usecases/manage_reading_progress_usecase.dart';
import '../../domain/repositories/book_repository.dart';

// 小说详情状态
abstract class BookDetailState extends Equatable {
  const BookDetailState();

  @override
  List<Object?> get props => <Object?>[];
}

class BookDetailInitial extends BookDetailState {}

class BookDetailLoading extends BookDetailState {}

class BookDetailLoaded extends BookDetailState {

  const BookDetailLoaded({
    required this.bookDetail,
    this.chapters = const <ChapterSimpleModel>[],
    this.similarBooks = const <NovelSimpleModel>[],
    this.authorOtherBooks = const <NovelSimpleModel>[],
  });
  final BookDetail bookDetail;
  final List<ChapterSimpleModel> chapters;
  final List<NovelSimpleModel> similarBooks;
  final List<NovelSimpleModel> authorOtherBooks;

  @override
  List<Object> get props => <Object>[bookDetail, chapters, similarBooks, authorOtherBooks];
}

class BookDetailError extends BookDetailState {

  const BookDetailError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

// 小说详情Cubit
class BookDetailCubit extends Cubit<BookDetailState> {

  BookDetailCubit({
    required this.getBookDetailUseCase,
    required this.manageFavoriteUseCase,
    required this.updateReadingProgressUseCase,
    required this.bookRepository,
  }) : super(BookDetailInitial());
  final GetBookDetailUseCase getBookDetailUseCase;
  final ManageFavoriteUseCase manageFavoriteUseCase;
  final UpdateReadingProgressUseCase updateReadingProgressUseCase;
  final BookRepository bookRepository;

  /// 加载小说详情
  Future<void> loadBookDetail(String bookId) async {
    emit(BookDetailLoading());

    final Either<AppError, BookDetail> result = await getBookDetailUseCase(
      GetBookDetailParams(bookId: bookId),
    );

    result.fold(
      (AppError error) => emit(BookDetailError(error.message)),
      (BookDetail bookDetail) async {
        // 并行加载其他数据
        final List<Future<Either<AppError, List<Equatable>>>> futures = <Future<Either<AppError, List<Equatable>>>>[
          bookRepository.getChapterList(bookId: bookId, limit: 20),
          bookRepository.getSimilarBooks(bookId: bookId),
          bookRepository.getAuthorOtherBooks(
            authorId: bookDetail.novel.author.id,
            excludeBookId: bookId,
          ),
        ];

        final List<Either<AppError, List<Equatable>>> results = await Future.wait(futures);

        final List<ChapterSimpleModel> chapters = results[0].fold(
          (AppError error) => <ChapterSimpleModel>[],
          (List<Equatable> chapters) => chapters as List<ChapterSimpleModel>,
        );

        final List<NovelSimpleModel> similarBooks = results[1].fold(
          (AppError error) => <NovelSimpleModel>[],
          (List<Equatable> books) => books as List<NovelSimpleModel>,
        );

        final List<NovelSimpleModel> authorOtherBooks = results[2].fold(
          (AppError error) => <NovelSimpleModel>[],
          (List<Equatable> books) => books as List<NovelSimpleModel>,
        );

        emit(BookDetailLoaded(
          bookDetail: bookDetail,
          chapters: chapters,
          similarBooks: similarBooks,
          authorOtherBooks: authorOtherBooks,
        ));
      },
    );
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      final bool newFavoriteStatus = !bookDetail.isFavorited;

      final Either<AppError, bool> result = await manageFavoriteUseCase(
        ManageFavoriteParams(
          bookId: bookDetail.novel.id,
          isFavorite: newFavoriteStatus,
        ),
      );

      result.fold(
        (AppError error) {
          // 显示错误消息，但不改变状态
        },
        (bool success) {
          // 更新状态
          final BookDetail updatedBookDetail = BookDetail(
            novel: bookDetail.novel,
            chapters: bookDetail.chapters,
            readingProgress: bookDetail.readingProgress,
            isFavorited: newFavoriteStatus,
            isDownloaded: bookDetail.isDownloaded,
            stats: bookDetail.stats,
          );

          emit(BookDetailLoaded(
            bookDetail: updatedBookDetail,
            chapters: currentState.chapters,
            similarBooks: currentState.similarBooks,
            authorOtherBooks: currentState.authorOtherBooks,
          ));
        },
      );
    }
  }

  /// 开始阅读
  Future<void> startReading(String chapterId) async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      
      // 更新阅读进度
      await updateReadingProgressUseCase(
        UpdateReadingProgressParams(
          bookId: bookDetail.novel.id,
          chapterId: chapterId,
          position: 0,
          progress: 0.0,
        ),
      );
      
      // 跳转到阅读页面（在UI层处理）
    }
  }

  /// 下载小说
  Future<void> downloadBook() async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      
      final Either<AppError, bool> result = await bookRepository.downloadBook(bookDetail.novel.id);
      
      result.fold(
        (AppError error) {
          // 显示错误消息
        },
        (bool success) {
          // 更新下载状态
          final BookDetail updatedBookDetail = BookDetail(
            novel: bookDetail.novel,
            chapters: bookDetail.chapters,
            readingProgress: bookDetail.readingProgress,
            isFavorited: bookDetail.isFavorited,
            isDownloaded: true,
            stats: bookDetail.stats,
          );

          emit(BookDetailLoaded(
            bookDetail: updatedBookDetail,
            chapters: currentState.chapters,
            similarBooks: currentState.similarBooks,
            authorOtherBooks: currentState.authorOtherBooks,
          ));
        },
      );
    }
  }

  /// 分享小说
  Future<void> shareBook(String platform) async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      
      await bookRepository.shareBook(
        bookId: bookDetail.novel.id,
        platform: platform,
      );
    }
  }

  /// 评分小说
  Future<void> rateBook(int rating, String? review) async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      
      await bookRepository.rateBook(
        bookId: bookDetail.novel.id,
        rating: rating,
        review: review,
      );
    }
  }

  /// 举报小说
  Future<void> reportBook(String reason, String? description) async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      final BookDetail bookDetail = currentState.bookDetail;
      
      await bookRepository.reportContent(
        targetId: bookDetail.novel.id,
        type: 'book',
        reason: reason,
        description: description,
      );
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    final BookDetailState currentState = state;
    if (currentState is BookDetailLoaded) {
      await loadBookDetail(currentState.bookDetail.novel.id);
    }
  }
}