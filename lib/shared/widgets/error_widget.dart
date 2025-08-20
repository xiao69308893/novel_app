import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_error.dart';

/// 错误组件类型枚举
enum ErrorWidgetType {
  simple,      // 简单错误显示
  detailed,    // 详细错误显示
  network,     // 网络错误
  empty,       // 空数据
  permission,  // 权限错误
  notFound,    // 资源未找到
}

/// 通用错误组件
class AppErrorWidget extends StatelessWidget {
  /// 错误类型
  final ErrorWidgetType type;
  
  /// 错误信息
  final String message;
  
  /// 错误描述
  final String? description;
  
  /// 错误图标
  final IconData? icon;
  
  /// 错误图标大小
  final double? iconSize;
  
  /// 错误图标颜色
  final Color? iconColor;
  
  /// 重试按钮文本
  final String? retryText;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 是否显示重试按钮
  final bool showRetryButton;
  
  /// 是否紧凑布局
  final bool compact;
  
  /// 自定义操作按钮
  final List<Widget>? actions;

  const AppErrorWidget({
    Key? key,
    this.type = ErrorWidgetType.simple,
    required this.message,
    this.description,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.retryText,
    this.onRetry,
    this.showRetryButton = true,
    this.compact = false,
    this.actions,
  }) : super(key: key);

  /// 从AppError创建错误组件
  factory AppErrorWidget.fromError(
    AppError error, {
    VoidCallback? onRetry,
    String? retryText,
    bool showRetryButton = true,
    bool compact = false,
  }) {
    ErrorWidgetType type;
    IconData icon;
    
    switch (error.type) {
      case AppErrorType.network:
      case AppErrorType.timeout:
        type = ErrorWidgetType.network;
        icon = Icons.wifi_off;
        break;
      case AppErrorType.noInternet:
        type = ErrorWidgetType.network;
        icon = Icons.signal_wifi_off;
        break;
      case AppErrorType.notFound:
        type = ErrorWidgetType.notFound;
        icon = Icons.search_off;
        break;
      case AppErrorType.permission:
        type = ErrorWidgetType.permission;
        icon = Icons.lock;
        break;
      case AppErrorType.unauthorized:
      case AppErrorType.forbidden:
        type = ErrorWidgetType.permission;
        icon = Icons.security;
        break;
      default:
        type = ErrorWidgetType.simple;
        icon = Icons.error_outline;
        break;
    }

    return AppErrorWidget(
      type: type,
      message: error.message,
      description: error.code != null ? '错误代码: ${error.code}' : null,
      icon: icon,
      onRetry: error.isRetriable ? onRetry : null,
      retryText: retryText,
      showRetryButton: showRetryButton && error.isRetriable,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (compact) {
      return _buildCompactError(theme);
    }
    
    return _buildFullError(theme);
  }

  /// 构建完整错误显示
  Widget _buildFullError(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 错误图标
            Icon(
              _getErrorIcon(),
              size: iconSize ?? 64,
              color: iconColor ?? _getErrorColor(),
            ),
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 错误标题
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            // 错误描述
            if (description != null) ...[
              const SizedBox(height: AppTheme.spacingRegular),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            const SizedBox(height: AppTheme.spacingLarge),
            
            // 操作按钮
            _buildActions(theme),
          ],
        ),
      ),
    );
  }

  /// 构建紧凑错误显示
  Widget _buildCompactError(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      child: Row(
        children: [
          Icon(
            _getErrorIcon(),
            size: iconSize ?? 24,
            color: iconColor ?? _getErrorColor(),
          ),
          const SizedBox(width: AppTheme.spacingRegular),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: theme.textTheme.bodyMedium,
                ),
                if (description != null) ...[
                  const SizedBox(height: AppTheme.spacingXSmall),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          if (showRetryButton && onRetry != null) ...[
            const SizedBox(width: AppTheme.spacingRegular),
            TextButton(
              onPressed: onRetry,
              child: Text(retryText ?? '重试'),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建操作按钮
  Widget _buildActions(ThemeData theme) {
    final buttons = <Widget>[];
    
    if (showRetryButton && onRetry != null) {
      buttons.add(
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: Text(retryText ?? '重试'),
        ),
      );
    }
    
    if (actions != null) {
      buttons.addAll(actions!);
    }
    
    if (buttons.isEmpty) return const SizedBox.shrink();
    
    return Wrap(
      spacing: AppTheme.spacingRegular,
      runSpacing: AppTheme.spacingSmall,
      alignment: WrapAlignment.center,
      children: buttons,
    );
  }

  /// 获取错误图标
  IconData _getErrorIcon() {
    if (icon != null) return icon!;
    
    switch (type) {
      case ErrorWidgetType.network:
        return Icons.wifi_off;
      case ErrorWidgetType.empty:
        return Icons.inbox;
      case ErrorWidgetType.permission:
        return Icons.lock;
      case ErrorWidgetType.notFound:
        return Icons.search_off;
      case ErrorWidgetType.detailed:
        return Icons.error;
      case ErrorWidgetType.simple:
      default:
        return Icons.error_outline;
    }
  }

  /// 获取错误颜色
  Color _getErrorColor() {
    switch (type) {
      case ErrorWidgetType.network:
        return Colors.orange;
      case ErrorWidgetType.empty:
        return Colors.grey;
      case ErrorWidgetType.permission:
        return Colors.red;
      case ErrorWidgetType.notFound:
        return Colors.blue;
      case ErrorWidgetType.detailed:
      case ErrorWidgetType.simple:
      default:
        return Colors.red;
    }
  }
}

/// 网络错误组件
class NetworkErrorWidget extends StatelessWidget {
  /// 错误信息
  final String? message;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 是否紧凑布局
  final bool compact;

  const NetworkErrorWidget({
    Key? key,
    this.message,
    this.onRetry,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      type: ErrorWidgetType.network,
      message: message ?? AppConstants.networkErrorMessage,
      icon: Icons.wifi_off,
      onRetry: onRetry,
      compact: compact,
    );
  }
}

/// 空数据组件
class EmptyDataWidget extends StatelessWidget {
  /// 空数据信息
  final String? message;
  
  /// 空数据图标
  final IconData? icon;
  
  /// 操作按钮文本
  final String? actionText;
  
  /// 操作回调
  final VoidCallback? onAction;
  
  /// 是否紧凑布局
  final bool compact;

  const EmptyDataWidget({
    Key? key,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      type: ErrorWidgetType.empty,
      message: message ?? AppConstants.noDataMessage,
      icon: icon ?? Icons.inbox,
      retryText: actionText,
      onRetry: onAction,
      showRetryButton: onAction != null,
      compact: compact,
    );
  }
}

/// 权限错误组件
class PermissionErrorWidget extends StatelessWidget {
  /// 权限名称
  final String? permission;
  
  /// 错误信息
  final String? message;
  
  /// 设置回调
  final VoidCallback? onSettings;
  
  /// 是否紧凑布局
  final bool compact;

  const PermissionErrorWidget({
    Key? key,
    this.permission,
    this.message,
    this.onSettings,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = message ?? 
        (permission != null ? '需要$permission权限' : '权限不足');
    
    return AppErrorWidget(
      type: ErrorWidgetType.permission,
      message: errorMessage,
      icon: Icons.lock,
      retryText: '去设置',
      onRetry: onSettings,
      showRetryButton: onSettings != null,
      compact: compact,
    );
  }
}

/// 404错误组件
class NotFoundWidget extends StatelessWidget {
  /// 资源类型
  final String? resourceType;
  
  /// 错误信息
  final String? message;
  
  /// 返回回调
  final VoidCallback? onBack;
  
  /// 是否紧凑布局
  final bool compact;

  const NotFoundWidget({
    Key? key,
    this.resourceType,
    this.message,
    this.onBack,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final errorMessage = message ?? 
        (resourceType != null ? '$resourceType不存在' : '请求的资源不存在');
    
    return AppErrorWidget(
      type: ErrorWidgetType.notFound,
      message: errorMessage,
      icon: Icons.search_off,
      retryText: '返回',
      onRetry: onBack ?? () => Navigator.pop(context),
      compact: compact,
    );
  }
}

/// 错误状态构建器
class ErrorStateBuilder extends StatelessWidget {
  /// 是否有错误
  final bool hasError;
  
  /// 错误信息
  final String? error;
  
  /// 错误组件构建器
  final Widget Function(String error)? errorBuilder;
  
  /// 内容组件构建器
  final Widget Function() contentBuilder;

  const ErrorStateBuilder({
    Key? key,
    required this.hasError,
    this.error,
    this.errorBuilder,
    required this.contentBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      return errorBuilder?.call(error ?? '未知错误') ?? 
          AppErrorWidget(message: error ?? '未知错误');
    }
    return contentBuilder();
  }
}

/// 多状态组件（加载、错误、空数据、内容）
class MultiStateWidget extends StatelessWidget {
  /// 是否正在加载
  final bool isLoading;
  
  /// 是否有错误
  final bool hasError;
  
  /// 是否为空数据
  final bool isEmpty;
  
  /// 错误信息
  final String? error;
  
  /// 加载组件
  final Widget? loadingWidget;
  
  /// 错误组件
  final Widget? errorWidget;
  
  /// 空数据组件
  final Widget? emptyWidget;
  
  /// 内容组件
  final Widget child;
  
  /// 重试回调
  final VoidCallback? onRetry;

  const MultiStateWidget({
    Key? key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    this.error,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (hasError) {
      return errorWidget ?? AppErrorWidget(
        message: error ?? '加载失败',
        onRetry: onRetry,
      );
    }
    
    if (isEmpty) {
      return emptyWidget ?? const EmptyDataWidget();
    }
    
    return child;
  }
}

/// 错误边界组件
class ErrorBoundary extends StatefulWidget {
  /// 子组件
  final Widget child;
  
  /// 错误组件构建器
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  
  /// 错误回调
  final void Function(Object error, StackTrace? stackTrace)? onError;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
    this.onError,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          AppErrorWidget(
            message: '组件渲染出错',
            description: _error.toString(),
            onRetry: _reset,
          );
    }
    
    return widget.child;
  }

  void _reset() {
    setState(() {
      _error = null;
      _stackTrace = null;
    });
  }

  @override
  void didUpdateWidget(ErrorBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child != widget.child) {
      _reset();
    }
  }
}

/// 错误组件工具类
class ErrorWidgetUtils {
  /// 创建网络错误组件
  static Widget networkError({
    String? message,
    VoidCallback? onRetry,
    bool compact = false,
  }) {
    return NetworkErrorWidget(
      message: message,
      onRetry: onRetry,
      compact: compact,
    );
  }

  /// 创建空数据组件
  static Widget emptyData({
    String? message,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return EmptyDataWidget(
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      compact: compact,
    );
  }

  /// 创建权限错误组件
  static Widget permissionError({
    String? permission,
    String? message,
    VoidCallback? onSettings,
    bool compact = false,
  }) {
    return PermissionErrorWidget(
      permission: permission,
      message: message,
      onSettings: onSettings,
      compact: compact,
    );
  }

  /// 创建404错误组件
  static Widget notFound({
    String? resourceType,
    String? message,
    VoidCallback? onBack,
    bool compact = false,
  }) {
    return NotFoundWidget(
      resourceType: resourceType,
      message: message,
      onBack: onBack,
      compact: compact,
    );
  }

  /// 显示错误对话框
  static void showErrorDialog(
    BuildContext context, {
    required String message,
    String? title,
    String? description,
    VoidCallback? onRetry,
    String? retryText,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? '错误'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: Text(retryText ?? '重试'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}