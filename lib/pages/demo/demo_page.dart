import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ui_components.dart';
import '../../core/router/app_router.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _animationController.forward();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
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
      appBar: AppBar(
        title: const Text('功能演示'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildHeader(context),
        _buildDemoGrid(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.science,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '功能演示中心',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '探索框架的各项功能特性，包括图表可视化、动画效果、UI组件、主题系统等。每个演示都包含详细的代码示例和使用说明。',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoGrid(BuildContext context) {
    final demos = [
      DemoItem(
        title: '图表可视化',
        description: '展示各种类型的图表组件，包括折线图、柱状图、饼图等',
        icon: Icons.bar_chart,
        color: Colors.blue,
        route: AppRoutes.charts,
        features: ['折线图', '柱状图', '饼图', '散点图'],
      ),
      DemoItem(
        title: '动画效果',
        description: '演示页面转场动画、组件动画和加载动画效果',
        icon: Icons.animation,
        color: Colors.purple,
        route: AppRoutes.animations,
        features: ['页面转场', '组件动画', '加载动画', 'Rive动画'],
      ),
      DemoItem(
        title: '图标管理',
        description: 'Material Icons 和 SVG 图标的统一管理和使用',
        icon: Icons.emoji_symbols,
        color: Colors.orange,
        route: AppRoutes.icons,
        features: ['Material Icons', 'SVG图标', '图标搜索', '图标选择器'],
      ),
      DemoItem(
        title: 'UI组件库',
        description: '基于 Material Design 3.0 的完整组件库',
        icon: Icons.widgets,
        color: Colors.green,
        route: AppRoutes.components,
        features: ['按钮组件', '输入框', '卡片', '对话框'],
      ),
      DemoItem(
        title: '主题系统',
        description: '深色/浅色主题切换和自定义主题配置',
        icon: Icons.palette,
        color: Colors.pink,
        route: AppRoutes.theme,
        features: ['主题切换', '颜色配置', '主题导出', '动态主题'],
      ),
      DemoItem(
        title: '网络请求',
        description: '基于 Dio 的 HTTP 客户端封装和错误处理',
        icon: Icons.cloud,
        color: Colors.cyan,
        route: AppRoutes.network,
        features: ['GET请求', 'POST请求', '文件上传', '错误处理'],
      ),
      DemoItem(
        title: '状态管理',
        description: '基于 Signals 的响应式状态管理系统',
        icon: Icons.memory,
        color: Colors.indigo,
        route: AppRoutes.state,
        features: ['Signal状态', 'Computed计算', 'Effect副作用', '状态持久化'],
      ),
      DemoItem(
        title: '表单和表格',
        description: '移动端友好的表单组件和数据展示组件',
        icon: Icons.table_chart,
        color: Colors.teal,
        route: AppRoutes.forms,
        features: ['表单验证', '数据表格', '搜索筛选', '卡片列表'],
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final demo = demos[index];
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 50 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: _buildDemoCard(context, demo),
                  ),
                );
              },
            );
          },
          childCount: demos.length,
        ),
      ),
    );
  }

  Widget _buildDemoCard(BuildContext context, DemoItem demo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        onTap: () {
          context.push(demo.route);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: demo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    demo.icon,
                    color: demo.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demo.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        demo.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: demo.features.map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: demo.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: demo.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 12,
                      color: demo.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final List<String> features;

  const DemoItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.features,
  });
}
