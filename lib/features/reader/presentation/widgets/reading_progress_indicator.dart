import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';

/// 阅读进度指示器组件
class ReadingProgressIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final double progress;
  final ValueChanged<int>? onPageChanged;

  const ReadingProgressIndicator({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.progress,
    this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingRegular,
        vertical: AppTheme.spacingSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 进度文本
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '第 ${currentPage + 1} 页',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
              Text(
                '共 $totalPages 页',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSmall),
          
          // 进度滑块
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withValues(alpha: 0.1),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: currentPage.toDouble(),
              min: 0,
              max: (totalPages - 1).toDouble(),
              divisions: totalPages - 1,
              onChanged: (value) {
                onPageChanged?.call(value.round());
              },
            ),
          ),
        ],
      ),
    );
  }
}