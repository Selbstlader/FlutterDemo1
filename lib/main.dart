import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals_flutter.dart';
import 'core/services/state_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/network_service.dart';
import 'core/services/animation_service.dart';
import 'core/services/icon_service.dart';
import 'core/router/app_router.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化核心服务
  await _initializeServices();

  // 设置系统UI样式
  _setupSystemUI();

  runApp(const MyApp());
}

/// 初始化所有核心服务
Future<void> _initializeServices() async {
  try {
    // 初始化存储服务
    await StorageService.init();

    // 初始化状态管理服务
    StateService();

    // 初始化主题服务
    await ThemeService().init();

    // 初始化网络服务
    NetworkService.init(
      baseUrl: 'https://api.example.com',
    );

    // 初始化动画服务
    AnimationService.init();

    // 初始化图标服务
    await IconService().init();

    // 初始化路由
    AppRouter().init();
  } catch (e, stackTrace) {
    rethrow;
  }
}

/// 设置系统UI样式
void _setupSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 设置首选方向（可选）
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final themeService = ThemeService();
      final currentTheme = themeService.getCurrentTheme();
      final isDarkMode = themeService.isDarkMode();

      return MaterialApp.router(
        title: 'Flutter 快速开发框架',
        debugShowCheckedModeBanner: false,

        // 主题配置
        theme: themeService.lightTheme.value,
        darkTheme: themeService.darkTheme.value,
        themeMode: _getThemeMode(themeService.themeMode.value),

        // 路由配置
        routerConfig: AppRouter().router,

        // 本地化配置
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: const Locale('zh', 'CN'),
        supportedLocales: const [
          Locale('zh', 'CN'),
          Locale('en', 'US'),
        ],

        // 构建器配置
        builder: (context, child) {
          // 设置 NetworkService 的 BuildContext
          NetworkService.setContext(context);
          
          return ScreenUtilInit(
            designSize: const Size(375, 812), // 设计稿尺寸
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MediaQuery(
                // 禁用系统字体缩放
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child ?? const SizedBox.shrink(),
              );
            },
            child: child,
          );
        },
      );
    });
  }

  /// 转换主题模式
  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// 应用生命周期管理
class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        _cleanup();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  /// 应用清理
  void _cleanup() {
    try {
      // 清理状态管理
      StateService().disposeAll();

      // 清理动画服务
      AnimationService.dispose();

      // 清理网络服务
      NetworkService.dispose();

      // 清理主题服务
      ThemeService().dispose();

      // 清理存储服务
      StorageService.dispose();

      // 清理图标服务
      IconService().dispose();
    } catch (e, stackTrace) {
      // 静默处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
