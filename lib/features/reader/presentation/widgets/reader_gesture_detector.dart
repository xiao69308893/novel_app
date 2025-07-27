import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 阅读器手势检测器
class ReaderGestureDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;
  final VoidCallback? onCenterTap;
  final VoidCallback? onLongPress;
  final bool enableVolumeKeyTurnPage;

  const ReaderGestureDetector({
    Key? key,
    required this.child,
    this.onTap,
    this.onLeftTap,
    this.onRightTap,
    this.onCenterTap,
    this.onLongPress,
    this.enableVolumeKeyTurnPage = false,
  }) : super(key: key);

  @override
  State<ReaderGestureDetector> createState() => _ReaderGestureDetectorState();
}

class _ReaderGestureDetectorState extends State<ReaderGestureDetector> {
  @override
  void initState() {
    super.initState();
    if (widget.enableVolumeKeyTurnPage) {
      _setupVolumeKeyListener();
    }
  }

  void _setupVolumeKeyListener() {
    // 这里需要使用volume_controller插件来监听音量键
    // 示例代码，实际实现时需要添加相应的依赖
    /*
    VolumeController().listener((volume) {
      // 当音量键被按下时触发翻页
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      onTapUp: (details) {
        final screenWidth = MediaQuery.of(context).size.width;
        final tapX = details.globalPosition.dx;
        
        if (tapX < screenWidth * 0.3) {
          // 左侧点击
          widget.onLeftTap?.call();
        } else if (tapX > screenWidth * 0.7) {
          // 右侧点击
          widget.onRightTap?.call();
        } else {
          // 中间点击
          widget.onCenterTap?.call();
        }
      },
      child: widget.child,
    );
  }
}