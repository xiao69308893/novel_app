import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/common_app_bar.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../app/themes/app_theme.dart';
import '../blocs/bookshelf/bookshelf_bloc.dart';

/// 设置页面
class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBarUtils.simple(title: '设置'),
      body: BlocBuilder<BookshelfBloc, BookshelfState>(
        builder: (context, state) {
          if (state is BookshelfLoaded && state.user?.settings != null) {
            final settings = state.user!.settings!;
            
            return ListView(
              padding: const EdgeInsets.all(AppTheme.spacingRegular),
              children: [
                // 阅读器设置
                _buildSettingsSection(
                  context,
                  title: '阅读器设置',
                  children: [
                    _buildSliderSetting(
                      context,
                      title: '字体大小',
                      value: settings.reader.fontSize,
                      min: 12.0,
                      max: 24.0,
                      divisions: 12,
                      onChanged: (value) {
                        // 更新字体大小
                      },
                    ),
                    _buildSliderSetting(
                      context,
                      title: '行间距',
                      value: settings.reader.lineSpacing,
                      min: 1.0,
                      max: 2.5,
                      divisions: 15,
                      onChanged: (value) {
                        // 更新行间距
                      },
                    ),
                    _buildDropdownSetting(
                      context,
                      title: '阅读主题',
                      value: settings.reader.theme,
                      items: const {
                        'light': '明亮主题',
                        'dark': '暗黑主题',
                        'sepia': '护眼主题',
                      },
                      onChanged: (value) {
                        // 更新阅读主题
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '屏幕常亮',
                      subtitle: '阅读时保持屏幕常亮',
                      value: settings.reader.keepScreenOn,
                      onChanged: (value) {
                        // 更新屏幕常亮设置
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '音量键翻页',
                      subtitle: '使用音量键进行翻页',
                      value: settings.reader.volumeKeyTurnPage,
                      onChanged: (value) {
                        // 更新音量键翻页设置
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // 通知设置
                _buildSettingsSection(
                  context,
                  title: '通知设置',
                  children: [
                    _buildSwitchSetting(
                      context,
                      title: '推送通知',
                      subtitle: '接收应用推送通知',
                      value: settings.notifications.enabled,
                      onChanged: (value) {
                        // 更新推送通知设置
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '更新通知',
                      subtitle: '小说更新时通知',
                      value: settings.notifications.updateNotification,
                      onChanged: (value) {
                        // 更新更新通知设置
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '推荐通知',
                      subtitle: '接收小说推荐通知',
                      value: settings.notifications.recommendationNotification,
                      onChanged: (value) {
                        // 更新推荐通知设置
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // 隐私设置
                _buildSettingsSection(
                  context,
                  title: '隐私设置',
                  children: [
                    _buildSwitchSetting(
                      context,
                      title: '个人资料可见',
                      subtitle: '允许他人查看你的个人资料',
                      value: settings.privacy.profileVisible,
                      onChanged: (value) {
                        // 更新个人资料可见性
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '阅读记录可见',
                      subtitle: '允许他人查看你的阅读记录',
                      value: settings.privacy.readingHistoryVisible,
                      onChanged: (value) {
                        // 更新阅读记录可见性
                      },
                    ),
                    _buildSwitchSetting(
                      context,
                      title: '允许搜索',
                      subtitle: '允许其他用户搜索到你',
                      value: settings.privacy.allowSearch,
                      onChanged: (value) {
                        // 更新搜索可见性
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingLarge),
                
                // 其他设置
                _buildSettingsSection(
                  context,
                  title: '其他设置',
                  children: [
                    ListTile(
                      title: const Text('清理缓存'),
                      subtitle: const Text('清理应用缓存数据'),
                      leading: const Icon(Icons.cleaning_services_outlined),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showClearCacheDialog(context),
                    ),
                    ListTile(
                      title: const Text('检查更新'),
                      subtitle: const Text('检查应用更新'),
                      leading: const Icon(Icons.system_update_outlined),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _checkUpdate(context),
                    ),
                    ListTile(
                      title: const Text('意见反馈'),
                      subtitle: const Text('提交意见和建议'),
                      leading: const Icon(Icons.feedback_outlined),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(context, '/feedback'),
                    ),
                    ListTile(
                      title: const Text('退出登录'),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ],
            );
          }
          
          return const Center(child: Text('设置加载中...'));
        },
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusRegular),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingRegular),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchSetting(
    BuildContext context, {
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildSliderSetting(
    BuildContext context, {
    required String title,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: value.toStringAsFixed(1),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownSetting(
    BuildContext context, {
    required String title,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        items: items.entries
            .map((entry) => DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value),
                ))
            .toList(),
        onChanged: onChanged,
        underline: const SizedBox.shrink(),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('确定要清理所有缓存数据吗？清理后需要重新下载。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('缓存清理完成')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _checkUpdate(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('当前已是最新版本')),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 执行退出登录逻辑
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/auth/login',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('退出'),
          ),
        ],
      ),
    );
  }
}