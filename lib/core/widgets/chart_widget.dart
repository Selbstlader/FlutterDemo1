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
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(
        milliseconds: widget.chartData.config.animationDuration.inMilliseconds,
      ),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
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
      child: Container(
        width: widget.width,
        height: widget.height ?? 300,
        padding: widget.padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.chartData.config.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  widget.chartData.config.title,
                  style: Theme.of(context).textTheme.titleLarge,
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
            if (widget.chartData.config.showLegend)
              _buildLegend(),
          ],
        ),
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
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: widget.chartData.config.type == ChartType.line,
              color: series.color.withOpacity(0.3),
            ),
          );
        }).toList(),
      ),
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
    final totalValue = widget.chartData.series.first.data
        .fold<double>(0, (sum, point) => sum + point.y);

    return PieChart(
      PieChartData(
        sections: widget.chartData.series.first.data.map((point) {
          final percentage = (point.y / totalValue) * 100;
          return PieChartSectionData(
            value: point.y * _animation.value,
            title: '${percentage.toStringAsFixed(1)}%',
            color: point.color ?? Colors.blue,
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: widget.chartData.series.map((series) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: series.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                series.name,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        }).toList(),
      ),
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