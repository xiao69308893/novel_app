import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedef.dart';
import '../entities/reader_config.dart';
import '../repositories/reader_repository.dart';

/// 保存阅读器配置用例
class SaveReaderConfig extends UseCase<void, ReaderConfig> {
  final ReaderRepository repository;

  const SaveReaderConfig(this.repository);

  @override
  ResultFuture<void> call(ReaderConfig config) async {
    return await repository.saveReaderConfig(config: config);
  }
}

/// 获取阅读器配置用例
class GetReaderConfig extends UseCase<ReaderConfig, NoParams> {
  final ReaderRepository repository;

  const GetReaderConfig(this.repository);

  @override
  ResultFuture<ReaderConfig> call(NoParams params) async {
    return await repository.getReaderConfig();
  }
}

/// 重置阅读器配置用例
class ResetReaderConfig extends UseCase<void, NoParams> {
  final ReaderRepository repository;

  const ResetReaderConfig(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    // 保存默认配置
    const defaultConfig = ReaderConfig();
    return await repository.saveReaderConfig(config: defaultConfig);
  }
}

/// 更新字体大小用例
class UpdateFontSize extends UseCase<void, double> {
  final ReaderRepository repository;

  const UpdateFontSize(this.repository);

  @override
  ResultFuture<void> call(double fontSize) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(fontSize: fontSize);
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新阅读主题用例
class UpdateReaderTheme extends UseCase<void, ReaderTheme> {
  final ReaderRepository repository;

  const UpdateReaderTheme(this.repository);

  @override
  ResultFuture<void> call(ReaderTheme theme) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(theme: theme);
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新翻页模式用例
class UpdatePageMode extends UseCase<void, PageMode> {
  final ReaderRepository repository;

  const UpdatePageMode(this.repository);

  @override
  ResultFuture<void> call(PageMode pageMode) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(pageMode: pageMode);
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 更新行间距用例
class UpdateLineHeight extends UseCase<void, double> {
  final ReaderRepository repository;

  const UpdateLineHeight(this.repository);

  @override
  ResultFuture<void> call(double lineHeight) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(lineHeight: lineHeight);
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换音量键翻页用例
class ToggleVolumeKeyTurnPage extends UseCase<void, NoParams> {
  final ReaderRepository repository;

  const ToggleVolumeKeyTurnPage(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(
          volumeKeyTurnPage: !config.volumeKeyTurnPage,
        );
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换屏幕常亮用例
class ToggleKeepScreenOn extends UseCase<void, NoParams> {
  final ReaderRepository repository;

  const ToggleKeepScreenOn(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(
          keepScreenOn: !config.keepScreenOn,
        );
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}

/// 切换全屏模式用例
class ToggleFullScreenMode extends UseCase<void, NoParams> {
  final ReaderRepository repository;

  const ToggleFullScreenMode(this.repository);

  @override
  ResultFuture<void> call(NoParams params) async {
    final configResult = await repository.getReaderConfig();
    
    return configResult.fold(
      (failure) => throw failure,
      (config) async {
        final updatedConfig = config.copyWith(
          fullScreenMode: !config.fullScreenMode,
        );
        return await repository.saveReaderConfig(config: updatedConfig);
      },
    );
  }
}