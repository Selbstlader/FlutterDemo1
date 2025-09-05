import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/models/auth_models.dart';
import '../core/models/chart_models.dart';
import '../core/widgets/ui_components.dart';
import '../core/widgets/chart_widget.dart';
import '../core/widgets/form_components.dart';
import 'dart:math' as math;

/// 开发模式首页
/// 包含多种图表展示和数据列表的综合首页
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据仪表板'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息展示区域
            _buildUserInfoSection(),
            const SizedBox(height: 24),

            // 第一行图表：折线图和柱状图
            _buildChartRow([
              _createLineChartData(),
              _createBarChartData(),
            ]),
            const SizedBox(height: 16),

            // 第二行图表：饼图和散点图
            _buildChartRow([
              _createPieChartData(),
              _createScatterChartData(),
            ]),
            const SizedBox(height: 16),

            // 第三行：全宽度折线图
            _buildFullWidthChart(_createFullWidthLineChartData()),
            const SizedBox(height: 24),

            // 底部列表组件
            _buildDataList(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息展示区域
  Widget _buildUserInfoSection() {
    return Watch((context) {
      final authState = _authService.authState.value;

      if (authState.status != AuthStatus.authenticated ||
          authState.profile == null) {
        return const SizedBox.shrink();
      }

      final profile = authState.profile!;

      return Container(
        width: double.infinity,
        child: AppCard(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.0),
          elevation: 2,
          child: Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 30,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '欢迎回来！',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .onPrimaryContainer
                            .withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.displayName ?? profile.username ?? '用户',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (profile.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        profile.email!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 登出按钮
              IconButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: '退出登录',
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建图表行布局
  Widget _buildChartRow(List<ChartData> chartDataList) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 在小屏幕上使用垂直布局，大屏幕上使用水平布局
        final isSmallScreen = constraints.maxWidth < 800;

        if (isSmallScreen) {
          // 小屏幕：垂直排列
          return Column(
            children: chartDataList.asMap().entries.map((entry) {
              final index = entry.key;
              final chartData = entry.value;
              return Container(
                width: double.infinity,
                margin: EdgeInsets.only(
                  bottom: index < chartDataList.length - 1 ? 16.0 : 0,
                ),
                child: AppCard(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ChartWidget(
                    chartData: chartData,
                    height: 280,
                  ),
                ),
              );
            }).toList(),
          );
        } else {
          // 大屏幕：水平排列
          return Row(
            children: chartDataList.asMap().entries.map((entry) {
              final index = entry.key;
              final chartData = entry.value;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < chartDataList.length - 1 ? 8.0 : 0,
                  ),
                  child: AppCard(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: ChartWidget(
                      chartData: chartData,
                      height: 250,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  /// 构建全宽度图表
  Widget _buildFullWidthChart(ChartData chartData) {
    return AppCard(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: ChartWidget(
        chartData: chartData,
        height: 300,
      ),
    );
  }

  /// 构建数据列表
  Widget _buildDataList(BuildContext context) {
    final items = _generateListData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '数据概览',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        AppCard(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          child: AppTable(
            columns: [
              AppTableColumn(
                key: 'indicator',
                title: '指标',
                builder: (value) {
                  final item = value as Map<String, dynamic>;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: item['color'] as Color,
                        child: Icon(
                          item['icon'] as IconData,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            item['subtitle'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
              AppTableColumn(
                key: 'value',
                title: '数值',
                builder: (value) {
                  final item = value as Map<String, dynamic>;
                  return Text(
                    item['value'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              AppTableColumn(
                key: 'change',
                title: '变化',
                builder: (value) {
                  final item = value as Map<String, dynamic>;
                  final change = item['change'] as String;
                  return Text(
                    change,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: change.startsWith('+') ? Colors.green : Colors.red,
                    ),
                  );
                },
              ),
            ],
            data: items
                .map((item) => {
                      'indicator': item,
                      'value': item,
                      'change': item,
                    })
                .toList(),
            // padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// 创建折线图数据
  ChartData _createLineChartData() {
    final random = math.Random();
    final data = List.generate(12, (index) {
      return DataPoint(
        x: index.toDouble(),
        y: 20 + random.nextDouble() * 60,
        label: '${index + 1}月',
      );
    });

    return ChartData(
      id: 'line_chart_1',
      config: const ChartConfig(
        title: '月度销售趋势',
        type: ChartType.line,
        showLegend: false,
        showGrid: true,
      ),
      series: [
        ChartSeries(
          id: 'sales',
          name: '销售额',
          data: data,
          color: Colors.blue,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 创建柱状图数据
  ChartData _createBarChartData() {
    final categories = ['产品A', '产品B', '产品C', '产品D', '产品E'];
    final random = math.Random();
    final data = categories.asMap().entries.map((entry) {
      return DataPoint(
        x: entry.key.toDouble(),
        y: 10 + random.nextDouble() * 40,
        label: entry.value,
      );
    }).toList();

    return ChartData(
      id: 'bar_chart_1',
      config: const ChartConfig(
        title: '产品销量对比',
        type: ChartType.bar,
        showLegend: false,
        showGrid: true,
      ),
      series: [
        ChartSeries(
          id: 'products',
          name: '销量',
          data: data,
          color: Colors.green,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 创建饼图数据
  ChartData _createPieChartData() {
    final data = [
      DataPoint(x: 0, y: 35, label: '移动端', color: Colors.blue),
      DataPoint(x: 1, y: 28, label: '桌面端', color: Colors.green),
      DataPoint(x: 2, y: 22, label: '平板端', color: Colors.orange),
      DataPoint(x: 3, y: 15, label: '其他', color: Colors.purple),
    ];

    return ChartData(
      id: 'pie_chart_1',
      config: const ChartConfig(
        title: '访问设备分布',
        type: ChartType.pie,
        showLegend: true,
        showGrid: false,
      ),
      series: [
        ChartSeries(
          id: 'devices',
          name: '设备类型',
          data: data,
          color: Colors.blue,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 创建散点图数据
  ChartData _createScatterChartData() {
    final random = math.Random();
    final data = List.generate(20, (index) {
      return DataPoint(
        x: random.nextDouble() * 100,
        y: random.nextDouble() * 100,
        label: '数据点${index + 1}',
      );
    });

    return ChartData(
      id: 'scatter_chart_1',
      config: const ChartConfig(
        title: '用户行为分析',
        type: ChartType.scatter,
        showLegend: false,
        showGrid: true,
      ),
      series: [
        ChartSeries(
          id: 'behavior',
          name: '用户行为',
          data: data,
          color: Colors.red,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 创建全宽度折线图数据
  ChartData _createFullWidthLineChartData() {
    final random = math.Random();
    final series1Data = List.generate(30, (index) {
      return DataPoint(
        x: index.toDouble(),
        y: 50 + math.sin(index * 0.2) * 20 + random.nextDouble() * 10,
        label: '第${index + 1}天',
      );
    });

    final series2Data = List.generate(30, (index) {
      return DataPoint(
        x: index.toDouble(),
        y: 40 + math.cos(index * 0.15) * 15 + random.nextDouble() * 8,
        label: '第${index + 1}天',
      );
    });

    return ChartData(
      id: 'full_width_line_chart',
      config: const ChartConfig(
        title: '30天数据趋势对比',
        type: ChartType.line,
        showLegend: true,
        showGrid: true,
      ),
      series: [
        ChartSeries(
          id: 'series1',
          name: '访问量',
          data: series1Data,
          color: Colors.blue,
        ),
        ChartSeries(
          id: 'series2',
          name: '转化率',
          data: series2Data,
          color: Colors.orange,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 生成列表数据
  List<Map<String, dynamic>> _generateListData() {
    final random = math.Random();
    return [
      {
        'title': '总收入',
        'subtitle': '本月累计收入',
        'value':
            '¥${(random.nextDouble() * 100000 + 50000).toStringAsFixed(0)}',
        'change': '+${(random.nextDouble() * 20 + 5).toStringAsFixed(1)}%',
        'icon': Icons.attach_money,
        'color': Colors.green,
      },
      {
        'title': '新用户',
        'subtitle': '本月新增用户数',
        'value': '${(random.nextDouble() * 5000 + 1000).toStringAsFixed(0)}',
        'change': '+${(random.nextDouble() * 15 + 3).toStringAsFixed(1)}%',
        'icon': Icons.person_add,
        'color': Colors.blue,
      },
      {
        'title': '订单量',
        'subtitle': '本月总订单数',
        'value': '${(random.nextDouble() * 2000 + 500).toStringAsFixed(0)}',
        'change': '+${(random.nextDouble() * 25 + 8).toStringAsFixed(1)}%',
        'icon': Icons.shopping_cart,
        'color': Colors.orange,
      },
      {
        'title': '转化率',
        'subtitle': '访问转化率',
        'value': '${(random.nextDouble() * 10 + 2).toStringAsFixed(1)}%',
        'change': '-${(random.nextDouble() * 5 + 1).toStringAsFixed(1)}%',
        'icon': Icons.trending_up,
        'color': Colors.purple,
      },
      {
        'title': '活跃用户',
        'subtitle': '日活跃用户数',
        'value': '${(random.nextDouble() * 10000 + 3000).toStringAsFixed(0)}',
        'change': '+${(random.nextDouble() * 12 + 2).toStringAsFixed(1)}%',
        'icon': Icons.people,
        'color': Colors.teal,
      },
    ];
  }
}
