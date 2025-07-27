import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/themes/app_theme.dart';

/// 通用AppBar组件
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题
  final String? title;
  
  /// 标题组件
  final Widget? titleWidget;
  
  /// 是否显示返回按钮
  final bool showBackButton;
  
  /// 自定义返回按钮
  final Widget? backButton;
  
  /// 返回按钮回调
  final VoidCallback? onBackPressed;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 前景颜色
  final Color? foregroundColor;
  
  /// 阴影高度
  final double? elevation;
  
  /// 是否居中显示标题
  final bool centerTitle;
  
  /// 底部组件
  final PreferredSizeWidget? bottom;
  
  /// 系统状态栏样式
  final SystemUiOverlayStyle? systemOverlayStyle;
  
  /// 是否透明背景
  final bool transparent;
  
  /// 标题样式
  final TextStyle? titleStyle;
  
  /// 工具栏高度
  final double? toolbarHeight;

  const CommonAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.backButton,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
    this.systemOverlayStyle,
    this.transparent = false,
    this.titleStyle,
    this.toolbarHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    
    return AppBar(
      title: titleWidget ?? _buildTitle(context),
      leading: _buildLeading(context),
      actions: actions,
      backgroundColor: transparent 
          ? Colors.transparent 
          : backgroundColor ?? appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? appBarTheme.foregroundColor,
      elevation: transparent ? 0 : elevation ?? appBarTheme.elevation,
      centerTitle: centerTitle,
      bottom: bottom,
      systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(context),
      toolbarHeight: toolbarHeight ?? AppTheme.appBarHeight,
      automaticallyImplyLeading: false, // 我们自己控制leading
    );
  }

  /// 构建标题
  Widget? _buildTitle(BuildContext context) {
    if (title == null) return null;
    
    return Text(
      title!,
      style: titleStyle ?? Theme.of(context).appBarTheme.titleTextStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 构建左侧按钮
  Widget? _buildLeading(BuildContext context) {
    if (!showBackButton) return null;
    
    if (backButton != null) return backButton;
    
    final canPop = Navigator.canPop(context);
    if (!canPop) return null;
    
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: onBackPressed ?? () => Navigator.pop(context),
      tooltip: '返回',
    );
  }

  /// 获取系统状态栏样式
  SystemUiOverlayStyle _getSystemOverlayStyle(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    if (transparent) {
      return brightness == Brightness.light
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light;
    }
    
    return brightness == Brightness.light
        ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
        : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent);
  }

  @override
  Size get preferredSize {
    final baseHeight = toolbarHeight ?? AppTheme.appBarHeight;
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(baseHeight + bottomHeight);
  }
}

/// 搜索AppBar
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// 搜索提示文本
  final String? hintText;
  
  /// 初始搜索文本
  final String? initialText;
  
  /// 搜索回调
  final ValueChanged<String>? onSearch;
  
  /// 搜索文本变化回调
  final ValueChanged<String>? onChanged;
  
  /// 是否自动获取焦点
  final bool autofocus;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 返回按钮回调
  final VoidCallback? onBackPressed;

  const SearchAppBar({
    Key? key,
    this.hintText,
    this.initialText,
    this.onSearch,
    this.onChanged,
    this.autofocus = false,
    this.actions,
    this.backgroundColor,
    this.onBackPressed,
  }) : super(key: key);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);
}

class _SearchAppBarState extends State<SearchAppBar> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _focusNode = FocusNode();
    
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      backgroundColor: widget.backgroundColor ?? theme.appBarTheme.backgroundColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
      ),
      title: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(
          hintText: widget.hintText ?? '搜索...',
          border: InputBorder.none,
          hintStyle: TextStyle(
            color: theme.appBarTheme.foregroundColor?.withOpacity(0.6),
          ),
        ),
        style: TextStyle(
          color: theme.appBarTheme.foregroundColor,
          fontSize: AppTheme.fontSizeMedium,
        ),
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSearch,
      ),
      actions: [
        if (_controller.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
              _focusNode.requestFocus();
            },
          ),
        ...?widget.actions,
      ],
    );
  }
}

/// 标签页AppBar
class TabAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题
  final String? title;
  
  /// 标签控制器
  final TabController tabController;
  
  /// 标签列表
  final List<Widget> tabs;
  
  /// 是否可滚动
  final bool isScrollable;
  
  /// 指示器颜色
  final Color? indicatorColor;
  
  /// 标签颜色
  final Color? labelColor;
  
  /// 未选中标签颜色
  final Color? unselectedLabelColor;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 返回按钮回调
  final VoidCallback? onBackPressed;

  const TabAppBar({
    Key? key,
    this.title,
    required this.tabController,
    required this.tabs,
    this.isScrollable = false,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.actions,
    this.backgroundColor,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppBar(
      title: title != null ? Text(title!) : null,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
      bottom: TabBar(
        controller: tabController,
        tabs: tabs,
        isScrollable: isScrollable,
        indicatorColor: indicatorColor ?? theme.primaryColor,
        labelColor: labelColor ?? theme.primaryColor,
        unselectedLabelColor: unselectedLabelColor ?? 
            theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: AppTheme.fontSizeMedium,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(AppTheme.appBarHeight + kTextTabBarHeight);
  }
}

/// 渐变AppBar
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 标题
  final String? title;
  
  /// 标题组件
  final Widget? titleWidget;
  
  /// 渐变色列表
  final List<Color> gradientColors;
  
  /// 渐变开始位置
  final Alignment gradientBegin;
  
  /// 渐变结束位置
  final Alignment gradientEnd;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 是否显示返回按钮
  final bool showBackButton;
  
  /// 返回按钮回调
  final VoidCallback? onBackPressed;
  
  /// 是否居中显示标题
  final bool centerTitle;

  const GradientAppBar({
    Key? key,
    this.title,
    this.titleWidget,
    required this.gradientColors,
    this.gradientBegin = Alignment.centerLeft,
    this.gradientEnd = Alignment.centerRight,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: gradientBegin,
          end: gradientEnd,
        ),
      ),
      child: AppBar(
        title: titleWidget ?? (title != null ? Text(title!) : null),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: centerTitle,
        leading: showBackButton && Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: onBackPressed ?? () => Navigator.pop(context),
              )
            : null,
        actions: actions,
        foregroundColor: Colors.white,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(AppTheme.appBarHeight);
}

/// 可折叠AppBar
class CollapsibleAppBar extends StatelessWidget {
  /// 展开高度
  final double expandedHeight;
  
  /// 背景图片
  final Widget? background;
  
  /// 标题
  final String? title;
  
  /// 标题组件
  final Widget? titleWidget;
  
  /// 是否固定在顶部
  final bool pinned;
  
  /// 是否浮动
  final bool floating;
  
  /// 是否捕捉
  final bool snap;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 前景颜色
  final Color? foregroundColor;

  const CollapsibleAppBar({
    Key? key,
    this.expandedHeight = 200.0,
    this.background,
    this.title,
    this.titleWidget,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      snap: snap,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      actions: actions,
      flexibleSpace: FlexibleSpaceBar(
        title: titleWidget ?? (title != null ? Text(title!) : null),
        background: background,
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
      ),
    );
  }
}

/// AppBar工具类
class AppBarUtils {
  /// 创建简单的AppBar
  static PreferredSizeWidget simple({
    required String title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CommonAppBar(
      title: title,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }

  /// 创建搜索AppBar
  static PreferredSizeWidget search({
    String? hintText,
    String? initialText,
    ValueChanged<String>? onSearch,
    ValueChanged<String>? onChanged,
    bool autofocus = false,
    VoidCallback? onBackPressed,
  }) {
    return SearchAppBar(
      hintText: hintText,
      initialText: initialText,
      onSearch: onSearch,
      onChanged: onChanged,
      autofocus: autofocus,
      onBackPressed: onBackPressed,
    );
  }

  /// 创建透明AppBar
  static PreferredSizeWidget transparent({
    String? title,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return CommonAppBar(
      title: title,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
      transparent: true,
    );
  }

  /// 创建渐变AppBar
  static PreferredSizeWidget gradient({
    String? title,
    required List<Color> colors,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) {
    return GradientAppBar(
      title: title,
      gradientColors: colors,
      actions: actions,
      onBackPressed: onBackPressed,
      showBackButton: showBackButton,
    );
  }
}