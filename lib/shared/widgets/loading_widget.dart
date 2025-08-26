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

  const LoadingWidget({
    super.key,
    this.type = LoadingType.circular,
    this.message,
    this.size,
    this.color,
    this.showBackground = false,
    this.backgroundColor,
    this.textStyle,
    this.center = true,
  });
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color loadingColor = color ?? theme.primaryColor;
    
    Widget loadingWidget = _buildLoadingIndicator(loadingColor);
    
    if (message != null) {
      loadingWidget = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
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
    final double indicatorSize = size ?? 24.0;
    
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

  const DotsLoadingIndicator({
    required this.color, super.key,
    this.size = 24.0,
    this.dotCount = 3,
  });
  final Color color;
  final double size;
  final int dotCount;

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

    _animations = List.generate(widget.dotCount, (int index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index / widget.dotCount,
            (index + 1) / widget.dotCount,
            curve: Curves.easeInOut,
          ),
        ),
      ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double dotSize = widget.size / 6;
    
    return SizedBox(
      width: widget.size,
      height: dotSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.dotCount, (int index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (BuildContext context, Widget? child) => Opacity(
                opacity: _animations[index].value,
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          )),
      ),
    );
  }
}

/// 脉冲加载指示器
class PulseLoadingIndicator extends StatefulWidget {

  const PulseLoadingIndicator({
    required this.color, super.key,
    this.size = 24.0,
  });
  final Color color;
  final double size;

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
  Widget build(BuildContext context) => AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) => Transform.scale(
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
        ),
    );
}

/// 波浪加载指示器
class WaveLoadingIndicator extends StatefulWidget {

  const WaveLoadingIndicator({
    required this.color, super.key,
    this.size = 24.0,
  });
  final Color color;
  final double size;

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

    _animations = List.generate(4, (int index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double barWidth = widget.size / 8;
    final double barHeight = widget.size;
    
    return SizedBox(
      width: widget.size,
      height: barHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (int index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (BuildContext context, Widget? child) => Container(
                width: barWidth,
                height: barHeight * _animations[index].value,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(barWidth / 2),
                ),
              ),
          )),
      ),
    );
  }
}

/// 骨架屏加载指示器
class SkeletonLoadingIndicator extends StatefulWidget {

  const SkeletonLoadingIndicator({
    required this.width, required this.height, super.key,
    this.baseColor,
    this.highlightColor,
  });
  final double width;
  final double height;
  final Color? baseColor;
  final Color? highlightColor;

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
    final Color baseColor = widget.baseColor ?? Colors.grey[300]!;
    final Color highlightColor = widget.highlightColor ?? Colors.grey[100]!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: <double>[
                _animation.value - 1,
                _animation.value,
                _animation.value + 1,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
    );
  }
}

/// 全屏加载遮罩
class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
    this.loadingWidget,
    this.overlayColor,
  });
  /// 是否显示
  final bool isLoading;
  
  /// 子组件
  final Widget child;
  
  /// 加载组件
  final Widget? loadingWidget;
  
  /// 遮罩颜色
  final Color? overlayColor;

  @override
  Widget build(BuildContext context) => Stack(
      children: <Widget>[
        child,
        if (isLoading)
          ColoredBox(
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

/// 列表加载更多组件
class LoadMoreWidget extends StatelessWidget {

  const LoadMoreWidget({
    required this.isLoading, required this.hasMore, super.key,
    this.onLoadMore,
    this.loadingText,
    this.noMoreText,
    this.loadMoreText,
  });
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingRegular),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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

  const RefreshWidget({
    required this.child, super.key,
    this.onRefresh,
    this.color,
  });
  /// 子组件
  final Widget child;
  
  /// 刷新回调
  final Future<void> Function()? onRefresh;
  
  /// 刷新指示器颜色
  final Color? color;

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

  const LoadingBuilder({
    required this.isLoading, required this.contentBuilder, super.key,
    this.loadingBuilder,
  });
  /// 是否正在加载
  final bool isLoading;
  
  /// 加载组件构建器
  final Widget Function()? loadingBuilder;
  
  /// 内容组件构建器
  final Widget Function() contentBuilder;

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
      builder: (BuildContext context) => Dialog(
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
  }) => ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (BuildContext context, int index) => Container(
          height: itemHeight,
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingRegular,
            vertical: AppTheme.spacingSmall,
          ),
          child: Row(
            children: <Widget>[
              SkeletonLoadingIndicator(
                width: itemHeight - 16,
                height: itemHeight - 16,
              ),
              const SizedBox(width: AppTheme.spacingRegular),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SkeletonLoadingIndicator(
                      width: double.infinity,
                      height: 16,
                    ),
                    SizedBox(height: AppTheme.spacingSmall),
                    SkeletonLoadingIndicator(
                      width: 100,
                      height: 12,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
}