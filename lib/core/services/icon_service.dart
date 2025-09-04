import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../models/app_models.dart';

/// 图标服务
class IconService {
  static final IconService _instance = IconService._internal();
  factory IconService() => _instance;
  IconService._internal();

  // 图标缓存
  final Map<String, IconData> _iconCache = {};
  final Map<String, String> _svgCache = {};

  /// 初始化图标服务
  Future<void> init() async {
    _loadDefaultIcons();
  }

  /// 加载默认图标
  void _loadDefaultIcons() {
    // Material Icons
    _iconCache.addAll({
      'home': Icons.home,
      'settings': Icons.settings,
      'person': Icons.person,
      'search': Icons.search,
      'favorite': Icons.favorite,
      'star': Icons.star,
      'add': Icons.add,
      'remove': Icons.remove,
      'edit': Icons.edit,
      'delete': Icons.delete,
      'save': Icons.save,
      'cancel': Icons.cancel,
      'check': Icons.check,
      'close': Icons.close,
      'menu': Icons.menu,
      'more_vert': Icons.more_vert,
      'arrow_back': Icons.arrow_back,
      'arrow_forward': Icons.arrow_forward,
      'arrow_upward': Icons.arrow_upward,
      'arrow_downward': Icons.arrow_downward,
      'refresh': Icons.refresh,
      'share': Icons.share,
      'download': Icons.download,
      'upload': Icons.upload,
      'visibility': Icons.visibility,
      'visibility_off': Icons.visibility_off,
      'lock': Icons.lock,
      'lock_open': Icons.lock_open,
      'notifications': Icons.notifications,
      'email': Icons.email,
      'phone': Icons.phone,
      'location_on': Icons.location_on,
      'calendar_today': Icons.calendar_today,
      'access_time': Icons.access_time,
      'info': Icons.info,
      'warning': Icons.warning,
      'error': Icons.error,
      'help': Icons.help,
      'thumb_up': Icons.thumb_up,
      'thumb_down': Icons.thumb_down,
      'shopping_cart': Icons.shopping_cart,
      'payment': Icons.payment,
      'account_balance': Icons.account_balance,
      'work': Icons.work,
      'school': Icons.school,
      'local_hospital': Icons.local_hospital,
      'restaurant': Icons.restaurant,
      'hotel': Icons.hotel,
      'flight': Icons.flight,
      'directions_car': Icons.directions_car,
      'directions_bike': Icons.directions_bike,
      'directions_walk': Icons.directions_walk,
      'camera': Icons.camera,
      'photo': Icons.photo,
      'video_call': Icons.video_call,
      'music_note': Icons.music_note,
      'movie': Icons.movie,
      'games': Icons.games,
      'sports': Icons.sports,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'nature': Icons.nature,
      'wb_sunny': Icons.wb_sunny,
      'wb_cloudy': Icons.wb_cloudy,
      'beach_access': Icons.beach_access,
    });

    // Material Design Icons
    _iconCache.addAll({
      'account': MdiIcons.account,
      'account_circle': MdiIcons.accountCircle,
      'account_group': MdiIcons.accountGroup,
      'bell': MdiIcons.bell,
      'bell_outline': MdiIcons.bellOutline,
      'bookmark': MdiIcons.bookmark,
      'bookmark_outline': MdiIcons.bookmarkOutline,
      'calendar': MdiIcons.calendar,
      'calendar_blank': MdiIcons.calendarBlank,
      'chart_line': MdiIcons.chartLine,
      'chart_bar': MdiIcons.chartBar,
      'chart_pie': MdiIcons.chartPie,
      'clock': MdiIcons.clock,
      'clock_outline': MdiIcons.clockOutline,
      'cog': MdiIcons.cog,
      'cog_outline': MdiIcons.cogOutline,
      'database': MdiIcons.database,
      'database_outline': MdiIcons.databaseOutline,
      'file': MdiIcons.file,
      'file_outline': MdiIcons.fileOutline,
      'folder': MdiIcons.folder,
      'folder_outline': MdiIcons.folderOutline,
      'heart': MdiIcons.heart,
      'heart_outline': MdiIcons.heartOutline,
      'home_outline': MdiIcons.homeOutline,
      'image': MdiIcons.image,
      'image_outline': MdiIcons.imageOutline,
      'lightbulb': MdiIcons.lightbulb,
      'lightbulb_outline': MdiIcons.lightbulbOutline,
      'map': MdiIcons.map,
      'map_outline': MdiIcons.mapOutline,
      'message': MdiIcons.message,
      'message_outline': MdiIcons.messageOutline,
      'palette': MdiIcons.palette,
      'palette_outline': MdiIcons.paletteOutline,
      'shield': MdiIcons.shield,
      'shield_outline': MdiIcons.shieldOutline,
      'star_outline': MdiIcons.starOutline,
      'tag': MdiIcons.tag,
      'tag_outline': MdiIcons.tagOutline,
      'weather_sunny': MdiIcons.weatherSunny,
      'weather_cloudy': MdiIcons.weatherCloudy,
      'weather_rainy': MdiIcons.weatherRainy,
      'weather_snowy': MdiIcons.weatherSnowy,
    });


  }

  /// 获取图标
  IconData? getIcon(String name) {
    final icon = _iconCache[name];
    return icon;
  }

  /// 注册自定义图标
  void registerIcon(String name, IconData icon) {
    _iconCache[name] = icon;
  }

  /// 批量注册图标
  void registerIcons(Map<String, IconData> icons) {
    _iconCache.addAll(icons);
  }

  /// 移除图标
  void removeIcon(String name) {
    _iconCache.remove(name);
  }

  /// 获取所有图标名称
  List<String> getAllIconNames() {
    return _iconCache.keys.toList();
  }

  /// 搜索图标
  List<String> searchIcons(String query) {
    if (query.isEmpty) return getAllIconNames();
    
    final lowerQuery = query.toLowerCase();
    return _iconCache.keys
        .where((name) => name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 注册SVG图标路径
  void registerSvgIcon(String name, String assetPath) {
    _svgCache[name] = assetPath;
  }

  /// 批量注册SVG图标
  void registerSvgIcons(Map<String, String> svgIcons) {
    _svgCache.addAll(svgIcons);

  }

  /// 获取SVG图标路径
  String? getSvgIconPath(String name) {
    final path = _svgCache[name];
    return path;
  }

  /// 移除SVG图标
  void removeSvgIcon(String name) {
    _svgCache.remove(name);
  }

  /// 获取所有SVG图标名称
  List<String> getAllSvgIconNames() {
    return _svgCache.keys.toList();
  }

  /// 搜索SVG图标
  List<String> searchSvgIcons(String query) {
    if (query.isEmpty) return getAllSvgIconNames();
    
    final lowerQuery = query.toLowerCase();
    return _svgCache.keys
        .where((name) => name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 清除所有缓存
  void clearCache() {
    _iconCache.clear();
    _svgCache.clear();
  }

  /// 重新加载默认图标
  void reloadDefaultIcons() {
    clearCache();
    _loadDefaultIcons();
  }

  /// 释放资源
  void dispose() {
    clearCache();
  }
}

/// 图标组件
class AppIcon extends StatelessWidget {
  final String name;
  final IconType type;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;

  const AppIcon(
    this.name, {
    super.key,
    this.type = IconType.material,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    final iconService = IconService();
    
    switch (type) {
      case IconType.material:
        final iconData = iconService.getIcon(name);
        if (iconData == null) {
          return Icon(
            Icons.help_outline,
            size: size,
            color: color ?? Theme.of(context).colorScheme.error,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          );
        }
        return Icon(
          iconData,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
        );
        
      case IconType.svg:
        final svgPath = iconService.getSvgIconPath(name);
        if (svgPath == null) {
          return Icon(
            Icons.help_outline,
            size: size,
            color: color ?? Theme.of(context).colorScheme.error,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          );
        }
        return SvgPicture.asset(
          svgPath,
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color!, BlendMode.srcIn)
              : null,
          semanticsLabel: semanticLabel,
        );
        
      case IconType.custom:
        final iconData = iconService.getIcon(name);
        if (iconData == null) {
          return Icon(
            Icons.help_outline,
            size: size,
            color: color ?? Theme.of(context).colorScheme.error,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          );
        }
        return Icon(
          iconData,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
        );
        
      case IconType.font:
        final iconData = iconService.getIcon(name);
        if (iconData == null) {
          return Icon(
            Icons.help_outline,
            size: size,
            color: color ?? Theme.of(context).colorScheme.error,
            semanticLabel: semanticLabel,
            textDirection: textDirection,
          );
        }
        return Icon(
          iconData,
          size: size,
          color: color,
          semanticLabel: semanticLabel,
          textDirection: textDirection,
        );
    }
  }
}

/// 图标按钮组件
class AppIconButton extends StatelessWidget {
  final String iconName;
  final IconType iconType;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final bool enabled;

  const AppIconButton({
    super.key,
    required this.iconName,
    this.iconType = IconType.material,
    this.onPressed,
    this.size,
    this.color,
    this.backgroundColor,
    this.padding,
    this.tooltip,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      onPressed: enabled ? onPressed : null,
      icon: AppIcon(
        iconName,
        type: iconType,
        size: size,
        color: color,
      ),
      padding: padding ?? const EdgeInsets.all(8.0),
      tooltip: tooltip,
      style: backgroundColor != null
          ? IconButton.styleFrom(
              backgroundColor: backgroundColor,
            )
          : null,
    );

    return button;
  }
}

/// 图标选择器组件
class IconPicker extends StatefulWidget {
  final IconType type;
  final Function(String iconName)? onIconSelected;
  final String? selectedIcon;
  final double iconSize;
  final Color? iconColor;
  final int crossAxisCount;
  final bool showSearch;

  const IconPicker({
    super.key,
    this.type = IconType.material,
    this.onIconSelected,
    this.selectedIcon,
    this.iconSize = 24.0,
    this.iconColor,
    this.crossAxisCount = 4,
    this.showSearch = true,
  });

  @override
  State<IconPicker> createState() => _IconPickerState();
}

class _IconPickerState extends State<IconPicker> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredIcons = [];
  final IconService _iconService = IconService();

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _loadIcons() {
    switch (widget.type) {
      case IconType.material:
      case IconType.custom:
      case IconType.font:
        _filteredIcons = _iconService.getAllIconNames();
        break;
      case IconType.svg:
        _filteredIcons = _iconService.getAllSvgIconNames();
        break;
    }
    setState(() {});
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    switch (widget.type) {
      case IconType.material:
      case IconType.custom:
      case IconType.font:
        _filteredIcons = _iconService.searchIcons(query);
        break;
      case IconType.svg:
        _filteredIcons = _iconService.searchSvgIcons(query);
        break;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showSearch)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '搜索图标...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.crossAxisCount,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: _filteredIcons.length,
            itemBuilder: (context, index) {
              final iconName = _filteredIcons[index];
              final isSelected = widget.selectedIcon == iconName;
              
              return InkWell(
                onTap: () => widget.onIconSelected?.call(iconName),
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppIcon(
                        iconName,
                        type: widget.type,
                        size: widget.iconSize,
                        color: widget.iconColor,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        iconName,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 图标展示组件
class IconShowcase extends StatelessWidget {
  final List<String> iconNames;
  final IconType type;
  final double iconSize;
  final Color? iconColor;
  final int crossAxisCount;
  final bool showLabels;

  const IconShowcase({
    super.key,
    required this.iconNames,
    this.type = IconType.material,
    this.iconSize = 32.0,
    this.iconColor,
    this.crossAxisCount = 6,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: showLabels ? 0.8 : 1.0,
      ),
      itemCount: iconNames.length,
      itemBuilder: (context, index) {
        final iconName = iconNames[index];
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppIcon(
              iconName,
              type: type,
              size: iconSize,
              color: iconColor,
            ),
            if (showLabels) ...[  
              const SizedBox(height: 8.0),
              Text(
                iconName,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      },
    );
  }
}