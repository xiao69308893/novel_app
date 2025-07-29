// 首页主页面
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/themes/app_theme.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../domain/entities/home_config.dart';
import '../../data/datasources/home_local_datasource.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_banner.dart';
import '../widgets/home_section.dart';
import '../widgets/novel_grid.dart';
import '../widgets/novel_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // 延迟加载首页数据，避免与其他初始化冲突
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 先初始化模拟数据（仅在开发环境）
      try {
        print('开始初始化模拟数据...');
        final localDataSource = HomeLocalDataSourceImpl();
        await localDataSource.initMockData();
        print('模拟数据初始化完成');
      } catch (e) {
        print('初始化模拟数据时出错: $e');
      }
      
      // 加载首页数据
      context.read<HomeCubit>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: CommonAppBar(
        title: '小说阅读',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/book/search');
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 打开通知页面
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading) {
            return const LoadingWidget();
          } else if (state is HomeError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<HomeCubit>().loadHomeData(),
            );
          } else if (state is HomeLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HomeCubit>().refreshHomeData(),
              child: _buildHomeContent(state),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeContent(HomeLoaded state) {
    return CustomScrollView(
      slivers: [
        // 轮播图
        if (state.banners.isNotEmpty)
          SliverToBoxAdapter(
            child: HomeBanner(banners: state.banners),
          ),

        // 功能区块
        SliverToBoxAdapter(
          child: _buildFunctionSection(),
        ),

        // 动态构建内容区块
        ...state.config.visibleSections.map((section) {
          return _buildSection(section, state);
        }).toList(),
      ],
    );
  }

  Widget _buildFunctionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFunctionItem(
            icon: Icons.trending_up,
            title: '排行榜',
            onTap: () => Navigator.pushNamed(context, '/book/ranking'),
          ),
          _buildFunctionItem(
            icon: Icons.category,
            title: '分类',
            onTap: () => Navigator.pushNamed(context, '/book/category'),
          ),
          _buildFunctionItem(
            icon: Icons.library_books,
            title: '书架',
            onTap: () => Navigator.pushNamed(context, '/bookshelf'),
          ),
          _buildFunctionItem(
            icon: Icons.history,
            title: '历史',
            onTap: () => Navigator.pushNamed(context, '/reading-history'),
          ),
        ],
      ),
    );
  }

  Widget _buildFunctionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
            ),
            child: Icon(
              icon,
              color: theme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(HomeSection section, HomeLoaded state) {
    switch (section.type) {
      case 'recommendation':
        final recommendations = state.recommendations
            .where((r) => r.type.name == section.config['type'])
            .toList();
        
        if (recommendations.isNotEmpty) {
          return SliverToBoxAdapter(
            child: HomeSectionWidget(
              title: section.title,
              novels: recommendations.first.novels,
              onMoreTap: () {
                // TODO: 跳转到更多页面
              },
            ),
          );
        }
        break;
        
      case 'ranking':
        // TODO: 实现排行榜区块
        break;
        
      case 'category':
        // TODO: 实现分类区块
        break;
    }
    
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}