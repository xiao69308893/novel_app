import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../repositories/reader_repository.dart';

/// 保存阅读进度用例
class SaveReadingProgress extends UseCase<void, SaveProgressParams> {
  final ReaderRepository repository;

  const SaveReadingProgress(this.repository);

  @override
  ResultFuture<void> call(SaveProgressParams params) async {
    return await repository.saveReadingProgress(
      novelId: params.novelId,
      chapterId: params.chapterId,
      position: params.position,
      progress: params.progress,
    );
  }
}

/// 保存进度参数
class SaveProgressParams extends Equatable {
  final String novelId;
  final String chapterId;
  final int position;
  final double progress;

  const SaveProgressParams({
    required this.novelId,
    required this.chapterId,
    required this.position,
    required this.progress,
  });

  @override
  List<Object> get props => [novelId, chapterId, position, progress];
}

/// 获取阅读进度用例
class GetReadingProgress extends UseCase<ReadingProgress?, String> {
  final ReaderRepository repository;

  const GetReadingProgress(this.repository);

  @override
  ResultFuture<ReadingProgress?> call(String novelId) async {
    return await repository.getReadingProgress(novelId: novelId);
  }
}

/// 更新阅读时长用例
class UpdateReadingTime extends UseCase<void, UpdateReadingTimeParams> {
  final ReaderRepository repository;

  const UpdateReadingTime(this.repository);

  @override
  ResultFuture<void> call(UpdateReadingTimeParams params) async {
    return await repository.updateReadingTime(
      novelId: params.novelId,
      minutes: params.minutes,
    );
  }
}

/// 更新阅读时长参数
class UpdateReadingTimeParams extends Equatable {
  final String novelId;
  final int minutes;

  const UpdateReadingTimeParams({
    required this.novelId,
    required this.minutes,
  });

  @override
  List<Object> get props => [novelId, minutes];
}

/// 获取阅读统计用例
class GetReadingStats extends UseCase<ReadingStats, NoParams> {
  final ReaderRepository repository;

  const GetReadingStats(this.repository);

  @override
  ResultFuture<ReadingStats> call(NoParams params) async {
    return await repository.getReadingStats();
  }
}

/// 缓存章节用例
class CacheChapter extends UseCase<void, CacheChapterParams> {
  final ReaderRepository repository;

  const CacheChapter(this.repository);

  @override
  ResultFuture<void> call(CacheChapterParams params) async {
    return await repository.cacheChapter(
      novelId: params.novelId,
      chapterId: params.chapterId,
    );
  }
}

/// 缓存章节参数
class CacheChapterParams extends Equatable {
  final String novelId;
  final String chapterId;

  const CacheChapterParams({
    required this.novelId,
    required this.chapterId,
  });

  @override
  List<Object> get props => [novelId, chapterId];
}

/// 获取缓存章节列表用例
class GetCachedChapterIds extends UseCase<List<String>, String> {
  final ReaderRepository repository;

  const GetCachedChapterIds(this.repository);

  @override
  ResultFuture<List<String>> call(String novelId) async {
    return await repository.getCachedChapterIds(novelId: novelId);
  }
}

/// 清理缓存用例
class ClearCache extends UseCase<void, ClearCacheParams> {
  final ReaderRepository repository;

  const ClearCache(this.repository);

  @override
  ResultFuture<void> call(ClearCacheParams params) async {
    return await repository.clearCache(novelId: params.novelId);
  }
}

/// 清理缓存参数
class ClearCacheParams extends Equatable {
  final String? novelId;

  const ClearCacheParams({this.novelId});

  @override
  List<Object?> get props => [novelId];
}