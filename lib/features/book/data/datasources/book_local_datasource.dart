// 小说本地数据源
import 'dart:convert';
import '../../../../core/utils/preferences_helper.dart';
import '../../../shared/models/chapter_model.dart';
import '../models/book_detail_model.dart';

abstract class BookLocalDataSource {
  Future<BookDetailModel?> getBookDetail(String bookId);
  Future<void> saveBookDetail(BookDetailModel bookDetail);
  Future<List<ChapterSimpleModel>?> getChapterList(String bookId);
  Future<void> saveChapterList(String bookId, List<ChapterSimpleModel> chapters);
  Future<ChapterModel?> getChapterDetail(String chapterId);
  Future<void> saveChapterDetail(ChapterModel chapter);
  Future<ReadingProgress?> getReadingProgress(String bookId);
  Future<void> saveReadingProgress(ReadingProgress progress);
  Future<List<String>?> getFavoriteBooks();
  Future<void> saveFavoriteBooks(List<String> bookIds);
  Future<void> addFavoriteBook(String bookId);
  Future<void> removeFavoriteBook(String bookId);
  Future<List<String>?> getDownloadedBooks();
  Future<void> saveDownloadedBooks(List<String> bookIds);
  Future<void> addDownloadedBook(String bookId);
  Future<void> removeDownloadedBook(String bookId);
  Future<void> clearCache();
}

class BookLocalDataSourceImpl implements BookLocalDataSource {
  static const String _bookDetailPrefix = 'book_detail_';
  static const String _chapterListPrefix = 'chapter_list_';
  static const String _chapterDetailPrefix = 'chapter_detail_';
  static const String _readingProgressPrefix = 'reading_progress_';
  static const String _favoriteBooksKey = 'favorite_books';
  static const String _downloadedBooksKey = 'downloaded_books';

  @override
  Future<BookDetailModel?> getBookDetail(String bookId) async {
    try {
      final detailJson = await PreferencesHelper.getString('$_bookDetailPrefix$bookId');
      if (detailJson != null) {
        final detailMap = json.decode(detailJson) as Map<String, dynamic>;
        return BookDetailModel.fromJson(detailMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveBookDetail(BookDetailModel bookDetail) async {
    final detailJson = json.encode(bookDetail.toJson());
    await PreferencesHelper.setString('$_bookDetailPrefix${bookDetail.novel.id}', detailJson);
  }

  @override
  Future<List<ChapterSimpleModel>?> getChapterList(String bookId) async {
    try {
      final chaptersJson = await PreferencesHelper.getString('$_chapterListPrefix$bookId');
      if (chaptersJson != null) {
        final List<dynamic> chaptersList = json.decode(chaptersJson);
        return chaptersList
            .map((chapterJson) => ChapterSimpleModel.fromJson(chapterJson))
            .toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveChapterList(String bookId, List<ChapterSimpleModel> chapters) async {
    final chaptersJson = json.encode(
      chapters.map((chapter) => chapter.toJson()).toList(),
    );
    await PreferencesHelper.setString('$_chapterListPrefix$bookId', chaptersJson);
  }

  @override
  Future<ChapterModel?> getChapterDetail(String chapterId) async {
    try {
      final chapterJson = await PreferencesHelper.getString('$_chapterDetailPrefix$chapterId');
      if (chapterJson != null) {
        final chapterMap = json.decode(chapterJson) as Map<String, dynamic>;
        return ChapterModel.fromJson(chapterMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveChapterDetail(ChapterModel chapter) async {
    final chapterJson = json.encode(chapter.toJson());
    await PreferencesHelper.setString('$_chapterDetailPrefix${chapter.id}', chapterJson);
  }

  @override
  Future<ReadingProgress?> getReadingProgress(String bookId) async {
    try {
      final progressJson = await PreferencesHelper.getString('$_readingProgressPrefix$bookId');
      if (progressJson != null) {
        final progressMap = json.decode(progressJson) as Map<String, dynamic>;
        return ReadingProgress.fromJson(progressMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveReadingProgress(ReadingProgress progress) async {
    final progressJson = json.encode(progress.toJson());
    await PreferencesHelper.setString('$_readingProgressPrefix${progress.novelId}', progressJson);
  }

  @override
  Future<List<String>?> getFavoriteBooks() async {
    try {
      final favoritesJson = await PreferencesHelper.getString(_favoriteBooksKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = json.decode(favoritesJson);
        return favoritesList.cast<String>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveFavoriteBooks(List<String> bookIds) async {
    final favoritesJson = json.encode(bookIds);
    await PreferencesHelper.setString(_favoriteBooksKey, favoritesJson);
  }

  @override
  Future<void> addFavoriteBook(String bookId) async {
    final favorites = await getFavoriteBooks() ?? [];
    if (!favorites.contains(bookId)) {
      favorites.add(bookId);
      await saveFavoriteBooks(favorites);
    }
  }

  @override
  Future<void> removeFavoriteBook(String bookId) async {
    final favorites = await getFavoriteBooks() ?? [];
    favorites.remove(bookId);
    await saveFavoriteBooks(favorites);
  }

  @override
  Future<List<String>?> getDownloadedBooks() async {
    try {
      final downloadedJson = await PreferencesHelper.getString(_downloadedBooksKey);
      if (downloadedJson != null) {
        final List<dynamic> downloadedList = json.decode(downloadedJson);
        return downloadedList.cast<String>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveDownloadedBooks(List<String> bookIds) async {
    final downloadedJson = json.encode(bookIds);
    await PreferencesHelper.setString(_downloadedBooksKey, downloadedJson);
  }

  @override
  Future<void> addDownloadedBook(String bookId) async {
    final downloaded = await getDownloadedBooks() ?? [];
    if (!downloaded.contains(bookId)) {
      downloaded.add(bookId);
      await saveDownloadedBooks(downloaded);
    }
  }

  @override
  Future<void> removeDownloadedBook(String bookId) async {
    final downloaded = await getDownloadedBooks() ?? [];
    downloaded.remove(bookId);
    await saveDownloadedBooks(downloaded);
  }

  @override
  Future<void> clearCache() async {
    // 这里可以实现清除所有缓存的逻辑
    // 由于键名是动态的，需要获取所有键然后过滤删除
    // 简化实现，实际项目中可能需要更复杂的逻辑
  }
}