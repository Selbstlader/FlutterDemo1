import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../config/app_config.dart';
import '../services/animation_service.dart';
import '../services/auth_service.dart';
import '../../features/features.dart';
import '../../pages/demo/pages.dart' as demo;
import '../../pages/home.dart' show HomePage;
import '../../pages/auth/auth_page.dart';

/// 转场动画类型
enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
}

/// 路由路径常量
class AppRoutes {
  static const String home = '/';
  static const String demo = '/demo';
  static const String charts = '/demo/charts';
  static const String animations = '/demo/animations';
  static const String icons = '/demo/icons';
  static const String components = '/demo/components';
  static const String forms = '/demo/forms';
  static const String theme = '/demo/theme';
  static const String network = '/demo/network';
  static const String state = '/demo/state';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String profile = '/profile';
  static const String auth = '/auth';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String notFound = '/404';
}

/// 路由配置
class AppRouter {
  static final AppRouter _instance = AppRouter._internal();
  factory AppRouter() => _instance;
  AppRouter._internal();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;
  static GlobalKey<NavigatorState> get shellNavigatorKey => _shellNavigatorKey;

  late final GoRouter _router;
  GoRouter get router => _router;

  // 应用配置实例
  final AppConfig _appConfig = AppConfig.instance;

  /// 获取当前应用模式
  static AppMode get currentMode => AppConfig.currentMode;

  /// 模式变化通知器
  static ValueNotifier<AppMode> get modeNotifier => AppConfig.modeNotifier;

  /// 切换应用模式
  static void switchMode(AppMode mode) {
    AppConfig.switchMode(mode);
    // 重新初始化路由以应用新模式
    _instance._reinitializeRouter();
  }

  /// 重新初始化路由器
  void _reinitializeRouter() {
    // 保存当前路由状态
    final currentLocation =
        _router?.routerDelegate.currentConfiguration.uri.toString() ??
            AppRoutes.home;

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: currentLocation,
      debugLogDiagnostics: true,
      routes: _buildRoutes(),
      errorBuilder: (context, state) => _buildErrorPage(context, state),
      redirect: _handleRedirect,
    );

    // 通知监听器路由已重新初始化
    AppConfig.modeNotifier.notifyListeners();
  }

  /// 初始化路由
  void init() {
    // 初始化应用配置
    _appConfig.init();

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      routes: _buildRoutes(),
      errorBuilder: (context, state) => _buildErrorPage(context, state),
      redirect: _handleRedirect,
    );

    // 监听模式变化并重新初始化路由
    AppConfig.modeNotifier.addListener(() {
      _reinitializeRouter();
    });
  }

  /// 构建路由列表
  List<RouteBase> _buildRoutes() {
    return [
      // 主页路由
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          _getPageForMode('home'),
          state,
          TransitionType.fade,
        ),
      ),

      // 演示页面路由组
      GoRoute(
        path: AppRoutes.demo,
        name: 'demo',
        pageBuilder: (context, state) => _buildPageWithTransition(
          _getPageForMode('demo'),
          state,
          TransitionType.slide,
        ),
        routes: [
          // 图表演示
          GoRoute(
            path: 'charts',
            name: 'charts',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const ChartsPage(),
              state,
              TransitionType.slide,
            ),
          ),
          // 动画演示
          GoRoute(
            path: 'animations',
            name: 'animations',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const AnimationsPage(),
              state,
              TransitionType.scale,
            ),
          ),
          // 图标演示
          GoRoute(
            path: 'icons',
            name: 'icons',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const IconsPage(),
              state,
              TransitionType.slide,
            ),
          ),
          // 组件演示
          GoRoute(
            path: 'components',
            name: 'components',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const ComponentsPage(),
              state,
              TransitionType.slide,
            ),
          ),
          // 表单和表格演示
          GoRoute(
            path: 'forms',
            name: 'forms',
            pageBuilder: (context, state) => _buildPageWithTransition(
              _getPageForMode('forms'),
              state,
              TransitionType.slide,
            ),
          ),
          // 主题演示
          GoRoute(
            path: 'theme',
            name: 'theme',
            pageBuilder: (context, state) => _buildPageWithTransition(
              _getPageForMode('theme'),
              state,
              TransitionType.fade,
            ),
          ),
          // 网络演示
          GoRoute(
            path: 'network',
            name: 'network',
            pageBuilder: (context, state) => _buildPageWithTransition(
              _getPageForMode('network'),
              state,
              TransitionType.slide,
            ),
          ),
          // 状态管理演示
          GoRoute(
            path: 'state',
            name: 'state',
            pageBuilder: (context, state) => _buildPageWithTransition(
              _getPageForMode('state'),
              state,
              TransitionType.slide,
            ),
          ),
        ],
      ),

      // 设置页面
      GoRoute(
        path: AppRoutes.settings,
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          _getPageForMode('settings'),
          state,
          TransitionType.slide,
        ),
      ),

      // 关于页面
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        pageBuilder: (context, state) => _buildPageWithTransition(
          _getPageForMode('about'),
          state,
          TransitionType.fade,
        ),
      ),

      // 用户资料页面
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          _getPageForMode('profile'),
          state,
          TransitionType.slide,
        ),
      ),

      // 认证页面
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const AuthPage(),
          state,
          TransitionType.slide,
        ),
      ),
    ];
  }

  /// 根据当前模式获取对应的页面组件
  Widget _getPageForMode(String pageName) {
    switch (AppConfig.currentMode) {
      case AppMode.demo:
        // 演示模式：使用 demo 目录下的页面
        switch (pageName) {
          case 'home':
            return const demo.HomePage();
          case 'demo':
            return const demo.DemoPage();
          case 'settings':
            return const demo.SettingsPage();
          case 'about':
            return const demo.AboutPage();
          case 'profile':
            return const demo.ProfilePage();
          case 'theme':
            return const demo.ThemeDemo();
          case 'forms':
            return const demo.FormDemoPage();
          case 'network':
            return const demo.NetworkDemo();
          case 'state':
            return const demo.StateDemo();
          default:
            return const demo.DemoPage();
        }
      case AppMode.development:
        // 开发模式：使用根目录下的页面
        switch (pageName) {
          case 'home':
            return HomePage();
          default:
            return HomePage();
        }
    }
    // 默认返回值（不应该到达这里）
    return HomePage();
  }

  /// 构建带转场动画的页面
  Page<dynamic> _buildPageWithTransition(
    Widget child,
    GoRouterState state,
    TransitionType transitionType,
  ) {
    switch (transitionType) {
      case TransitionType.fade:
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        );
      case TransitionType.slide:
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      case TransitionType.scale:
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
        );
      case TransitionType.rotation:
        return CustomTransitionPage<void>(
          key: state.pageKey,
          child: child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RotationTransition(
              turns: animation,
              child: child,
            );
          },
        );
      default:
        return MaterialPage(
          key: state.pageKey,
          child: child,
        );
    }
  }

  /// 处理重定向
  /// 在开发模式下检查用户认证状态，未认证用户重定向到登录页面
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // 获取当前路由路径
    final String location = state.uri.toString();

    // 检查是否为开发模式
    if (AppConfig.currentMode == AppMode.development) {
      // 获取认证服务实例
      final AuthService authService = AuthService();

      // 检查用户是否已登录
      final bool isLoggedIn = authService.isLoggedIn;

      // 定义不需要认证的路由（认证相关页面）
      final List<String> publicRoutes = [
        AppRoutes.auth,
        AppRoutes.login,
        AppRoutes.register,
      ];

      // 检查当前路由是否为公开路由
      final bool isPublicRoute =
          publicRoutes.any((route) => location.startsWith(route));

      // 如果用户未登录且不是访问公开路由，重定向到认证页面
      if (!isLoggedIn && !isPublicRoute) {
        return AppRoutes.auth;
      }

      // 如果用户已登录且正在访问认证页面，重定向到首页
      if (isLoggedIn && isPublicRoute) {
        return AppRoutes.home;
      }
    }

    // 其他情况不重定向
    return null;
  }

  /// 构建错误页面
  Widget _buildErrorPage(BuildContext context, GoRouterState state) {
    return const NotFoundPage();
  }

  /// 导航到指定路由
  static void go(String location, {Object? extra}) {
    _instance._router.go(location, extra: extra);
  }

  /// 推送新路由
  static void push(String location, {Object? extra}) {
    _instance._router.push(location, extra: extra);
  }

  /// 替换当前路由
  static void replace(String location, {Object? extra}) {
    _instance._router.pushReplacement(location, extra: extra);
  }

  /// 返回上一页
  static void pop([Object? result]) {
    if (_instance._router.canPop()) {
      _instance._router.pop(result);
    }
  }

  /// 返回到指定路由
  static void popUntil(String location) {
    while (_instance._router.canPop() &&
        _instance._router.routerDelegate.currentConfiguration.fullPath !=
            location) {
      _instance._router.pop();
    }
  }

  /// 清空路由栈并导航到指定路由
  static void goAndClearStack(String location, {Object? extra}) {
    while (_instance._router.canPop()) {
      _instance._router.pop();
    }
    _instance._router.pushReplacement(location, extra: extra);
  }

  /// 获取当前路由信息
  static String get currentLocation {
    return _instance._router.routerDelegate.currentConfiguration.fullPath ??
        '/';
  }

  /// 检查是否可以返回
  static bool get canPop {
    return _instance._router.canPop();
  }

  /// 获取路由参数
  static Map<String, String> getPathParameters(BuildContext context) {
    return GoRouterState.of(context).pathParameters;
  }

  /// 获取查询参数
  static Map<String, String> getQueryParameters(BuildContext context) {
    return GoRouterState.of(context).uri.queryParameters;
  }

  /// 获取额外数据
  static Object? getExtra(BuildContext context) {
    return GoRouterState.of(context).extra;
  }
}

/// 路由扩展方法
extension AppRouterExtension on BuildContext {
  /// 导航到指定路由
  void go(String location, {Object? extra}) {
    AppRouter.go(location, extra: extra);
  }

  /// 推送新路由
  void pushRoute(String location, {Object? extra}) {
    AppRouter.push(location, extra: extra);
  }

  /// 替换当前路由
  void replace(String location, {Object? extra}) {
    AppRouter.replace(location, extra: extra);
  }

  /// 返回上一页
  void pop([Object? result]) {
    AppRouter.pop(result);
  }

  /// 获取路由参数
  Map<String, String> get pathParameters {
    return AppRouter.getPathParameters(this);
  }

  /// 获取查询参数
  Map<String, String> get queryParameters {
    return AppRouter.getQueryParameters(this);
  }

  /// 获取额外数据
  Object? get routeExtra {
    return AppRouter.getExtra(this);
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面未找到')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404 - 页面未找到',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '您访问的页面不存在',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
