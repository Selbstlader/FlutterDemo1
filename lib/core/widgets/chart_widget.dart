import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/chart_models.dart';

/// 通用图表组件
class ChartWidget extends StatefulWidget {
  final ChartData chartData;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final VoidCallback? onTap;

  const ChartWidget({
    super.key,
    required this.chartData,
    this.width,
    this.height,
    this.padding,
    this.onTap,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  int _touchedIndex = -1; // 记录被触摸的扇形索引

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 主动画 - 用于数值增长
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );

    // 缩放动画 - 用于入场效果
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    // 旋转动画 - 用于饼图旋转入场
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));

    if (widget.chartData.config.animate) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 根据可用空间调整内边距
          final isSmallSpace = constraints.maxWidth < 300;
          final padding =
              widget.padding ?? EdgeInsets.all(isSmallSpace ? 8 : 16);

          return Container(
            width: widget.width,
            height: widget.height ?? 300,
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.chartData.config.title.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: isSmallSpace ? 8 : 16),
                    child: Text(
                      widget.chartData.config.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: isSmallSpace ? 16 : null,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildChart();
                    },
                  ),
                ),
                if (widget.chartData.config.showLegend) _buildLegend(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart() {
    switch (widget.chartData.config.type) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.pie:
        return _buildPieChart();
      case ChartType.scatter:
        return _buildScatterChart();
      case ChartType.radar:
        return _buildLineChart(); // 雷达图暂时使用折线图实现
      default:
        return const Center(
          child: Text('不支持的图表类型'),
        );
    }
  }

  Widget _buildLineChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallChart = constraints.maxWidth < 300;

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: widget.chartData.config.showGrid,
              drawVerticalLine: true,
              drawHorizontalLine: true,
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: !isSmallChart,
                  reservedSize: isSmallChart ? 20 : 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: isSmallChart ? 8 : 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: !isSmallChart,
                  reservedSize: isSmallChart ? 25 : 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        fontSize: isSmallChart ? 8 : 10,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
            lineBarsData: widget.chartData.series.map((series) {
              return LineChartBarData(
                spots: series.data.map((point) {
                  return FlSpot(point.x, point.y * _animation.value);
                }).toList(),
                isCurved: true,
                color: series.color,
                barWidth: isSmallChart ? 2 : 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: !isSmallChart,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: isSmallChart ? 2 : 3,
                      color: series.color,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: widget.chartData.config.type == ChartType.line,
                  color: series.color.withOpacity(0.3),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(
          show: widget.chartData.config.showGrid,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final Map<double, List<DataPoint>> groupedData = {};

    // 按x值分组数据点
    for (final series in widget.chartData.series) {
      for (final point in series.data) {
        groupedData.putIfAbsent(point.x, () => []).add(point);
      }
    }

    return groupedData.entries.map((entry) {
      final x = entry.key;
      final points = entry.value;

      return BarChartGroupData(
        x: x.toInt(),
        barRods: points.asMap().entries.map((pointEntry) {
          final index = pointEntry.key;
          final point = pointEntry.value;

          return BarChartRodData(
            toY: point.y * _animation.value,
            color: point.color ?? widget.chartData.series[index].color,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          );
        }).toList(),
      );
    }).toList();
  }

  Widget _buildPieChart() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalValue = widget.chartData.series.first.data
            .fold<double>(0, (sum, point) => sum + point.y);

        // 计算可用空间，考虑内边距
        final padding = 32.0; // 预留边距
        final availableWidth = constraints.maxWidth - padding;
        final availableHeight = constraints.maxHeight - padding;
        final availableSize = availableWidth < availableHeight 
            ? availableWidth 
            : availableHeight;
        
        // 自适应计算饼图参数
        final radius = (availableSize * 0.35).clamp(30.0, 100.0);
        final centerRadius = (radius * 0.4).clamp(12.0, 40.0);
        final fontSize = availableSize < 200 ? 9.0 : (availableSize < 300 ? 11.0 : 12.0);
        final sectionsSpace = availableSize < 200 ? 0.5 : 1.5;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PieChart(
                    PieChartData(
                      sections: widget.chartData.series.first.data
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final point = entry.value;
                        final percentage = (point.y / totalValue) * 100;
                        final animatedValue = point.y * _animation.value;
                        final isTouched = index == _touchedIndex;

                        // 为每个扇形添加渐变色和阴影效果
                        final baseColor =
                            point.color ?? _getDefaultPieColor(index);
                        final displayColor = isTouched
                            ? _getHighlightColor(baseColor)
                            : baseColor
                                .withOpacity((0.9 + (_animation.value * 0.1)).clamp(0.0, 1.0));

                        return PieChartSectionData(
                          value: animatedValue,
                          title: _animation.value > 0.8
                              ? '${percentage.toStringAsFixed(1)}%'
                              : '',
                          color: displayColor,
                          radius: (isTouched ? radius + (radius * 0.1) : radius) +
                              (_animation.value * (radius * 0.08)), // 触摸时按比例扩大半径
                          titleStyle: TextStyle(
                            fontSize: isTouched ? fontSize + 2 : fontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                offset: const Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          titlePositionPercentageOffset: 0.6,
                          borderSide: BorderSide(
                            color: isTouched
                                ? Colors.white
                                : Colors.white.withOpacity(0.8),
                            width: isTouched
                                ? (availableSize < 200 ? 2 : 3)
                                : (availableSize < 200 ? 1 : 2),
                          ),
                        );
                      }).toList(),
                      sectionsSpace: sectionsSpace,
                      centerSpaceRadius: centerRadius,
                      startDegreeOffset:
                          -90 + (_rotationAnimation.value * 360), // 旋转入场动画
                      centerSpaceColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      // 添加触摸回调
                      pieTouchData: PieTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchedIndex = -1;
                              return;
                            }
                            _touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                    ),
                  ),
                  // 中心显示总数
                  if (centerRadius > 30) // 只在有足够空间时显示
                    AnimatedOpacity(
                      opacity: _animation.value > 0.7 ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '总计',
                            style: TextStyle(
                              fontSize: availableSize < 200 ? 10 : 12,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            (totalValue * _animation.value).toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: availableSize < 200 ? 14 : 18,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 获取默认饼图颜色 - 使用更现代的配色方案
  Color _getDefaultPieColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // 靛蓝
      const Color(0xFF10B981), // 翠绿
      const Color(0xFFF59E0B), // 琥珀
      const Color(0xFFEF4444), // 红色
      const Color(0xFF8B5CF6), // 紫色
      const Color(0xFF06B6D4), // 青色
      const Color(0xFFEC4899), // 粉色
      const Color(0xFF84CC16), // 青柠
      const Color(0xFFF97316), // 橙色
      const Color(0xFF6B7280), // 灰色
    ];
    return colors[index % colors.length];
  }

  // 获取高亮颜色
  Color _getHighlightColor(Color baseColor) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
  }

  Widget _buildScatterChart() {
    return ScatterChart(
      ScatterChartData(
        gridData: FlGridData(
          show: widget.chartData.config.showGrid,
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
        scatterSpots: widget.chartData.series
            .expand((series) => series.data)
            .map((point) {
          return ScatterSpot(
            point.x,
            point.y * _animation.value,
            color: point.color ?? Colors.blue,
            radius: 6,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAreaChart() {
    return _buildLineChart(); // 区域图基于折线图实现
  }

  Widget _buildLegend() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallSpace = constraints.maxWidth < 300;

        return Padding(
          padding: EdgeInsets.only(top: isSmallSpace ? 8 : 16),
          child: Wrap(
            spacing: isSmallSpace ? 8 : 16,
            runSpacing: isSmallSpace ? 4 : 8,
            children: widget.chartData.series.map((series) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: isSmallSpace ? 8 : 12,
                    height: isSmallSpace ? 8 : 12,
                    decoration: BoxDecoration(
                      color: series.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: isSmallSpace ? 2 : 4),
                  Flexible(
                    child: Text(
                      series.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: isSmallSpace ? 10 : null,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// 图表工厂类
class ChartFactory {
  /// 创建折线图数据
  static ChartData createLineChart({
    required String title,
    required List<ChartSeries> series,
    bool showGrid = true,
    bool showLegend = true,
    bool enableAnimation = true,
  }) {
    return ChartData(
      id: 'line_chart_${DateTime.now().millisecondsSinceEpoch}',
      config: ChartConfig(
        title: title,
        type: ChartType.line,
        showGrid: showGrid,
        showLegend: showLegend,
        animate: enableAnimation,
      ),
      series: series,
      createdAt: DateTime.now(),
    );
  }

  /// 创建柱状图数据
  static ChartData createBarChart({
    required String title,
    required List<ChartSeries> series,
    bool showGrid = true,
    bool showLegend = true,
    bool enableAnimation = true,
  }) {
    return ChartData(
      id: 'bar_chart_${DateTime.now().millisecondsSinceEpoch}',
      config: ChartConfig(
        title: title,
        type: ChartType.bar,
        showGrid: showGrid,
        showLegend: showLegend,
        animate: enableAnimation,
      ),
      series: series,
      createdAt: DateTime.now(),
    );
  }

  /// 创建饼图数据
  static ChartData createPieChart({
    required String title,
    required List<DataPoint> dataPoints,
    bool showLegend = true,
    bool enableAnimation = true,
  }) {
    return ChartData(
      id: 'pie_chart_${DateTime.now().millisecondsSinceEpoch}',
      config: ChartConfig(
        title: title,
        type: ChartType.pie,
        showGrid: false,
        showLegend: showLegend,
        animate: enableAnimation,
      ),
      series: [
        ChartSeries(
          id: 'pie_series',
          name: 'Data',
          data: dataPoints,
          color: Colors.blue,
        ),
      ],
      createdAt: DateTime.now(),
    );
  }

  /// 创建散点图数据
  static ChartData createScatterChart({
    required String title,
    required List<ChartSeries> series,
    bool showGrid = true,
    bool showLegend = true,
    bool enableAnimation = true,
  }) {
    return ChartData(
      id: 'scatter_chart_${DateTime.now().millisecondsSinceEpoch}',
      config: ChartConfig(
        title: title,
        type: ChartType.scatter,
        showGrid: showGrid,
        showLegend: showLegend,
        animate: enableAnimation,
      ),
      series: series,
      createdAt: DateTime.now(),
    );
  }

  /// 创建面积图数据
  static ChartData createAreaChart({
    required String title,
    required List<ChartSeries> series,
    bool showGrid = true,
    bool showLegend = true,
    bool enableAnimation = true,
  }) {
    return ChartData(
      id: 'area_chart_${DateTime.now().millisecondsSinceEpoch}',
      config: ChartConfig(
        title: title,
        type: ChartType.line,
        showGrid: showGrid,
        showLegend: showLegend,
        animate: enableAnimation,
      ),
      series: series,
      createdAt: DateTime.now(),
    );
  }
}
