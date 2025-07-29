import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../widgets/bookshelf_item.dart';

// Events
abstract class BookshelfEvent extends Equatable {
  const BookshelfEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookshelf extends BookshelfEvent {
  const LoadBookshelf();
}

class LoadUserProfile extends BookshelfEvent {
  const LoadUserProfile();
}

class SortBookshelf extends BookshelfEvent {
  final BookshelfSortType sortType;

  const SortBookshelf(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

class ChangeViewType extends BookshelfEvent {
  final BookshelfViewType viewType;

  const ChangeViewType(this.viewType);

  @override
  List<Object?> get props => [viewType];
}

class AddToBookshelf extends BookshelfEvent {
  final String bookId;

  const AddToBookshelf(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class RemoveFromBookshelf extends BookshelfEvent {
  final String bookId;

  const RemoveFromBookshelf(this.bookId);

  @override
  List<Object?> get props => [bookId];
}

class RefreshBookshelf extends BookshelfEvent {
  const RefreshBookshelf();
}

// States
abstract class BookshelfState extends Equatable {
  const BookshelfState();

  @override
  List<Object?> get props => [];
}

class BookshelfInitial extends BookshelfState {}

class BookshelfLoading extends BookshelfState {}

class BookshelfLoaded extends BookshelfState {
  final List<dynamic> books;
  final dynamic user;
  final BookshelfSortType sortType;
  final BookshelfViewType viewType;

  const BookshelfLoaded({
    required this.books,
    this.user,
    this.sortType = BookshelfSortType.recentRead,
    this.viewType = BookshelfViewType.grid,
  });

  @override
  List<Object?> get props => [books, user, sortType, viewType];

  BookshelfLoaded copyWith({
    List<dynamic>? books,
    dynamic user,
    BookshelfSortType? sortType,
    BookshelfViewType? viewType,
  }) {
    return BookshelfLoaded(
      books: books ?? this.books,
      user: user ?? this.user,
      sortType: sortType ?? this.sortType,
      viewType: viewType ?? this.viewType,
    );
  }
}

class BookshelfError extends BookshelfState {
  final String message;

  const BookshelfError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class BookshelfBloc extends Bloc<BookshelfEvent, BookshelfState> {
  BookshelfBloc() : super(BookshelfInitial()) {
    on<LoadBookshelf>(_onLoadBookshelf);
    on<LoadUserProfile>(_onLoadUserProfile);
    on<SortBookshelf>(_onSortBookshelf);
    on<ChangeViewType>(_onChangeViewType);
    on<AddToBookshelf>(_onAddToBookshelf);
    on<RemoveFromBookshelf>(_onRemoveFromBookshelf);
    on<RefreshBookshelf>(_onRefreshBookshelf);
  }

  Future<void> _onLoadBookshelf(
    LoadBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    try {
      emit(BookshelfLoading());
      
      // 暂时使用模拟数据，避免网络请求错误
      await Future.delayed(const Duration(milliseconds: 500));
      final books = <dynamic>[];
      
      emit(BookshelfLoaded(
        books: books,
        sortType: BookshelfSortType.recentRead,
        viewType: BookshelfViewType.grid,
      ));
    } catch (e) {
      emit(BookshelfError('加载书架失败：${e.toString()}'));
    }
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<BookshelfState> emit,
  ) async {
    try {
      if (state is BookshelfLoaded) {
        final currentState = state as BookshelfLoaded;
        final user = null; // 暂时使用模拟数据
        emit(currentState.copyWith(user: user));
      }
    } catch (e) {
      emit(BookshelfError('加载用户信息失败：${e.toString()}'));
    }
  }

  Future<void> _onSortBookshelf(
    SortBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    if (state is BookshelfLoaded) {
      final currentState = state as BookshelfLoaded;
      final sortedBooks = List<dynamic>.from(currentState.books);
      
      emit(currentState.copyWith(
        books: sortedBooks,
        sortType: event.sortType,
      ));
    }
  }

  Future<void> _onChangeViewType(
    ChangeViewType event,
    Emitter<BookshelfState> emit,
  ) async {
    if (state is BookshelfLoaded) {
      final currentState = state as BookshelfLoaded;
      emit(currentState.copyWith(viewType: event.viewType));
    }
  }

  Future<void> _onAddToBookshelf(
    AddToBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    try {
      // 暂时使用模拟实现
      emit(BookshelfError('添加到书架功能暂未实现'));
    } catch (e) {
      emit(BookshelfError('添加到书架失败：${e.toString()}'));
    }
  }

  Future<void> _onRemoveFromBookshelf(
    RemoveFromBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    try {
      if (state is BookshelfLoaded) {
        final currentState = state as BookshelfLoaded;
        final updatedBooks = currentState.books
            .where((book) => book.id != event.bookId)
            .toList();
        
        emit(currentState.copyWith(books: updatedBooks));
      }
    } catch (e) {
      emit(BookshelfError('移除书籍失败：${e.toString()}'));
    }
  }

  Future<void> _onRefreshBookshelf(
    RefreshBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    add(const LoadBookshelf());
  }
}