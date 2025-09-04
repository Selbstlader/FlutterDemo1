import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// 使用barrel文件统一导入，类似Vue的@符号效果
import '../services/animation_service.dart';
import '../../features/features.dart';
import '../../pages/demo/pages.dart';

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
  static const String theme = '/demo/theme';
  static const String network = '/demo/network';
  static const String state = '/demo/state';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String profile = '/profile';
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

  /// 初始化路由
  void init() {
    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AppRoutes.home,
      debugLogDiagnostics: true,
      routes: _buildRoutes(),
      errorBuilder: (context, state) => _buildErrorPage(context, state),
      redirect: _handleRedirect,
    );
  }

  /// 构建路由列表
  List<RouteBase> _buildRoutes() {
    return [
      // 主页路由
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const HomePage(),
          state,
          TransitionType.fade,
        ),
      ),

      // 演示页面路由组
      GoRoute(
        path: AppRoutes.demo,
        name: 'demo',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const DemoPage(),
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
          // 主题演示
          GoRoute(
            path: 'theme',
            name: 'theme',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const ThemeDemo(),
              state,
              TransitionType.fade,
            ),
          ),
          // 网络演示
          GoRoute(
            path: 'network',
            name: 'network',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const NetworkDemo(),
              state,
              TransitionType.slide,
            ),
          ),
          // 状态管理演示
          GoRoute(
            path: 'state',
            name: 'state',
            pageBuilder: (context, state) => _buildPageWithTransition(
              const StateDemo(),
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
          const SettingsPage(),
          state,
          TransitionType.slide,
        ),
      ),

      // 关于页面
      GoRoute(
        path: AppRoutes.about,
        name: 'about',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const AboutPage(),
          state,
          TransitionType.fade,
        ),
      ),

      // 用户资料页面
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => _buildPageWithTransition(
          const ProfilePage(),
          state,
          TransitionType.slide,
        ),
      ),
    ];
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
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // 这里可以添加认证检查、权限验证等逻辑
    return null; // 不重定向
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
