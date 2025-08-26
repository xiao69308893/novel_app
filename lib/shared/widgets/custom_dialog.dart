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

  const CustomDialog({
    super.key,
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
  });
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
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
      children: <Widget>[
        if (icon != null) ...<Widget>[
          icon!,
          const SizedBox(width: AppTheme.spacingRegular),
        ] else if (type != DialogType.custom) ...<Widget>[
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
    
    final List<Widget> buttons = <Widget>[];
    
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

  const LoadingDialog({
    super.key,
    this.message,
    this.cancellable = false,
    this.onCancel,
  });
  /// 加载文本
  final String? message;
  
  /// 是否可以取消
  final bool cancellable;
  
  /// 取消回调
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) => WillPopScope(
      onWillPop: () async => cancellable,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const CircularProgressIndicator(),
            if (message != null) ...<Widget>[
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
            ? <Widget>[
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ]
            : null,
      ),
    );
}

/// 输入对话框
class InputDialog extends StatefulWidget {

  const InputDialog({
    super.key,
    this.title,
    this.hint,
    this.initialValue,
    this.confirmText,
    this.cancelText,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
  });
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

  @override
  State<InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<InputDialog> {
  late TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
    Theme.of(context);
    
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
      actions: <Widget>[
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
      final String? error = widget.validator!(_controller.text);
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

  const ListSelectionDialog({
    required this.items, required this.titleBuilder, super.key,
    this.title,
    this.subtitleBuilder,
    this.initialValue,
    this.multiSelect = false,
    this.initialValues,
    this.confirmText,
    this.cancelText,
  });
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

  @override
  State<ListSelectionDialog<T>> createState() => _ListSelectionDialogState<T>();
}

class _ListSelectionDialogState<T> extends State<ListSelectionDialog<T>> {
  T? _selectedItem;
  final Set<T> _selectedItems = <T>{};

  @override
  void initState() {
    super.initState();
    if (widget.multiSelect) {
      _selectedItems.addAll(widget.initialValues ?? <T>[]);
    } else {
      _selectedItem = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: widget.title != null ? Text(widget.title!) : null,
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = widget.items[index];
            return _buildListItem(item);
          },
        ),
      ),
      actions: <Widget>[
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

  Widget _buildListItem(T item) {
    if (widget.multiSelect) {
      return CheckboxListTile(
        title: Text(widget.titleBuilder(item)),
        subtitle: widget.subtitleBuilder != null
            ? Text(widget.subtitleBuilder!(item) ?? '')
            : null,
        value: _selectedItems.contains(item),
        onChanged: (bool? selected) {
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

  const BottomSheetDialog({
    required this.items, super.key,
    this.title,
    this.showCancelButton = true,
    this.cancelText,
  });
  /// 标题
  final String? title;
  
  /// 选项列表
  final List<BottomSheetItem> items;
  
  /// 是否显示取消按钮
  final bool showCancelButton;
  
  /// 取消按钮文本
  final String? cancelText;

  @override
  Widget build(BuildContext context) => DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusMedium),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (title != null) ...<Widget>[
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey[300]!,
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
          ...items.map((BottomSheetItem item) => _buildItem(context, item)),
          
          if (showCancelButton) ...<Widget>[
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

  Widget _buildItem(BuildContext context, BottomSheetItem item) => ListTile(
      leading: item.icon,
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      onTap: () {
        Navigator.of(context).pop(item.value);
        item.onTap?.call();
      },
    );
}

/// 底部选择对话框选项
class BottomSheetItem {

  const BottomSheetItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.value,
    this.onTap,
  });
  final String title;
  final String? subtitle;
  final Widget? icon;
  final dynamic value;
  final VoidCallback? onTap;
}

/// 对话框工具类
class DialogUtils {
  /// 显示信息对话框
  static Future<bool?> showInfo(
    BuildContext context, {
    required String content, String? title,
    String? confirmText,
    bool showCancelButton = false,
  }) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: title ?? '提示',
        content: content,
        confirmText: confirmText,
        showCancelButton: showCancelButton,
      ),
    );

  /// 显示成功对话框
  static Future<bool?> showSuccess(
    BuildContext context, {
    required String content, String? title,
    String? confirmText,
  }) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.success,
        title: title ?? '成功',
        content: content,
        confirmText: confirmText,
        showCancelButton: false,
      ),
    );

  /// 显示警告对话框
  static Future<bool?> showWarning(
    BuildContext context, {
    required String content, String? title,
    String? confirmText,
    String? cancelText,
  }) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.warning,
        title: title ?? '警告',
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

  /// 显示错误对话框
  static Future<bool?> showError(
    BuildContext context, {
    required String content, String? title,
    String? confirmText,
  }) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.error,
        title: title ?? '错误',
        content: content,
        confirmText: confirmText,
        showCancelButton: false,
      ),
    );

  /// 显示确认对话框
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String content, String? title,
    String? confirmText,
    String? cancelText,
  }) => showDialog<bool>(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.confirm,
        title: title ?? '确认',
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

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
  }) => showDialog<String>(
      context: context,
      builder: (BuildContext context) => InputDialog(
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

  /// 显示列表选择对话框
  static Future<T?> showListSelection<T>(
    BuildContext context, {
    required List<T> items, required String Function(T item) titleBuilder, String? title,
    String? Function(T item)? subtitleBuilder,
    T? initialValue,
    String? confirmText,
    String? cancelText,
  }) => showDialog<T>(
      context: context,
      builder: (BuildContext context) => ListSelectionDialog<T>(
        title: title,
        items: items,
        titleBuilder: titleBuilder,
        subtitleBuilder: subtitleBuilder,
        initialValue: initialValue,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );

  /// 显示多选对话框
  static Future<List<T>?> showMultiSelection<T>(
    BuildContext context, {
    required List<T> items, required String Function(T item) titleBuilder, String? title,
    String? Function(T item)? subtitleBuilder,
    List<T>? initialValues,
    String? confirmText,
    String? cancelText,
  }) => showDialog<List<T>>(
      context: context,
      builder: (BuildContext context) => ListSelectionDialog<T>(
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

  /// 显示底部选择对话框
  static Future<dynamic> showBottomSheet(
    BuildContext context, {
    required List<BottomSheetItem> items, String? title,
    bool showCancelButton = true,
    String? cancelText,
  }) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => BottomSheetDialog(
        title: title,
        items: items,
        showCancelButton: showCancelButton,
        cancelText: cancelText,
      ),
    );

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
      builder: (BuildContext context) => LoadingDialog(
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