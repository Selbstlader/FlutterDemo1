import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'storage_service.dart';

/// 应用主题模式枚举
enum AppThemeMode {
  system,
  light,
  dark,
}

/// 主题服务
class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _themeModeKey = 'theme_mode';
  static const String _customThemeKey = 'custom_theme';
  static const String _accentColorKey = 'accent_color';

  // 主题状态信号
  late final Signal<AppThemeMode> _themeMode;
  late final Signal<ThemeData> _lightTheme;
  late final Signal<ThemeData> _darkTheme;
  late final Signal<Color> _accentColor;
  late final Signal<bool> _isSystemDark;

  // Getters
  Signal<AppThemeMode> get themeMode => _themeMode;
  Signal<ThemeData> get lightTheme => _lightTheme;
  Signal<ThemeData> get darkTheme => _darkTheme;
  Signal<Color> get accentColor => _accentColor;
  Signal<bool> get isSystemDark => _isSystemDark;

  /// 初始化主题服务
  Future<void> init() async {
    // 初始化信号 - 先初始化基础信号
    _themeMode = signal(AppThemeMode.system);
    _accentColor = signal(Colors.blue);
    _isSystemDark = signal(false);

    // 然后初始化依赖于_accentColor的主题信号
    _lightTheme = signal(_createLightTheme());
    _darkTheme = signal(_createDarkTheme());

    // 从存储中加载主题设置
    await _loadThemeSettings();

    // 监听系统主题变化
    _listenToSystemTheme();
  }

  /// 加载主题设置
  Future<void> _loadThemeSettings() async {
    try {
      // 加载主题模式
      final themeModeString = await StorageService.getString(_themeModeKey);
      if (themeModeString != null) {
        final mode = AppThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => AppThemeMode.system,
        );
        _themeMode.value = mode;
      }

      // 加载强调色
      final accentColorValue = await StorageService.getInt(_accentColorKey);
      if (accentColorValue != null) {
        _accentColor.value = Color(accentColorValue);
        _updateThemes();
      }
    } catch (e) {}
  }

  /// 监听系统主题变化
  void _listenToSystemTheme() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isSystemDark.value = brightness == Brightness.dark;

    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      final newBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _isSystemDark.value = newBrightness == Brightness.dark;
    };
  }

  /// 设置主题模式
  Future<void> setThemeMode(AppThemeMode mode) async {
    try {
      _themeMode.value = mode;
      await StorageService.setString(_themeModeKey, mode.toString());
    } catch (e) {}
  }

  /// 设置强调色
  Future<void> setAccentColor(Color color) async {
    try {
      _accentColor.value = color;
      await StorageService.setInt(_accentColorKey, color.value);
      _updateThemes();
    } catch (e) {}
  }

  /// 更新主题
  void _updateThemes() {
    _lightTheme.value = _createLightTheme();
    _darkTheme.value = _createDarkTheme();
  }

  /// 创建浅色主题
  ThemeData _createLightTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentColor.value,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        elevation: 8,
      ),
    );
  }

  /// 创建深色主题
  ThemeData _createDarkTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _accentColor.value,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: colorScheme.surface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
        elevation: 8,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primaryContainer,
        elevation: 3,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        elevation: 8,
      ),
    );
  }

  /// 获取当前有效主题
  ThemeData getCurrentTheme() {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return _lightTheme.value;
      case AppThemeMode.dark:
        return _darkTheme.value;
      case AppThemeMode.system:
        return _isSystemDark.value ? _darkTheme.value : _lightTheme.value;
    }
  }

  /// 获取当前是否为深色主题
  bool isDarkMode() {
    switch (_themeMode.value) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return _isSystemDark.value;
    }
  }

  /// 切换主题模式
  Future<void> toggleThemeMode() async {
    final currentMode = _themeMode.value;
    AppThemeMode newMode;

    switch (currentMode) {
      case AppThemeMode.system:
        newMode = AppThemeMode.light;
        break;
      case AppThemeMode.light:
        newMode = AppThemeMode.dark;
        break;
      case AppThemeMode.dark:
        newMode = AppThemeMode.system;
        break;
    }

    await setThemeMode(newMode);
  }

  /// 预设颜色
  static const List<Color> presetColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.lime,
    Colors.brown,
  ];

  /// 重置为默认主题
  Future<void> resetToDefault() async {
    await setThemeMode(AppThemeMode.system);
    await setAccentColor(Colors.blue);
  }

  /// 导出主题配置
  Map<String, dynamic> exportThemeConfig() {
    return {
      'themeMode': _themeMode.value.toString(),
      'accentColor': _accentColor.value.value,
    };
  }

  /// 导入主题配置
  Future<void> importThemeConfig(Map<String, dynamic> config) async {
    try {
      if (config.containsKey('themeMode')) {
        final themeModeString = config['themeMode'] as String;
        final mode = AppThemeMode.values.firstWhere(
          (e) => e.toString() == themeModeString,
          orElse: () => AppThemeMode.system,
        );
        await setThemeMode(mode);
      }

      if (config.containsKey('accentColor')) {
        final colorValue = config['accentColor'] as int;
        await setAccentColor(Color(colorValue));
      }
    } catch (e) {}
  }

  /// 释放资源
  void dispose() {
    // 清理平台亮度监听器
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        null;
  }
}

/// 主题切换组件
class ThemeToggleButton extends StatelessWidget {
  final double? size;
  final Color? color;
  final String? tooltip;

  const ThemeToggleButton({
    super.key,
    this.size,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();

    return Watch((context) {
      final isDark = themeService.isDarkMode();
      final mode = themeService.themeMode.value;

      IconData icon;
      String tooltipText;

      switch (mode) {
        case AppThemeMode.system:
          icon = Icons.brightness_auto;
          tooltipText = '跟随系统';
          break;
        case AppThemeMode.light:
          icon = Icons.brightness_7;
          tooltipText = '浅色模式';
          break;
        case AppThemeMode.dark:
          icon = Icons.brightness_4;
          tooltipText = '深色模式';
          break;
      }

      return IconButton(
        onPressed: () => themeService.toggleThemeMode(),
        icon: Icon(
          icon,
          size: size,
          color: color,
        ),
        tooltip: tooltip ?? tooltipText,
      );
    });
  }
}

/// 颜色选择器组件
class ColorPicker extends StatelessWidget {
  final Function(Color)? onColorSelected;
  final Color? selectedColor;
  final List<Color>? colors;
  final double colorSize;
  final int crossAxisCount;

  const ColorPicker({
    super.key,
    this.onColorSelected,
    this.selectedColor,
    this.colors,
    this.colorSize = 40.0,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final colorList = colors ?? ThemeService.presetColors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: colorList.length,
      itemBuilder: (context, index) {
        final color = colorList[index];
        final isSelected = selectedColor == color;

        return GestureDetector(
          onTap: () => onColorSelected?.call(color),
          child: Container(
            width: colorSize,
            height: colorSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.onSurface
                    : Colors.transparent,
                width: 3.0,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    size: colorSize * 0.5,
                  )
                : null,
          ),
        );
      },
    );
  }
}
