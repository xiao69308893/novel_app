import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../app/themes/app_theme.dart';
import '../blocs/bookshelf/bookshelf_bloc.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';
import '../widgets/profile_menu.dart';

/// 个人中心页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 加载用户信息
    context.read<BookshelfBloc>().add(const LoadUserProfile());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarUtils.simple(
        title: '个人中心',
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/profile/settings');
            },
          ),
        ],
      ),
      body: BlocBuilder<BookshelfBloc, BookshelfState>(
        builder: (context, state) {
          if (state is BookshelfLoading) {
            return const LoadingWidget(message: '正在加载个人信息...');
          }

          if (state is BookshelfError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: AppTheme.spacingRegular),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingRegular),
                  ElevatedButton(
                    onPressed: () {
                      context.read<BookshelfBloc>().add(const LoadUserProfile());
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            );
          }

          if (state is BookshelfLoaded && state.user != null) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<BookshelfBloc>().add(const LoadUserProfile());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 用户信息头部
                    ProfileHeader(user: state.user!),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    // 用户统计
                    if (state.user!.stats != null)
                      ProfileStats(stats: state.user!.stats!),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    // 功能菜单
                    const ProfileMenu(),
                    
                    // 底部安全区域
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}