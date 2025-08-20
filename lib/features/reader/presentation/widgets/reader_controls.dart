import 'package:flutter/material.dart';
import '../../../../shared/models/novel_model.dart';
import '../../../../app/themes/app_theme.dart';
import '../../domain/entities/reader_config.dart';
import '../../domain/entities/reading_session.dart';

/// 阅读器控制栏组件
class ReaderControls extends StatelessWidget {
  final NovelModel novel;
  final ReadingSession session;
  final ReaderConfig config;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onAutoPageToggle;
  final ValueChanged<int>? onProgressChanged;

  const ReaderControls({
    Key? key,
    required this.novel,
    required this.session,
    required this.config,
    this.onMenuTap,
    this.onSettingsTap,
    this.onBookmarkTap,
    this.onAutoPageToggle,
    this.onProgressChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 顶部控制栏
        _buildTopBar(context),
        
        const Spacer(),
        
        // 底部控制栏
        _buildBottomBar(context),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: AppTheme.spacingRegular,
        right: AppTheme.spacingRegular,
        bottom: AppTheme.spacingRegular,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
      ),
      child: Row(
        children: [
          // 返回按钮
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          
          // 标题信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  novel.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  session.currentChapter.title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 功能按钮
          IconButton(
            icon: Icon(
              session.hasBookmarkAtCurrentPosition 
                  ? Icons.bookmark 
                  : Icons.bookmark_border,
              color: session.hasBookmarkAtCurrentPosition 
                  ? Colors.amber 
                  : Colors.white,
            ),
            onPressed: onBookmarkTap,
          ),
          
          IconButton(
            icon: const Icon(Icons.list, color: Colors.white),
            onPressed: onMenuTap,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.spacingRegular,
        right: AppTheme.spacingRegular,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingRegular,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度条
          Row(
            children: [
              Text(
                '${session.currentPage + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              
              Expanded(
                child: Slider(
                  value: session.currentPage.toDouble(),
                  min: 0,
                  max: (session.pages.length - 1).toDouble(),
                  divisions: session.pages.length - 1,
                  onChanged: (value) {
                    onProgressChanged?.call(value.round());
                  },
                  activeColor: Colors.white,
                  inactiveColor: Colors.white30,
                ),
              ),
              
              Text(
                '${session.pages.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          
          // 控制按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.brightness_6, color: Colors.white),
                onPressed: () {
                  // 亮度调节
                },
              ),
              
              IconButton(
                icon: Icon(
                  session.isAutoPage ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: onAutoPageToggle,
              ),
              
              IconButton(
                icon: const Icon(Icons.text_fields, color: Colors.white),
                onPressed: onSettingsTap,
              ),
              
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // 分享功能
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}