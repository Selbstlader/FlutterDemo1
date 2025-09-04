import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../core/services/theme_service.dart';
import '../shared/themes/app_theme.dart';

/// 主题演示页面
class ThemeDemo extends StatefulWidget {
  const ThemeDemo({super.key});

  @override
  State<ThemeDemo> createState() => _ThemeDemoState();
}

class _ThemeDemoState extends State<ThemeDemo> {
  final ThemeService _themeService = ThemeService();
  
  // 预定义的强调色选项
  final List<Color> _accentColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.purple,
    Colors.teal,
    Colors.indigo,
    Colors.pink,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题演示'),
        elevation: 0,
      ),
      body: Watch(
        (context) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildThemeModeSection(),
              const SizedBox(height: 24),
              _buildAccentColorSection(),
              const SizedBox(height: 24),
              _buildPreviewSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建主题模式选择区域
  Widget _buildThemeModeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题模式',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...AppThemeMode.values.map((mode) {
              return RadioListTile<AppThemeMode>(
                title: Text(_getThemeModeTitle(mode)),
                subtitle: Text(_getThemeModeSubtitle(mode)),
                value: mode,
                groupValue: _themeService.themeMode.value,
                onChanged: (value) {
                  if (value != null) {
                    _themeService.setThemeMode(value);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 构建强调色选择区域
  Widget _buildAccentColorSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '强调色',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _accentColors.map((color) {
                final isSelected = _themeService.accentColor.value == color;
                return GestureDetector(
                  onTap: () => _themeService.setAccentColor(color),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 3,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color),
                            size: 24,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建主题预览区域
  Widget _buildPreviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '主题预览',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildButtonPreview(),
            const SizedBox(height: 16),
            _buildInputPreview(),
            const SizedBox(height: 16),
            _buildCardPreview(),
            const SizedBox(height: 16),
            _buildChipPreview(),
          ],
        ),
      ),
    );
  }

  /// 构建按钮预览
  Widget _buildButtonPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '按钮组件',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: const Text('Elevated Button'),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text('Outlined Button'),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Text Button'),
            ),
            FilledButton(
              onPressed: () {},
              child: const Text('Filled Button'),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建输入框预览
  Widget _buildInputPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '输入组件',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            labelText: '标准输入框',
            hintText: '请输入内容',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 8),
        const TextField(
          decoration: InputDecoration(
            labelText: '填充输入框',
            hintText: '请输入内容',
            filled: true,
            prefixIcon: Icon(Icons.email),
          ),
        ),
      ],
    );
  }

  /// 构建卡片预览
  Widget _buildCardPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '卡片组件',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: const Text('卡片标题'),
            subtitle: const Text('这是一个示例卡片，展示当前主题效果'),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建标签预览
  Widget _buildChipPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签组件',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              label: const Text('普通标签'),
              avatar: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Text('A'),
              ),
            ),
            ActionChip(
              label: const Text('操作标签'),
              onPressed: () {},
              avatar: const Icon(Icons.add),
            ),
            FilterChip(
              label: const Text('筛选标签'),
              selected: true,
              onSelected: (value) {},
            ),
            ChoiceChip(
              label: const Text('选择标签'),
              selected: false,
              onSelected: (value) {},
            ),
          ],
        ),
      ],
    );
  }

  /// 获取主题模式标题
  String _getThemeModeTitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  /// 获取主题模式副标题
  String _getThemeModeSubtitle(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '根据系统设置自动切换';
      case AppThemeMode.light:
        return '始终使用浅色主题';
      case AppThemeMode.dark:
        return '始终使用深色主题';
    }
  }

  /// 获取对比色
  Color _getContrastColor(Color color) {
    // 计算颜色亮度，选择合适的对比色
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}