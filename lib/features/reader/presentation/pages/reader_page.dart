import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../app/themes/app_theme.dart';
import '../blocs/reader/reader_bloc.dart';
import '../widgets/reader_content.dart';
import '../widgets/reader_controls.dart';
import '../widgets/reader_settings_panel.dart';
import '../widgets/chapter_list_drawer.dart';

/// 阅读器页面
class ReaderPage extends StatefulWidget {
  final String novelId;
  final String? chapterId;
  final int? chapterNumber;

  const ReaderPage({
    Key? key,
    required this.novelId,
    this.chapterId,
    this.chapterNumber,
  }) : super(key: key);

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  bool _showSettingsPanel = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化阅读器
    context.read<ReaderBloc>().add(InitializeReader(
      novelId: widget.novelId,
      chapterId: widget.chapterId,
      chapterNumber: widget.chapterNumber,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderBloc, ReaderState>(
      builder: (context, state) {
        if (state is ReaderLoading) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: LoadingWidget(
              message: state.message,
              center: true,
            ),
          );
        }

        if (state is ReaderError) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: AppErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<ReaderBloc>().add(InitializeReader(
                  novelId: widget.novelId,
                  chapterId: widget.chapterId,
                  chapterNumber: widget.chapterNumber,
                ));
              },
            ),
          );
        }

        if (state is ReaderLoaded) {
          return _buildReaderInterface(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildReaderInterface(BuildContext context, ReaderLoaded state) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: state.config.theme.backgroundColor,
        statusBarIconBrightness: state.config.theme == ReaderTheme.light 
            ? Brightness.dark 
            : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: state.config.theme.backgroundColor,
        drawer: ChapterListDrawer(
          novel: state.novel,
          chapters: state.chapterList,
          currentChapterId: state.session.currentChapter.id,
          onChapterSelected: (chapterId) {
            Navigator.pop(context);
            context.read<ReaderBloc>().add(LoadChapter(
              novelId: widget.novelId,
              chapterId: chapterId,
            ));
          },
        ),
        body: Stack(
          children: [
            // 主要阅读内容
            ReaderContent(
              session: state.session,
              config: state.config,
              onTap: () {
                context.read<ReaderBloc>().add(const ToggleUIVisibility());
              },
              onPageTurn: (forward) {
                context.read<ReaderBloc>().add(TurnPage(forward));
              },
            ),

            // 控制栏（顶部和底部）
            if (state.isUIVisible)
              ReaderControls(
                novel: state.novel,
                session: state.session,
                config: state.config,
                onMenuTap: () => Scaffold.of(context).openDrawer(),
                onSettingsTap: () {
                  setState(() {
                    _showSettingsPanel = !_showSettingsPanel;
                  });
                },
                onBookmarkTap: () {
                  context.read<ReaderBloc>().add(const AddBookmarkEvent());
                },
                onAutoPageToggle: () {
                  context.read<ReaderBloc>().add(const ToggleAutoPage());
                },
                onProgressChanged: (page) {
                  context.read<ReaderBloc>().add(JumpToPage(page));
                },
              ),

            // 设置面板
            if (_showSettingsPanel)
              ReaderSettingsPanel(
                config: state.config,
                onConfigChanged: (config) {
                  context.read<ReaderBloc>().add(UpdateReaderConfig(config));
                },
                onClose: () {
                  setState(() {
                    _showSettingsPanel = false;
                  });
                },
              ),

            // 错误提示
            if (state.error != null)
              Positioned(
                bottom: 100,
                left: AppTheme.spacingRegular,
                right: AppTheme.spacingRegular,
                child: Card(
                  color: Colors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingRegular),
                    child: Text(
                      state.error!,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}