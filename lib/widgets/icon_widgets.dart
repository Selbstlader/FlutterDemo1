import 'package:flutter/material.dart';
import '../core/services/icon_service.dart';

/// 图标组件集合
class IconWidgets {
  /// 创建带动画的图标
  static Widget animatedIcon({
    required IconData icon,
    required Color color,
    double size = 24.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.8, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Icon(
            icon,
            color: color,
            size: size,
          ),
        );
      },
    );
  }

  /// 创建带背景的图标
  static Widget iconWithBackground({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    double size = 24.0,
    double padding = 8.0,
    BorderRadius? borderRadius,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: size,
      ),
    );
  }

  /// 创建图标按钮
  static Widget iconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
    double size = 24.0,
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, size: size),
      color: color,
      onPressed: onPressed,
      tooltip: tooltip,
    );
  }
}

/// 图标展示组件
class IconShowcase extends StatelessWidget {
  final List<IconData> iconNames;
  final double iconSize;
  final Color? iconColor;
  final Function(IconData)? onIconTap;

  const IconShowcase({
    super.key,
    required this.iconNames,
    this.iconSize = 32.0,
    this.iconColor,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: iconNames.map((iconData) {
        return GestureDetector(
          onTap: () => onIconTap?.call(iconData),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              iconData,
              size: iconSize,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 图标网格组件
class IconGrid extends StatelessWidget {
  final List<IconData> icons;
  final int crossAxisCount;
  final double iconSize;
  final Function(IconData)? onIconTap;

  const IconGrid({
    super.key,
    required this.icons,
    this.crossAxisCount = 4,
    this.iconSize = 32.0,
    this.onIconTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: icons.length,
      itemBuilder: (context, index) {
        final icon = icons[index];
        return GestureDetector(
          onTap: () => onIconTap?.call(icon),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Icon(
              icon,
              size: iconSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      },
    );
  }
}