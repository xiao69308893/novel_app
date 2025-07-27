import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';

/// 对话框类型枚举
enum DialogType {
  info,
  success,
  warning,
  error,
  confirm,
  custom,
}

/// 通用对话框
class CustomDialog extends StatelessWidget {
  /// 对话框类型
  final DialogType type;
  
  /// 标题
  final String? title;
  
  /// 内容
  final String? content;
  
  /// 自定义内容组件
  final Widget? contentWidget;
  
  /// 确认按钮文本
  final String? confirmText;
  
  /// 取消按钮文本
  final String? cancelText;
  
  /// 确认回调
  final VoidCallback? onConfirm;
  
  /// 取消回调
  final VoidCallback? onCancel;
  
  /// 是否显示取消按钮
  final bool showCancelButton;
  
  /// 是否可以通过点击外部区域关闭
  final bool barrierDismissible;
  
  /// 自定义图标
  final Widget? icon;
  
  /// 自定义操作按钮
  final List<Widget>? actions;

  const CustomDialog({
    Key? key,
    this.type = DialogType.info,
    this.title,
    this.content,
    this.contentWidget,
    this.confirmText,
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.showCancelButton = true,
    this.barrierDismissible = true,
    this.icon,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: _buildTitle(theme),
      content: _buildContent(theme),
      actions: _buildActions(context, theme),
      actionsPadding: const EdgeInsets.only(
        right: AppTheme.spacingRegular,
        bottom: AppTheme.spacingRegular,
      ),
    );
  }

  /// 构建标题
  Widget? _buildTitle(ThemeData theme) {
    if (title == null && icon == null) return null;
    
    return Row(
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: AppTheme.spacingRegular),
        ] else if (type != DialogType.custom) ...[
          Icon(
            _getTypeIcon(),
            color: _getTypeColor(),
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingRegular),
        ],
        if (title != null)
          Expanded(
            child: Text(
              title!,
              style: theme.textTheme.headlineSmall,
            ),
          ),
      ],
    );
  }

  /// 构建内容
  Widget? _buildContent(ThemeData theme) {
    if (contentWidget != null) {
      return contentWidget;
    }
    
    if (content != null) {
      return Text(
        content!,
        style: theme.textTheme.bodyMedium,
      );
    }
    
    return null;
  }

  /// 构建操作按钮
  List<Widget>? _buildActions(BuildContext context, ThemeData theme) {
    if (actions != null) {
      return actions;
    }
    
    final buttons = <Widget>[];
    
    if (showCancelButton) {
      buttons.add(
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelText ?? '取消'),
        ),
      );
    }
    
    buttons.add(
      ElevatedButton(
        onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getTypeColor(),
        ),
        child: Text(confirmText ?? '确定'),
      ),
    );
    
    return buttons;
  }

  /// 获取类型图标
  IconData _getTypeIcon() {
    switch (type) {
      case DialogType.info:
        return Icons.info_outline;
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.warning:
        return Icons.warning_outlined;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.confirm:
        return Icons.help_outline;
      case DialogType.custom:
      default:
        return Icons.info_outline;
    }
  }

  /// 获取类型颜色
  Color _getTypeColor() {
    switch (type) {
      case DialogType.info:
        return Colors.blue;
      case DialogType.success:
        return Colors.green;
      case DialogType.warning:
        return Colors.orange;
      case DialogType.error:
        return Colors.red;
      case DialogType.confirm:
        return Colors.blue;
      case DialogType.custom:
      default:
        return Colors.blue;
    }
  }
}

/// 加载对话框
class LoadingDialog extends StatelessWidget {
  /// 加载文本
  final String? message;
  
  /// 是否可以取消
  final bool cancellable;
  
  /// 取消回调
  final VoidCallback? onCancel;

  const LoadingDialog({
    Key? key,
    this.message,
    this.cancellable = false,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => cancellable,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacingRegular),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: cancellable
            ? [
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ]
            : null,
      ),
    );
  }
}

/// 输入对话框
class InputDialog extends StatefulWidget {
  /// 标题
  final String? title;
  
  /// 提示文本
  final String? hint;
  
  /// 初始值
  final String? initialValue;
  
  /// 确认按钮文本
  final String? confirmText;
  
  /// 取消按钮文本
  final String? cancelText;
  
  /// 输入验证
  final String? Function(String?)? validator;
  
  /// 键盘类型
  final TextInputType? keyboardType;
  
  /// 最大行数
  final int? maxLines;
  
  /// 最大长度
  final int? maxLength;

  const InputDialog({
    Key? key,
    this.title,
    this.hint,
    this.initialValue,
    this.confirmText,
    this.cancelText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  }) : super(key: key);

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: widget.title != null ? Text(widget.title!) : null,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: _errorText,
            counterText: widget.maxLength != null ? null : '',
          ),
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          autofocus: true,
          validator: widget.validator,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() {
                _errorText = null;
              });
            }
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText ?? '取消'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: Text(widget.confirmText ?? '确定'),
        ),
      ],
    );
  }

  void _handleConfirm() {
    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      if (error != null) {
        setState(() {
          _errorText = error;
        });
        return;
      }
    }
    
    Navigator.of(context).pop(_controller.text);
  }
}

/// 列表选择对话框
class ListSelectionDialog<T> extends StatefulWidget {
  /// 标题
  final String? title;
  
  /// 选项列表
  final List<T> items;
  
  /// 选项标题构建器
  final String Function(T item) titleBuilder;
  
  /// 选项副标题构建器
  final String? Function(T item)? subtitleBuilder;
  
  /// 初始选中项
  final T? initialValue;
  
  /// 是否多选
  final bool multiSelect;
  
  /// 初始选中项列表（多选）
  final List<T>? initialValues;
  
  /// 确认按钮文本
  final String? confirmText;
  
  /// 取消按钮文本
  final String? cancelText;

  const ListSelectionDialog({
    Key? key,
    this.title,
    required this.items,
    required this.titleBuilder,
    this.subtitleBuilder,
    this.initialValue,
    this.multiSelect = false,
    this.initialValues,
    this.confirmText,
    this.cancelText,
  }) : super(key: key);

  @override
  State<ListSelectionDialog<T>> createState() => _ListSelectionDialogState<T>();
}

class _ListSelectionDialogState<T> extends State<ListSelectionDialog<T>> {
  T? _selectedItem;
  final Set<T> _selectedItems = {};

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      _selectedItems.addAll(widget.initialValues ?? []);
    } else {
      _selectedItem = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: widget.title != null ? Text(widget.title!) : null,
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return _buildListItem(item);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText ?? '取消'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          child: Text(widget.confirmText ?? '确定'),
        ),
      ],
    );
  }

  Widget _buildListItem(T item) {
    if (widget.multiSelect) {
      return CheckboxListTile(
        title: Text(widget.titleBuilder(item)),
        subtitle: widget.subtitleBuilder != null
            ? Text(widget.subtitleBuilder!(item) ?? '')
            : null,
        value: _selectedItems.contains(item),
        onChanged: (selected) {
          setState(() {
            if (selected == true) {
              _selectedItems.add(item);
            } else {
              _selectedItems.remove(item);
            }
          });
        },
      );
    } else {
      return RadioListTile<T>(
        title: Text(widget.titleBuilder(item)),
        subtitle: widget.subtitleBuilder != null
            ? Text(widget.subtitleBuilder!(item) ?? '')
            : null,
        value: item,
        groupValue: _selectedItem,
        onChanged: (value) {
          setState(() {
            _selectedItem = value;
          });
        },
      );
    }
  }

  void _handleConfirm() {
    if (widget.multiSelect) {
      Navigator.of(context).pop(_selectedItems.toList());
    } else {
      Navigator.of(context).pop(_selectedItem);
    }
  }
}

/// 底部选择对话框
class BottomSheetDialog extends StatelessWidget {
  /// 标题
  final String? title;
  
  /// 选项列表
  final List<BottomSheetItem> items;
  
  /// 是否显示取消按钮
  final bool showCancelButton;
  
  /// 取消按钮文本
  final String? cancelText;

  const BottomSheetDialog({
    Key? key,
    this.title,
    required this.items,
    this.showCancelButton = true,
    this.cancelText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
              ),
              child: Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          
          // 选项列表
          ...items.map((item) => _buildItem(context, item)),
          
          if (showCancelButton) ...[
            const Divider(height: 1),
            ListTile(
              title: Text(
                cancelText ?? '取消',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
          
          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, BottomSheetItem item) {
    return ListTile(
      leading: item.icon,
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: () {
        Navigator.of(context).pop(item.value);
        item.onTap?.call();
      },
    );
  }
}

/// 底部选择对话框选项
class BottomSheetItem {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final dynamic value;
  final VoidCallback? onTap;

  const BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
    this.onTap,
  });
}

/// 对话框工具类
class DialogUtils {
  /// 显示信息对话框
  static Future<bool?> showInfo(
    BuildContext context, {
    String? title,
    required String content,
    String? confirmText,
    bool showCancelButton = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.info,
        title: title ?? '提示',
        content: content,
        confirmText: confirmText,
        showCancelButton: showCancelButton,
      ),
    );
  }

  /// 显示成功对话框
  static Future<bool?> showSuccess(
    BuildContext context, {
    String? title,
    required String content,
    String? confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.success,
        title: title ?? '成功',
        content: content,
        confirmText: confirmText,
        showCancelButton: false,
      ),
    );
  }

  /// 显示警告对话框
  static Future<bool?> showWarning(
    BuildContext context, {
    String? title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.warning,
        title: title ?? '警告',
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  /// 显示错误对话框
  static Future<bool?> showError(
    BuildContext context, {
    String? title,
    required String content,
    String? confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.error,
        title: title ?? '错误',
        content: content,
        confirmText: confirmText,
        showCancelButton: false,
      ),
    );
  }

  /// 显示确认对话框
  static Future<bool?> showConfirm(
    BuildContext context, {
    String? title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => CustomDialog(
        type: DialogType.confirm,
        title: title ?? '确认',
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  /// 显示输入对话框
  static Future<String?> showInput(
    BuildContext context, {
    String? title,
    String? hint,
    String? initialValue,
    String? confirmText,
    String? cancelText,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    int? maxLength,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => InputDialog(
        title: title,
        hint: hint,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
      ),
    );
  }

  /// 显示列表选择对话框
  static Future<T?> showListSelection<T>(
    BuildContext context, {
    String? title,
    required List<T> items,
    required String Function(T item) titleBuilder,
    String? Function(T item)? subtitleBuilder,
    T? initialValue,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => ListSelectionDialog<T>(
        title: title,
        items: items,
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  /// 显示多选对话框
  static Future<List<T>?> showMultiSelection<T>(
    BuildContext context, {
    String? title,
    required List<T> items,
    required String Function(T item) titleBuilder,
    String? Function(T item)? subtitleBuilder,
    List<T>? initialValues,
    String? confirmText,
    String? cancelText,
  }) {
    return showDialog<List<T>>(
      context: context,
      builder: (context) => ListSelectionDialog<T>(
        title: title,
        items: items,
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        multiSelect: true,
        initialValues: initialValues,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
  }

  /// 显示底部选择对话框
  static Future<dynamic> showBottomSheet(
    BuildContext context, {
    String? title,
    required List<BottomSheetItem> items,
    bool showCancelButton = true,
    String? cancelText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BottomSheetDialog(
        title: title,
        items: items,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
      ),
    );
  }

  /// 显示加载对话框
  static void showLoading(
    BuildContext context, {
    String? message,
    bool cancellable = false,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: cancellable,
      builder: (context) => LoadingDialog(
        message: message,
        cancellable: cancellable,
        onCancel: onCancel,
      ),
    );
  }

  /// 隐藏加载对话框
  static void hideLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}