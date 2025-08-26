import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../app/themes/app_theme.dart';

/// 亮度控制组件
class BrightnessControl extends StatefulWidget {

  const BrightnessControl({
    super.key,
    this.initialBrightness = 0.5,
    this.onBrightnessChanged,
    this.onClose,
  });
  final double initialBrightness;
  final ValueChanged<double>? onBrightnessChanged;
  final VoidCallback? onClose;

  @override
  State<BrightnessControl> createState() => _BrightnessControlState();
}

class _BrightnessControlState extends State<BrightnessControl>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.initialBrightness;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _setBrightness(double brightness) {
    setState(() {
      _brightness = brightness;
    });
    
    // 设置系统亮度
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: 
            brightness > 0.5 ? Brightness.dark : Brightness.light,
      ),
    );
    
    widget.onBrightnessChanged?.call(brightness);
  }

  Future<void> _close() async {
    await _animationController.reverse();
    widget.onClose?.call();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: _close,
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.5),
        child: FadeTransition(
          opacity: _animation,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // 阻止点击事件传播
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(AppTheme.spacingLarge),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // 标题
                    Row(
                      children: <Widget>[
                        const Icon(Icons.brightness_6),
                        const SizedBox(width: AppTheme.spacingSmall),
                        const Text(
                          '亮度调节',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _close,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingLarge),
                    
                    // 亮度滑块
                    Row(
                      children: <Widget>[
                        const Icon(Icons.brightness_low),
                        Expanded(
                          child: Slider(
                            value: _brightness,
                            min: 0.1,
                            divisions: 9,
                            label: '${(_brightness * 100).round()}%',
                            onChanged: _setBrightness,
                          ),
                        ),
                        const Icon(Icons.brightness_high),
                      ],
                    ),
                    
                    const SizedBox(height: AppTheme.spacingRegular),
                    
                    // 快捷按钮
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        _buildQuickButton('最暗', 0.1),
                        _buildQuickButton('较暗', 0.3),
                        _buildQuickButton('适中', 0.5),
                        _buildQuickButton('较亮', 0.7),
                        _buildQuickButton('最亮', 1.0),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

  Widget _buildQuickButton(String label, double brightness) {
    final bool isSelected = (_brightness - brightness).abs() < 0.05;
    
    return GestureDetector(
      onTap: () => _setBrightness(brightness),
      child: Container(
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