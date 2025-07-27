import 'package:flutter/material.dart';
import '../../../../app/themes/app_theme.dart';
import '../../domain/entities/reader_config.dart';

/// 阅读器设置面板组件
class ReaderSettingsPanel extends StatefulWidget {
  final ReaderConfig config;
  final ValueChanged<ReaderConfig>? onConfigChanged;
  final VoidCallback? onClose;

  const ReaderSettingsPanel({
    Key? key,
    required this.config,
    this.onConfigChanged,
    this.onClose,
  }) : super(key: key);

  @override
  State<ReaderSettingsPanel> createState() => _ReaderSettingsPanelState();
}

class _ReaderSettingsPanelState extends State<ReaderSettingsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late ReaderConfig _currentConfig;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.config;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateConfig(ReaderConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
    });
    widget.onConfigChanged?.call(newConfig);
  }

  Future<void> _closePanel() async {
    await _animationController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closePanel,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: SlideTransition(
          position: _slideAnimation,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {}, // 阻止点击事件传播
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Column(
                  children: [
                    // 头部
                    _buildHeader(),
                    
                    // 设置内容
                    Expanded(
                      child: _buildSettingsContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            '阅读设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _closePanel,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingRegular),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 阅读主题
          _buildThemeSection(),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // 字体设置
          _buildFontSection(),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // 翻页设置
          _buildPageSection(),
          
          const SizedBox(height: AppTheme.spacingLarge),
          
          // 其他设置
          _buildOtherSection(),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '阅读主题',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        Row(
          children: ReaderTheme.values.map((theme) {
            final isSelected = _currentConfig.theme == theme;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _updateConfig(_currentConfig.copyWith(theme: theme));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.backgroundColor,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: theme.backgroundColor,
                          border: Border.all(color: theme.textColor),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        theme.displayName,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildFontSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '字体设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 字体大小
        _buildSliderSetting(
          label: '字体大小',
          value: _currentConfig.fontSize,
          min: 12.0,
          max: 32.0,
          divisions: 20,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(fontSize: value));
          },
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 行间距
        _buildSliderSetting(
          label: '行间距',
          value: _currentConfig.lineHeight,
          min: 1.0,
          max: 3.0,
          divisions: 20,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(lineHeight: value));
          },
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 页边距
        Row(
          children: [
            const Text('页边距'),
            const Spacer(),
            _buildMarginButton('紧凑', 12.0),
            _buildMarginButton('标准', 20.0),
            _buildMarginButton('宽松', 28.0),
          ],
        ),
      ],
    );
  }

  Widget _buildPageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '翻页设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 翻页模式
        Row(
          children: PageMode.values.map((mode) {
            final isSelected = _currentConfig.pageMode == mode;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  _updateConfig(_currentConfig.copyWith(pageMode: mode));
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    mode.displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 音量键翻页
        SwitchListTile(
          title: const Text('音量键翻页'),
          subtitle: const Text('使用音量键进行翻页'),
          value: _currentConfig.volumeKeyTurnPage,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(volumeKeyTurnPage: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildOtherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '其他设置',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: AppTheme.spacingRegular),
        
        // 屏幕常亮
        SwitchListTile(
          title: const Text('屏幕常亮'),
          subtitle: const Text('阅读时保持屏幕常亮'),
          value: _currentConfig.keepScreenOn,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(keepScreenOn: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
        
        // 显示状态栏
        SwitchListTile(
          title: const Text('显示状态栏'),
          subtitle: const Text('显示页码和时间信息'),
          value: _currentConfig.showStatusBar,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(showStatusBar: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
        
        // 全屏模式
        SwitchListTile(
          title: const Text('全屏模式'),
          subtitle: const Text('隐藏系统状态栏'),
          value: _currentConfig.fullScreenMode,
          onChanged: (value) {
            _updateConfig(_currentConfig.copyWith(fullScreenMode: value));
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSliderSetting({
    required String label,
    required double value,
    required double min,
    required double max,
    int? divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMarginButton(String label, double margin) {
    final isSelected = _currentConfig.pageMargin.left == margin;
    return GestureDetector(
      onTap: () {
        _updateConfig(_currentConfig.copyWith(
          pageMargin: EdgeInsets.all(margin),
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}