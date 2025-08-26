import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../widgets/bookshelf_item.dart';

// Events
abstract class BookshelfEvent extends Equatable {
  const BookshelfEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadBookshelf extends BookshelfEvent {
  const LoadBookshelf();
}

class LoadUserProfile extends BookshelfEvent {
  const LoadUserProfile();
}

class SortBookshelf extends BookshelfEvent {

  const SortBookshelf(this.sortType);
  final BookshelfSortType sortType;

  @override
  List<Object?> get props => <Object?>[sortType];
}

class ChangeViewType extends BookshelfEvent {

  const ChangeViewType(this.viewType);
  final BookshelfViewType viewType;

  @override
  List<Object?> get props => <Object?>[viewType];
}

  class AddToBookshelf extends BookshelfEvent {

  const AddToBookshelf(this.bookId);
  final String bookId;

  @override
  List<Object?> get props => <Object?>[bookId];
}

class RemoveFromBookshelf extends BookshelfEvent {

  const RemoveFromBookshelf(this.bookId);
  final String bookId;

  @override
  List<Object?> get props => <Object?>[bookId];
}

class RefreshBookshelf extends BookshelfEvent {
  const RefreshBookshelf();
}

// States
abstract class BookshelfState extends Equatable {
  const BookshelfState();

  @override
  List<Object?> get props => <Object?>[];
}

class BookshelfInitial extends BookshelfState {}

class BookshelfLoading extends BookshelfState {}

class BookshelfLoaded extends BookshelfState {

  const BookshelfLoaded({
    required this.books,
    this.user,
    this.sortType = BookshelfSortType.recentRead,
    this.viewType = BookshelfViewType.grid,
  });
  final List<dynamic> books;
  final dynamic user;
  final BookshelfSortType sortType;
  final BookshelfViewType viewType;

  @override
  List<Object?> get props => <Object?>[books, user, sortType, viewType];

  BookshelfLoaded copyWith({
    List<dynamic>? books,
    dynamic user,
    BookshelfSortType? sortType,
    BookshelfViewType? viewType,
  }) => BookshelfLoaded(
      books: books ?? this.books,
      user: user ?? this.user,
      sortType: sortType ?? this.sortType,
      viewType: viewType ?? this.viewType,
    );
}

class BookshelfError extends BookshelfState {

  const BookshelfError(this.message);
  final String message;

  @override
  List<Object?> get props => <Object?>[message];
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
      final List books = <dynamic>[];
      
      emit(BookshelfLoaded(
        books: books,
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
        final BookshelfLoaded currentState = state as BookshelfLoaded;
// 暂时使用模拟数据
        emit(currentState.copyWith());
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
      final BookshelfLoaded currentState = state as BookshelfLoaded;
      final List sortedBooks = List<dynamic>.from(currentState.books);
      
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
      final BookshelfLoaded currentState = state as BookshelfLoaded;
      emit(currentState.copyWith(viewType: event.viewType));
    }
  }

  Future<void> _onAddToBookshelf(
    AddToBookshelf event,
    Emitter<BookshelfState> emit,
  ) async {
    try {
      // 暂时使用模拟实现
      emit(const BookshelfError('添加到书架功能暂未实现'));
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
        final BookshelfLoaded currentState = state as BookshelfLoaded;
        final List updatedBooks = currentState.books
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