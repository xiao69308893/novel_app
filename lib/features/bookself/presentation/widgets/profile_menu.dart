import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';

/// 个人中心菜单组件
class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingRegular),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _buildMenuItem(
            context,
            icon: Icons.person_outline,
            title: '个人资料',
            subtitle: '编辑个人信息',
            onTap: () => Navigator.pushNamed(context, '/profile/edit'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.settings_outlined,
            title: '设置',
            subtitle: '阅读器、通知等设置',
            onTap: () => Navigator.pushNamed(context, '/profile/settings'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.bookmark_outline,
            title: '我的书签',
            subtitle: '查看所有书签',
            onTap: () => Navigator.pushNamed(context, '/profile/bookmarks'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.download_outlined,
            title: '缓存管理',
            subtitle: '管理离线缓存',
            onTap: () => Navigator.pushNamed(context, '/profile/cache'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.assessment_outlined,
            title: '阅读统计',
            subtitle: '详细阅读数据',
            onTap: () => Navigator.pushNamed(context, '/profile/stats'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '使用帮助和问题反馈',
            onTap: () => Navigator.pushNamed(context, '/profile/help'),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Icons.info_outline,
            title: '关于',
            subtitle: '版本信息',
            onTap: () => Navigator.pushNamed(context, '/profile/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final ThemeData theme = Theme.of(context);
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? theme.primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? theme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() => const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
    );
}
