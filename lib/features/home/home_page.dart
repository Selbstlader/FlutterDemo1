import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/feature_card.dart';

/// 主页面
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter 快速开发框架'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 欢迎区域
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppConstants.paddingLarge.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '欢迎使用',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingSmall.h),
                  Text(
                    'Flutter 快速开发框架',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingSmall.h),
                  Text(
                    '轻量级、高性能的Flutter开发解决方案',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppConstants.paddingLarge.h),
            
            // 功能模块标题
            Text(
              '核心功能模块',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: AppConstants.paddingMedium.h),
            
            // 功能模块网格
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMedium.w,
                mainAxisSpacing: AppConstants.paddingMedium.h,
                childAspectRatio: 1.2,
                children: [
                  FeatureCard(
                    title: '图表可视化',
                    description: '基于fl_chart的数据可视化',
                    icon: Icons.bar_chart,
                    color: Colors.blue,
                    onTap: () => context.go('/charts'),
                  ),
                  FeatureCard(
                    title: '动画系统',
                    description: '流畅的页面和组件动画',
                    icon: Icons.animation,
                    color: Colors.green,
                    onTap: () => context.go('/animations'),
                  ),
                  FeatureCard(
                    title: '图标管理',
                    description: 'Material Icons + SVG图标',
                    icon: Icons.emoji_symbols,
                    color: Colors.orange,
                    onTap: () => context.go('/icons'),
                  ),
                  FeatureCard(
                    title: 'UI组件库',
                    description: 'Material Design 3.0组件',
                    icon: Icons.widgets,
                    color: Colors.purple,
                    onTap: () => context.go('/components'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}