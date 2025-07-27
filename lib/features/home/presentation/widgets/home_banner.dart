// 首页轮播图组件
import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../domain/entities/banner.dart';

class HomeBanner extends StatefulWidget {
  final List<Banner> banners;

  const HomeBanner({
    Key? key,
    required this.banners,
  }) : super(key: key);

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    
    // 自动播放
    if (widget.banners.length > 1) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        final nextIndex = (_currentIndex + 1) % widget.banners.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        _startAutoPlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 180,
      margin: const EdgeInsets.all(AppTheme.spacingRegular),
      child: Stack(
        children: [
          // 轮播图
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return _buildBannerItem(widget.banners[index]);
            },
          ),
          
          // 指示器
          if (widget.banners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: _buildIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(Banner banner) {
    return GestureDetector(
      onTap: () => _handleBannerTap(banner),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
          image: DecorationImage(
            image: NetworkImage(banner.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
              ],
            ),
          ),
          padding: const EdgeInsets.all(AppTheme.spacingRegular),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTheme.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (banner.subtitle != null)
                Text(
                  banner.subtitle!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppTheme.fontSizeSmall,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.banners.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = index == _currentIndex;
        
        return Container(
          width: isActive ? 16 : 8,
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }).toList(),
    );
  }

  void _handleBannerTap(Banner banner) {
    switch (banner.type) {
      case BannerType.novel:
        if (banner.targetId != null) {
          Navigator.pushNamed(
            context,
            '/novel/detail',
            arguments: {'novelId': banner.targetId},
          );
        }
        break;
      case BannerType.external:
        if (banner.targetUrl != null) {
          // TODO: 打开外部链接
        }
        break;
      default:
        // TODO: 处理其他类型
        break;
    }
  }
}