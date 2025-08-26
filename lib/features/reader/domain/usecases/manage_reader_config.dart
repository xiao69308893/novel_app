import 'package:dartz/dartz.dart';

import 'package:novel_app/core/errors/app_error.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/reader_config.dart';
import '../repositories/reader_repository.dart';

/// 保存阅读器配置用例
class SaveReaderConfig extends UseCase<void, ReaderConfig> {

  SaveReaderConfig(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(ReaderConfig config) async => repository.saveReaderConfig(config: config);
}

/// 获取阅读器配置用例
class GetReaderConfig extends UseCase<ReaderConfig, NoParams> {

  GetReaderConfig(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<ReaderConfig> call(NoParams params) async => repository.getReaderConfig();
}

/// 重置阅读器配置用例
class ResetReaderConfig extends UseCase<void, NoParams> {

  ResetReaderConfig(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(NoParams params) async {
    // 保存默认配置
    const ReaderConfig defaultConfig = ReaderConfig();
    return repository.saveReaderConfig(config: defaultConfig);
  }
}

/// 更新字体大小用例
class UpdateFontSize extends UseCase<void, double> {

  UpdateFontSize(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(double fontSize) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(fontSize: fontSize);
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新阅读主题用例
class UpdateReaderTheme extends UseCase<void, ReaderTheme> {

  UpdateReaderTheme(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(ReaderTheme theme) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(theme: theme);
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新翻页模式用例
class UpdatePageMode extends UseCase<void, PageMode> {

  UpdatePageMode(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(PageMode pageMode) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(pageMode: pageMode);
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新行间距用例
class UpdateLineHeight extends UseCase<void, double> {

  UpdateLineHeight(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(double lineHeight) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(lineHeight: lineHeight);
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换音量键翻页用例
class ToggleVolumeKeyTurnPage extends UseCase<void, NoParams> {

  ToggleVolumeKeyTurnPage(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(NoParams params) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(
          volumeKeyTurnPage: !config.volumeKeyTurnPage,
        );
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换屏幕常亮用例
class ToggleKeepScreenOn extends UseCase<void, NoParams> {

  ToggleKeepScreenOn(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(NoParams params) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(
          keepScreenOn: !config.keepScreenOn,
        );
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换全屏模式用例
class ToggleFullScreenMode extends UseCase<void, NoParams> {

  ToggleFullScreenMode(this.repository);
  final ReaderRepository repository;

  @override
  ResultFuture<void> call(NoParams params) async {
    final Either<AppError, ReaderConfig> configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (AppError failure) => throw failure,
      (ReaderConfig config) async {
        final ReaderConfig updatedConfig = config.copyWith(
          fullScreenMode: !config.fullScreenMode,
        );
        return repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}