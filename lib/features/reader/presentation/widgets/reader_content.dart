import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../domain/entities/reader_config.dart';
import '../../domain/entities/reading_session.dart';

/// 阅读器内容组件
class ReaderContent extends StatefulWidget {
  final ReadingSession session;
  final ReaderConfig config;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onPageTurn;

  const ReaderContent({
    Key? key,
    required this.session,
    required this.config,
    this.onTap,
    this.onPageTurn,
  }) : super(key: key);

  @override
  State<ReaderContent> createState() => _ReaderContentState();
}

class _ReaderContentState extends State<ReaderContent>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.session.currentPage);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // 设置音量键监听
    if (widget.config.volumeKeyTurnPage) {
      _setupVolumeKeyListener();
    }
  }

  @override
  void didUpdateWidget(ReaderContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 当前页面改变时更新PageController
    if (widget.session.currentPage != oldWidget.session.currentPage) {
      _pageController.animateToPage(
        widget.session.currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _setupVolumeKeyListener() {
    // 这里需要实现音量键监听逻辑
    // 可以使用volume_controller或flutter_volume_controller插件
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        color: widget.config.theme.backgroundColor,
        child: SafeArea(
          child: _buildPageContent(),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (widget.config.pageMode) {
      case PageMode.slide:
        return _buildSlidePageView();
      case PageMode.curl:
        return _buildCurlPageView();
      case PageMode.fade:
        return _buildFadePageView();
      case PageMode.scroll:
        return _buildScrollView();
    }
  }

  Widget _buildSlidePageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.session.pages.length,
      onPageChanged: (page) {
        // 这里应该通知BLoC更新当前页
      },
      itemBuilder: (context, index) {
        return _buildPageText(widget.session.pages[index]);
      },
    );
  }

  Widget _buildCurlPageView() {
    // 仿真翻页效果，这里简化为滑动效果
    return _buildSlidePageView();
  }

  Widget _buildFadePageView() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _animation,
          child: _buildPageText(widget.session.currentPageContent),
        );
      },
    );
  }

  Widget _buildScrollView() {
    return SingleChildScrollView(
      child: _buildPageText(widget.session.pages.join('\n')),
    );
  }

  Widget _buildPageText(String content) {
    return Container(
      padding: widget.config.pageMargin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 章节标题
          if (widget.session.currentPage == 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                widget.session.currentChapter.title,
                style: widget.config.textStyle.copyWith(
                  fontSize: widget.config.fontSize + 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          // 正文内容
          Expanded(
            child: Text(
              content,
              style: widget.config.textStyle,
              textAlign: TextAlign.justify,
            ),
          ),
          
          // 页面信息
          if (widget.config.showStatusBar)
            Container(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.session.currentPage + 1}/${widget.session.pages.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.config.theme.textColor.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    DateTime.now().toString().substring(11, 16),
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.config.theme.textColor.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}