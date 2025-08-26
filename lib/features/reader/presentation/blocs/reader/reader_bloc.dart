import 'dart:async';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'dart:ui';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:novel_app/core/errors/app_error.dart';
import 'package:novel_app/features/reader/domain/repositories/reader_repository.dart' ;
import '../../../../../shared/models/chapter_model.dart' hide ReadingProgress;
import '../../../../../shared/models/novel_model.dart';
import '../../../domain/entities/reader_config.dart';
import '../../../domain/entities/reading_session.dart';
import '../../../domain/usecases/load_chapter.dart';
import '../../../domain/usecases/manage_reading_progress.dart';
import '../../../domain/usecases/manage_bookmarks.dart';
import '../../../domain/usecases/manage_reader_config.dart';
import '../../../domain/services/page_calculator.dart';

/// 阅读器事件基类
abstract class ReaderEvent extends Equatable {
  const ReaderEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// 初始化阅读器事件
class InitializeReader extends ReaderEvent {

  const InitializeReader({
    required this.novelId,
    this.chapterId,
    this.chapterNumber,
  });
  final String novelId;
  final String? chapterId;
  final int? chapterNumber;

  @override
  List<Object?> get props => <Object?>[novelId, chapterId, chapterNumber];
}

/// 加载章节事件
class LoadChapter extends ReaderEvent {

  const LoadChapter({
    required this.novelId,
    required this.chapterId,
  });
  final String novelId;
  final String chapterId;

  @override
  List<Object> get props => <Object>[novelId, chapterId];
}

/// 翻页事件
class TurnPage extends ReaderEvent { // true为下一页，false为上一页

  const TurnPage(this.forward);
  final bool forward;

  @override
  List<Object> get props => <Object>[forward];
}

/// 跳转到指定页事件
class JumpToPage extends ReaderEvent {

  const JumpToPage(this.page);
  final int page;

  @override
  List<Object> get props => <Object>[page];
}

/// 切换章节事件
class SwitchChapter extends ReaderEvent { // true为下一章，false为上一章

  const SwitchChapter(this.next);
  final bool next;

  @override
  List<Object> get props => <Object>[next];
}

/// 更新阅读器配置事件
class UpdateReaderConfig extends ReaderEvent {

  const UpdateReaderConfig(this.config);
  final ReaderConfig config;

  @override
  List<Object> get props => <Object>[config];
}

/// 添加书签事件
class AddBookmarkEvent extends ReaderEvent {

  const AddBookmarkEvent({this.note});
  final String? note;

  @override
  List<Object?> get props => <Object?>[note];
}

/// 切换界面显示事件
class ToggleUIVisibility extends ReaderEvent {
  const ToggleUIVisibility();
}

/// 切换自动翻页事件
class ToggleAutoPage extends ReaderEvent {
  const ToggleAutoPage();
}

/// 保存阅读进度事件
class SaveProgress extends ReaderEvent {
  const SaveProgress();
}

/// 阅读器状态基类
abstract class ReaderState extends Equatable {
  const ReaderState();

  @override
  List<Object?> get props => <Object?>[];
}

/// 阅读器初始状态
class ReaderInitial extends ReaderState {
  const ReaderInitial();
}

/// 阅读器加载中状态
class ReaderLoading extends ReaderState {
  
  const ReaderLoading({this.message = '正在加载...'});
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

/// 阅读器加载成功状态
class ReaderLoaded extends ReaderState {

  const ReaderLoaded({
    required this.novel,
    required this.session,
    required this.config,
    this.chapterList = const <ChapterSimpleModel>[],
    this.adjacentChapters = const <String, ChapterSimpleModel?>{},
    this.bookmarks = const <BookmarkModel>[],
    this.isUIVisible = false,
    this.error,
  });
  final NovelModel novel;
  final ReadingSession session;
  final ReaderConfig config;
  final List<ChapterSimpleModel> chapterList;
  final Map<String, ChapterSimpleModel?> adjacentChapters;
  final List<BookmarkModel> bookmarks;
  final bool isUIVisible;
  final String? error;

  ReaderLoaded copyWith({
    NovelModel? novel,
    ReadingSession? session,
    ReaderConfig? config,
    List<ChapterSimpleModel>? chapterList,
    Map<String, ChapterSimpleModel?>? adjacentChapters,
    List<BookmarkModel>? bookmarks,
    bool? isUIVisible,
    String? error,
  }) => ReaderLoaded(
      novel: novel ?? this.novel,
      session: session ?? this.session,
      config: config ?? this.config,
      chapterList: chapterList ?? this.chapterList,
      adjacentChapters: adjacentChapters ?? this.adjacentChapters,
      bookmarks: bookmarks ?? this.bookmarks,
      isUIVisible: isUIVisible ?? this.isUIVisible,
      error: error ?? this.error,
    );

  @override
  List<Object?> get props => <Object?>[
        novel,
        session,
        config,
        chapterList,
        adjacentChapters,
        bookmarks,
        isUIVisible,
        error,
      ];
}

/// 阅读器加载失败状态
class ReaderError extends ReaderState {

  const ReaderError(this.message);
  final String message;

  @override
  List<Object> get props => <Object>[message];
}

/// 阅读器BLoC
class ReaderBloc extends Bloc<ReaderEvent, ReaderState> {

  ReaderBloc({
    required this.loadChapter,
    required this.saveReadingProgress,
    required this.getReadingProgress,
    required this.addBookmark,
    required this.getBookmarks,
    required this.saveReaderConfig,
    required this.getReaderConfig,
  }) : super(const ReaderInitial()) {
    on<InitializeReader>(_onInitializeReader);
    on<LoadChapter>(_onLoadChapter);
    on<TurnPage>(_onTurnPage);
    on<JumpToPage>(_onJumpToPage);
    on<SwitchChapter>(_onSwitchChapter);
    on<UpdateReaderConfig>(_onUpdateReaderConfig);
    on<AddBookmarkEvent>(_onAddBookmark);
    on<ToggleUIVisibility>(_onToggleUIVisibility);
    on<ToggleAutoPage>(_onToggleAutoPage);
    on<SaveProgress>(_onSaveProgress);
  }
  final LoadChapter loadChapter;
  final SaveReadingProgress saveReadingProgress;
  final GetReadingProgress getReadingProgress;
  final AddBookmark addBookmark;
  final GetBookmarks getBookmarks;
  final SaveReaderConfig saveReaderConfig;
  final GetReaderConfig getReaderConfig;

  Timer? _autoPageTimer;
  Timer? _progressSaveTimer;

  @override
  Future<void> close() {
    _autoPageTimer?.cancel();
    _progressSaveTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeReader(
    InitializeReader event,
    Emitter<ReaderState> emit,
  ) async {
    emit(const ReaderLoading(message: '正在初始化阅读器...'));

    try {
      // 获取阅读进度
      final Either<AppError, ReadingProgress?> progressResult = await getReadingProgress(event.novelId);
      final ReadingProgress? progress = progressResult.fold(
        (AppError failure) => null,
        (ReadingProgress? progress) => progress,
      );

      // 确定要加载的章节ID
      String chapterIdToLoad;
      if (event.chapterId != null) {
        chapterIdToLoad = event.chapterId!;
      } else if (progress != null) {
        chapterIdToLoad = progress.chapterId;
      } else {
        // 默认加载第一章（这里需要从章节列表获取）
        emit(const ReaderError('无法确定要加载的章节'));
        return;
      }

      // 加载章节内容
      add(LoadChapter(novelId: event.novelId, chapterId: chapterIdToLoad));
    } catch (e) {
      emit(ReaderError('初始化失败: ${e.toString()}'));
    }
  }

  Future<void> _onLoadChapter(
    LoadChapter event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) {
      emit(const ReaderLoading(message: '正在加载章节...'));
    }

    try {
      // 加载章节内容
      final chapterResult = await loadChapter.call(LoadChapterParams(
        novelId: event.novelId,
        chapterId: event.chapterId,
      ) as int);

      final chapter = chapterResult.fold(
        (failure) => throw Exception(failure.message),
        (chapter) => chapter,
      );

      // 获取配置
      final ReaderConfig config = currentState is ReaderLoaded 
          ? currentState.config 
          : const ReaderConfig();

      // 计算页面分页
      // 这里需要屏幕尺寸信息，实际实现时可能需要从UI层传入
      const Size screenSize = Size(375, 667); // 示例尺寸
      final List<String> pages = PageCalculator.calculatePages(
        content: chapter.content ?? '',
        config: config,
        screenSize: screenSize,
      );

      // 创建阅读会话
      final ReadingSession session = ReadingSession(
        id: '${event.novelId}_${event.chapterId}',
        userId: 'current_user',
        novelId: event.novelId,
        currentChapter: chapter,
        pages: pages,
        startTime: DateTime.now(),
      );

      // 获取书签
      final Either<AppError, List<BookmarkModel>> bookmarksResult = await getBookmarks(GetBookmarksParams(
        novelId: event.novelId,
        chapterId: event.chapterId,
      ));
      final List<BookmarkModel> bookmarks = bookmarksResult.fold(
        (AppError failure) => <BookmarkModel>[],
        (List<BookmarkModel> bookmarks) => bookmarks,
      );

      if (currentState is ReaderLoaded) {
        emit(currentState.copyWith(
          session: session,
          bookmarks: bookmarks,
        ));
      } else {
        // 这里需要获取小说信息，简化处理
        emit(ReaderLoaded(
          novel: NovelModel(
            id: event.novelId,
            title: '小说标题',
            author: const NovelAuthor(id: '1', name: '作者'),
            publishTime: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          session: session,
          config: config,
          bookmarks: bookmarks,
        ));
      }

      // 启动定时保存进度
      _startProgressSaveTimer();
    } catch (e) {
      emit(ReaderError('加载章节失败: ${e.toString()}'));
    }
  }

  Future<void> _onTurnPage(
    TurnPage event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    final ReadingSession session = currentState.session;
    int newPage;

    if (event.forward) {
      if (session.hasNextPage) {
        newPage = session.currentPage + 1;
      } else {
        // 到达章节末尾，尝试加载下一章
        add(const SwitchChapter(true));
        return;
      }
    } else {
      if (session.hasPreviousPage) {
        newPage = session.currentPage - 1;
      } else {
        // 到达章节开头，尝试加载上一章
        add(const SwitchChapter(false));
        return;
      }
    }

    final ReadingSession updatedSession = session.copyWith(currentPage: newPage);
    emit(currentState.copyWith(session: updatedSession));
  }

  Future<void> _onJumpToPage(
    JumpToPage event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    final ReadingSession session = currentState.session;
    if (event.page >= 0 && event.page < session.pages.length) {
      final ReadingSession updatedSession = session.copyWith(currentPage: event.page);
      emit(currentState.copyWith(session: updatedSession));
    }
  }

  Future<void> _onSwitchChapter(
    SwitchChapter event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    // 这里需要实现章节切换逻辑
    // 需要从adjacent chapters或章节列表中获取目标章节
    emit(currentState.copyWith(
      error: event.next ? '已经是最后一章' : '已经是第一章',
    ));
  }

  Future<void> _onUpdateReaderConfig(
    UpdateReaderConfig event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    // 保存配置
    await saveReaderConfig(event.config);

    // 重新计算页面分页
    const Size screenSize = Size(375, 667);
    final List<String> pages = PageCalculator.calculatePages(
      content: currentState.session.currentChapter.content ?? '',
      config: event.config,
      screenSize: screenSize,
    );

    // 重新计算当前页码
    final int currentPosition = PageCalculator.calculatePositionFromPage(
      pages: currentState.session.pages,
      page: currentState.session.currentPage,
    );
    final int newPage = PageCalculator.calculatePageFromPosition(
      pages: pages,
      position: currentPosition,
    );

    final ReadingSession updatedSession = currentState.session.copyWith(
      pages: pages,
      currentPage: newPage,
    );

    emit(currentState.copyWith(
      config: event.config,
      session: updatedSession,
    ));
  }

  Future<void> _onAddBookmark(
    AddBookmarkEvent event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    try {
      final ReadingSession session = currentState.session;
      final int position = PageCalculator.calculatePositionFromPage(
        pages: session.pages,
        page: session.currentPage,
      );

      final Either<AppError, BookmarkModel> bookmarkResult = await addBookmark(AddBookmarkParams(
        novelId: session.novelId,
        chapterId: session.currentChapter.id,
        position: position,
        note: event.note,
        content: session.currentPageContent.substring(0, 50), // 获取前50个字符作为内容
      ));

      bookmarkResult.fold(
        (AppError failure) {
          emit(currentState.copyWith(error: failure.message));
        },
        (BookmarkModel bookmark) {
          final List<BookmarkModel> updatedBookmarks = <BookmarkModel>[...currentState.bookmarks, bookmark];
          emit(currentState.copyWith(bookmarks: updatedBookmarks));
        },
      );
    } catch (e) {
      emit(currentState.copyWith(error: '添加书签失败'));
    }
  }

  Future<void> _onToggleUIVisibility(
    ToggleUIVisibility event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    emit(currentState.copyWith(isUIVisible: !currentState.isUIVisible));
  }

  Future<void> _onToggleAutoPage(
    ToggleAutoPage event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    final ReadingSession session = currentState.session;
    if (session.isAutoPage) {
      _autoPageTimer?.cancel();
      emit(currentState.copyWith(
        session: session.copyWith(isAutoPage: false),
      ));
    } else {
      _startAutoPageTimer();
      emit(currentState.copyWith(
        session: session.copyWith(isAutoPage: true),
      ));
    }
  }

  Future<void> _onSaveProgress(
    SaveProgress event,
    Emitter<ReaderState> emit,
  ) async {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    try {
      final ReadingSession session = currentState.session;
      final int position = PageCalculator.calculatePositionFromPage(
        pages: session.pages,
        page: session.currentPage,
      );

      await saveReadingProgress(SaveProgressParams(
        novelId: session.novelId,
        chapterId: session.currentChapter.id,
        position: position,
        progress: session.progressPercent,
      ));
    } catch (e) {
      // 保存进度失败不影响阅读
    }
  }

  void _startAutoPageTimer() {
    final ReaderState currentState = state;
    if (currentState is! ReaderLoaded) return;

    _autoPageTimer?.cancel();
    _autoPageTimer = Timer.periodic(
      Duration(seconds: currentState.config.autoPageInterval),
      (Timer timer) {
        add(const TurnPage(true));
      },
    );
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(
      const Duration(seconds: 10), // 每10秒保存一次进度
      (Timer timer) {
        add(const SaveProgress());
      },
    );
  }
}