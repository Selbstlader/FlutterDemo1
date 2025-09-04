import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/themes/app_theme.dart';

/// 图表展示页面
class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});
  
  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  int selectedIndex = 0;
  
  final List<String> chartTypes = ['折线图', '柱状图', '饼图', '散点图'];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图表可视化'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 图表类型选择
          Container(
            height: 60.h,
            padding: EdgeInsets.symmetric(horizontal: AppConstants.paddingMedium.w),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: chartTypes.length,
              itemBuilder: (context, index) {
                final isSelected = selectedIndex == index;
                return Padding(
                  padding: EdgeInsets.only(right: AppConstants.paddingSmall.w),
                  child: FilterChip(
                    label: Text(chartTypes[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          
          // 图表展示区域
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingMedium.w),
                  child: _buildChart(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChart() {
    switch (selectedIndex) {
      case 0:
        return _buildLineChart();
      case 1:
        return _buildBarChart();
      case 2:
        return _buildPieChart();
      case 3:
        return _buildScatterChart();
      default:
        return _buildLineChart();
    }
  }
  
  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(2.6, 2),
              FlSpot(4.9, 5),
              FlSpot(6.8, 3.1),
              FlSpot(8, 4),
              FlSpot(9.5, 3),
              FlSpot(11, 4),
            ],
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 20,
        barTouchData: BarTouchData(enabled: false),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: AppTheme.chartColors[0])]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 10, color: AppTheme.chartColors[1])]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 14, color: AppTheme.chartColors[2])]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 15, color: AppTheme.chartColors[3])]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 13, color: AppTheme.chartColors[4])]),
        ],
      ),
    );
  }
  
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(
            color: AppTheme.chartColors[0],
            value: 40,
            title: '40%',
            radius: 60,
          ),
          PieChartSectionData(
            color: AppTheme.chartColors[1],
            value: 30,
            title: '30%',
            radius: 60,
          ),
          PieChartSectionData(
            color: AppTheme.chartColors[2],
            value: 15,
            title: '15%',
            radius: 60,
          ),
          PieChartSectionData(
            color: AppTheme.chartColors[3],
            value: 15,
            title: '15%',
            radius: 60,
          ),
        ],
        sectionsSpace: 2,
        centerSpaceRadius: 40,
      ),
    );
  }
  
  Widget _buildScatterChart() {
    return ScatterChart(
      ScatterChartData(
        scatterSpots: [
          ScatterSpot(1, 2, color: AppTheme.chartColors[0]),
          ScatterSpot(2, 3, color: AppTheme.chartColors[1]),
          ScatterSpot(3, 1, color: AppTheme.chartColors[2]),
          ScatterSpot(4, 4, color: AppTheme.chartColors[3]),
          ScatterSpot(5, 2.5, color: AppTheme.chartColors[4]),
          ScatterSpot(6, 3.5, color: AppTheme.chartColors[0]),
          ScatterSpot(7, 1.5, color: AppTheme.chartColors[1]),
        ],
        minX: 0,
        maxX: 8,
        minY: 0,
        maxY: 5,
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        gridData: const FlGridData(show: true),
      ),
    );
  }
}