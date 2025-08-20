import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';

/// 加载组件类型枚举
enum LoadingType {
  circular,    // 圆形加载指示器
  linear,      // 线性加载指示器
  dots,        // 点状加载指示器
  pulse,       // 脉冲加载指示器
  wave,        // 波浪加载指示器
  skeleton,    // 骨架屏
}

/// 通用加载组件
class LoadingWidget extends StatelessWidget {
  /// 加载类型
  final LoadingType type;
  
  /// 加载文本
  final String? message;
  
  /// 大小
  final double? size;
  
  /// 颜色
  final Color? color;
  
  /// 是否显示背景
  final bool showBackground;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 文本样式
  final TextStyle? textStyle;
  
  /// 是否显示在中心
  final bool center;

  const LoadingWidget({
    Key? key,
    this.type = LoadingType.circular,
    this.message,
    this.size,
    this.color,
    this.showBackground = false,
    this.backgroundColor,
    this.textStyle,
    this.center = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loadingColor = color ?? theme.primaryColor;
    
    Widget loadingWidget = _buildLoadingIndicator(loadingColor);
    
    if (message != null) {
      loadingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          loadingWidget,
          const SizedBox(height: AppTheme.spacingRegular),
          Text(
            message!,
            style: textStyle ?? theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    if (showBackground) {
      loadingWidget = Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        ),
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: loadingWidget,
      );
    }

    if (center) {
      loadingWidget = Center(child: loadingWidget);
    }

    return loadingWidget;
  }

  /// 构建加载指示器
  Widget _buildLoadingIndicator(Color color) {
    final indicatorSize = size ?? 24.0;
    
    switch (type) {
      case LoadingType.circular:
        return SizedBox(
          width: indicatorSize,
          height: indicatorSize,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeWidth: 2.0,
          ),
        );
        
      case LoadingType.linear:
        return SizedBox(
          width: size ?? 200.0,
          child: LinearProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        );
        
      case LoadingType.dots:
        return DotsLoadingIndicator(
          color: color,
          size: indicatorSize,
        );
        
      case LoadingType.pulse:
        return PulseLoadingIndicator(
          color: color,
          size: indicatorSize,
        );
        
      case LoadingType.wave:
        return WaveLoadingIndicator(
          color: color,
          size: indicatorSize,
        );
        
      case LoadingType.skeleton:
        return SkeletonLoadingIndicator(
          width: size ?? 200.0,
          height: indicatorSize,
        );
    }
  }
}

/// 点状加载指示器
class DotsLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;
  final int dotCount;

  const DotsLoadingIndicator({
    Key? key,
    required this.color,
    this.size = 24.0,
    this.dotCount = 3,
  }) : super(key: key);

  @override
  State<DotsLoadingIndicator> createState() => _DotsLoadingIndicatorState();
}

class _DotsLoadingIndicatorState extends State<DotsLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _animations = List.generate(widget.dotCount, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.dotCount,
            (index + 1) / widget.dotCount,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotSize = widget.size / 6;
    
    return SizedBox(
      width: widget.size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.dotCount, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 脉冲加载指示器
class PulseLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const PulseLoadingIndicator({
    Key? key,
    required this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<PulseLoadingIndicator> createState() => _PulseLoadingIndicatorState();
}

class _PulseLoadingIndicatorState extends State<PulseLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 波浪加载指示器
class WaveLoadingIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const WaveLoadingIndicator({
    Key? key,
    required this.color,
    this.size = 24.0,
  }) : super(key: key);

  @override
  State<WaveLoadingIndicator> createState() => _WaveLoadingIndicatorState();
}

class _WaveLoadingIndicatorState extends State<WaveLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animations = List.generate(4, (index) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final barWidth = widget.size / 8;
    final barHeight = widget.size;
    
    return SizedBox(
      width: widget.size,
      height: barHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Container(
                width: barWidth,
                height: barHeight * _animations[index].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/// 骨架屏加载指示器
class SkeletonLoadingIndicator extends StatefulWidget {
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoadingIndicator({
    Key? key,
    required this.width,
    required this.height,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  @override
  State<SkeletonLoadingIndicator> createState() => _SkeletonLoadingIndicatorState();
}

class _SkeletonLoadingIndicatorState extends State<SkeletonLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? Colors.grey[300]!;
    final highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        );
      },
    );
  }
}

/// 全屏加载遮罩
class LoadingOverlay extends StatelessWidget {
  /// 是否显示
  final bool isLoading;
  
  /// 子组件
  final Widget child;
  
  /// 加载组件
  final Widget? loadingWidget;
  
  /// 遮罩颜色
  final Color? overlayColor;

  const LoadingOverlay({
    Key? key,
    required this.isLoading,
    required this.child,
    this.loadingWidget,
    this.overlayColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
            child: loadingWidget ?? 
                const LoadingWidget(
                  message: AppConstants.loadingMessage,
                  showBackground: true,
                ),
          ),
      ],
    );
  }
}

/// 列表加载更多组件
class LoadMoreWidget extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;
  
  /// 是否有更多数据
  final bool hasMore;
  
  /// 加载更多回调
  final VoidCallback? onLoadMore;
  
  /// 加载文本
  final String? loadingText;
  
  /// 无更多数据文本
  final String? noMoreText;
  
  /// 点击加载更多文本
  final String? loadMoreText;

  const LoadMoreWidget({
    Key? key,
    required this.isLoading,
    required this.hasMore,
    this.onLoadMore,
    this.loadingText,
    this.noMoreText,
    this.loadMoreText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Text(
              loadingText ?? AppConstants.loadingMoreMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasMore) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        alignment: Alignment.center,
        child: Text(
          noMoreText ?? AppConstants.noMoreDataMessage,
          style: theme.textTheme.bodySmall,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onLoadMore,
        child: Text(
          loadMoreText ?? '点击加载更多',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.primaryColor,
          ),
        ),
      ),
    );
  }
}

/// 下拉刷新组件
class RefreshWidget extends StatelessWidget {
  /// 子组件
  final Widget child;
  
  /// 刷新回调
  final Future<void> Function()? onRefresh;
  
  /// 刷新指示器颜色
  final Color? color;

  const RefreshWidget({
    Key? key,
    required this.child,
    this.onRefresh,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onRefresh == null) {
      return child;
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      color: color ?? Theme.of(context).primaryColor,
      child: child,
    );
  }
}

/// 加载状态构建器
class LoadingBuilder extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;
  
  /// 加载组件构建器
  final Widget Function()? loadingBuilder;
  
  /// 内容组件构建器
  final Widget Function() contentBuilder;

  const LoadingBuilder({
    Key? key,
    required this.isLoading,
    this.loadingBuilder,
    required this.contentBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingBuilder?.call() ?? const LoadingWidget();
    }
    return contentBuilder();
  }
}

/// 加载组件工具类
class LoadingUtils {
  /// 显示加载对话框
  static void showLoadingDialog(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: LoadingWidget(
          message: message ?? AppConstants.loadingMessage,
          showBackground: true,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// 创建骨架屏列表
  static Widget buildSkeletonList({
    int itemCount = 5,
    double itemHeight = 80,
    EdgeInsets? padding,
  }) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingRegular,
            vertical: AppTheme.spacingSmall,
          ),
          child: Row(
            children: [
              SkeletonLoadingIndicator(
                width: itemHeight - 16,
                height: itemHeight - 16,
              ),
              const SizedBox(width: AppTheme.spacingRegular),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SkeletonLoadingIndicator(
                      width: double.infinity,
                      height: 16,
                    ),
                    const SizedBox(height: AppTheme.spacingSmall),
                    SkeletonLoadingIndicator(
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}