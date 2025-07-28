import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import 'common_app_bar.dart';

/// 占位页面 - 用于未实现的功能
class PlaceholderPage extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const PlaceholderPage({
    Key? key,
    required this.title,
    this.message = '该功能正在开发中，敬请期待',
    this.icon = Icons.construction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CommonAppBar(
        title: title,
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.primaryColor.withOpacity(0.5),
            ),
            const SizedBox(height: AppTheme.spacingLarge),
            Text(
              title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingRegular),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXLarge),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('返回'),
            ),
          ],
        ),
      ),
    );
  }
}