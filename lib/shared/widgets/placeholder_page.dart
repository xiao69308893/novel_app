import 'package:flutter/material.dart';
import '../../app/themes/app_theme.dart';
import 'common_app_bar.dart';

/// 占位页面 - 用于未实现的功能
class PlaceholderPage extends StatelessWidget {

  const PlaceholderPage({
    required this.title, super.key,
    this.message = '该功能正在开发中，敬请期待',
    this.icon = Icons.construction,
  });
  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    
    return Scaffold(
      appBar: CommonAppBar(
        title: title,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 80,
              color: theme.primaryColor.withValues(alpha: 0.5),
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