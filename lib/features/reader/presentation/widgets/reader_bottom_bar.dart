mport 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';

/// 阅读器底部控制栏
class ReaderBottomBar extends StatelessWidget {
  final bool isVisible;
  final int currentPage;
  final int totalPages;
  final bool isAutoPage;
  final VoidCallback? onBrightnessPressed;
  final VoidCallback? onAutoPagePressed;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onSharePressed;
  final ValueChanged<int>? onProgressChanged;

  const ReaderBottomBar({
    Key? key,
    this.isVisible = true,
    required this.currentPage,
    required this.totalPages,
    this.isAutoPage = false,
    this.onBrightnessPressed,
    this.onAutoPagePressed,
    this.onSettingsPressed,
    this.onSharePressed,
    this.onProgressChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      transform: Matrix4.translationValues(0, isVisible ? 0 : 100, 0),
      child: Container(
        padding: EdgeInsets.only(
          left: AppTheme.spacingRegular,
          right: AppTheme.spacingRegular,
          bottom: MediaQuery.of(context).padding.bottom + AppTheme.spacingRegular,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 进度条
            Row(
              children: [
                Text(
                  '${currentPage + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                Expanded(
                  child: Slider(
                    value: currentPage.toDouble(),
                    min: 0,
                    max: (totalPages - 1).toDouble(),
                    divisions: totalPages > 1 ? totalPages - 1 : 1,
                    onChanged: (value) {
                      onProgressChanged?.call(value.round());
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
                Text(
                  '$totalPages',
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
                  onPressed: onBrightnessPressed,
                ),
                IconButton(
                  icon: Icon(
                    isAutoPage ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  onPressed: onAutoPagePressed,
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields, color: Colors.white),
                  onPressed: onSettingsPressed,
                ),
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white),
                  onPressed: onSharePressed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}