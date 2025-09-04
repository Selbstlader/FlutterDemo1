import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/theme_service.dart';
import '../../core/widgets/ui_components.dart';
import '../../core/widgets/chart_widget.dart';
import '../../core/router/app_router.dart';
import '../../widgets/animation_widgets.dart';
import '../../widgets/icon_widgets.dart';
import 'package:signals/signals_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildContent(context),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        _buildWelcomeSection(context),
        _buildFeaturesGrid(context),
        _buildQuickActions(context),
        _buildFooter(context),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Flutter 快速开发框架',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Watch((context) {
          return IconButton(
            icon: Icon(
              ThemeService().isDarkMode() ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              ThemeService().toggleThemeMode();
            },
            tooltip: '切换主题',
          );
        }),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {
            context.push(AppRoutes.settings);
          },
          tooltip: '设置',
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '欢迎使用',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '这是一个基于 Flutter 的快速开发框架，集成了状态管理、网络请求、图表可视化、动画系统等常用功能模块。',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFeatureChip(context, '响应式状态管理', Icons.memory),
                  _buildFeatureChip(context, '图表可视化', Icons.bar_chart),
                  _buildFeatureChip(context, '动画系统', Icons.animation),
                  _buildFeatureChip(context, 'UI组件库', Icons.widgets),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label, IconData icon) {
    return Chip(
      avatar: Icon(
        icon,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      backgroundColor:
          Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      side: BorderSide.none,
    );
  }

  Widget _buildFeaturesGrid(BuildContext context) {
    final features = [
      FeatureItem(
        title: '图表演示',
        subtitle: '各种图表类型展示',
        icon: Icons.bar_chart,
        color: Colors.blue,
        route: AppRoutes.charts,
      ),
      FeatureItem(
        title: '动画效果',
        subtitle: '页面转场和组件动画',
        icon: Icons.animation,
        color: Colors.purple,
        route: AppRoutes.animations,
      ),
      FeatureItem(
        title: '图标管理',
        subtitle: 'Material Icons 和 SVG',
        icon: Icons.emoji_symbols,
        color: Colors.orange,
        route: AppRoutes.icons,
      ),
      FeatureItem(
        title: 'UI组件',
        subtitle: 'Material Design 3.0',
        icon: Icons.widgets,
        color: Colors.green,
        route: AppRoutes.components,
      ),
      FeatureItem(
        title: '主题系统',
        subtitle: '深色/浅色主题切换',
        icon: Icons.palette,
        color: Colors.pink,
        route: AppRoutes.theme,
      ),
      FeatureItem(
        title: '网络请求',
        subtitle: 'HTTP 客户端封装',
        icon: Icons.cloud,
        color: Colors.cyan,
        route: AppRoutes.network,
      ),
      FeatureItem(
        title: '状态管理',
        subtitle: 'Signals 响应式状态',
        icon: Icons.memory,
        color: Colors.indigo,
        route: AppRoutes.state,
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final feature = features[index];
            return _buildFeatureCard(context, feature, index);
          },
          childCount: features.length,
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, FeatureItem feature, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: AppCard(
            onTap: () {
              context.push(feature.route);
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: feature.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature.icon,
                    color: feature.color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  feature.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  feature.subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '快速操作',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '查看演示',
                      icon: Icon(Icons.play_arrow),
                      onPressed: () {
                        context.push(AppRoutes.demo);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: '关于框架',
                      type: ButtonType.secondary,
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        context.push(AppRoutes.about);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Flutter 快速开发框架',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
  });
}
