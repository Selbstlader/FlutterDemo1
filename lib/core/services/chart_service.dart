import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../models/chart_models.dart';

/// 图表服务
class ChartService {
  static final ChartService _instance = ChartService._internal();
  factory ChartService() => _instance;
  ChartService._internal();

  // 图表数据存储
  final Map<String, Signal<ChartData?>> _charts = {};

  // 图表加载状态
  final Map<String, Signal<bool>> _loadingStates = {};

  // 图表错误状态
  final Map<String, Signal<String?>> _errorStates = {};

  /// 获取图表数据信号
  Signal<ChartData?> getChartSignal(String chartId) {
    return _charts.putIfAbsent(chartId, () => signal<ChartData?>(null));
  }

  /// 获取图表加载状态信号
  Signal<bool> getLoadingSignal(String chartId) {
    return _loadingStates.putIfAbsent(chartId, () => signal(false));
  }

  /// 获取图表错误状态信号
  Signal<String?> getErrorSignal(String chartId) {
    return _errorStates.putIfAbsent(chartId, () => signal<String?>(null));
  }

  /// 设置图表数据
  void setChartData(String chartId, ChartData chartData) {
    try {
      final chartSignal = getChartSignal(chartId);
      chartSignal.value = chartData;

      // 清除错误状态
      final errorSignal = getErrorSignal(chartId);
      errorSignal.value = null;
    } catch (e) {
      setChartError(chartId, '设置图表数据失败: $e');
    }
  }

  /// 设置图表加载状态
  void setChartLoading(String chartId, bool loading) {
    final loadingSignal = getLoadingSignal(chartId);
    loadingSignal.value = loading;
  }

  /// 设置图表错误状态
  void setChartError(String chartId, String error) {
    final errorSignal = getErrorSignal(chartId);
    errorSignal.value = error;

    // 停止加载状态
    setChartLoading(chartId, false);
  }

  /// 更新图表数据点
  void updateChartDataPoint(
    String chartId,
    String seriesId,
    int pointIndex,
    DataPoint newPoint,
  ) {
    try {
      final chartSignal = getChartSignal(chartId);
      final currentData = chartSignal.value;

      if (currentData == null) {
        throw Exception('Chart data not found for $chartId');
      }

      final seriesIndex = currentData.series.indexWhere(
        (series) => series.id == seriesId,
      );

      if (seriesIndex == -1) {
        throw Exception('Series $seriesId not found in chart $chartId');
      }

      final series = currentData.series[seriesIndex];
      if (pointIndex < 0 || pointIndex >= series.data.length) {
        throw Exception('Invalid point index $pointIndex for series $seriesId');
      }

      // 创建新的数据点列表
      final newDataPoints = List<DataPoint>.from(series.data);
      newDataPoints[pointIndex] = newPoint;

      // 创建新的系列
      final newSeries = series.copyWith(data: newDataPoints);

      // 创建新的系列列表
      final newSeriesList = List<ChartSeries>.from(currentData.series);
      newSeriesList[seriesIndex] = newSeries;

      // 创建新的图表数据
      final newChartData = currentData.copyWith(series: newSeriesList);

      chartSignal.value = newChartData;
    } catch (e) {
      setChartError(chartId, '更新图表数据点失败: $e');
    }
  }

  /// 添加数据点到系列
  void addDataPointToSeries(
    String chartId,
    String seriesId,
    DataPoint dataPoint,
  ) {
    try {
      final chartSignal = getChartSignal(chartId);
      final currentData = chartSignal.value;

      if (currentData == null) {
        throw Exception('Chart data not found for $chartId');
      }

      final seriesIndex = currentData.series.indexWhere(
        (series) => series.id == seriesId,
      );

      if (seriesIndex == -1) {
        throw Exception('Series $seriesId not found in chart $chartId');
      }

      final series = currentData.series[seriesIndex];

      // 创建新的数据点列表
      final newDataPoints = List<DataPoint>.from(series.data)..add(dataPoint);

      // 创建新的系列
      final newSeries = series.copyWith(data: newDataPoints);

      // 创建新的系列列表
      final newSeriesList = List<ChartSeries>.from(currentData.series);
      newSeriesList[seriesIndex] = newSeries;

      // 创建新的图表数据
      final newChartData = currentData.copyWith(series: newSeriesList);

      chartSignal.value = newChartData;
    } catch (e) {
      setChartError(chartId, '添加数据点失败: $e');
    }
  }

  /// 移除数据点
  void removeDataPointFromSeries(
    String chartId,
    String seriesId,
    int pointIndex,
  ) {
    try {
      final chartSignal = getChartSignal(chartId);
      final currentData = chartSignal.value;

      if (currentData == null) {
        throw Exception('Chart data not found for $chartId');
      }

      final seriesIndex = currentData.series.indexWhere(
        (series) => series.id == seriesId,
      );

      if (seriesIndex == -1) {
        throw Exception('Series $seriesId not found in chart $chartId');
      }

      final series = currentData.series[seriesIndex];
      if (pointIndex < 0 || pointIndex >= series.data.length) {
        throw Exception('Invalid point index $pointIndex for series $seriesId');
      }

      // 创建新的数据点列表
      final newDataPoints = List<DataPoint>.from(series.data)
        ..removeAt(pointIndex);

      // 创建新的系列
      final newSeries = series.copyWith(data: newDataPoints);

      // 创建新的系列列表
      final newSeriesList = List<ChartSeries>.from(currentData.series);
      newSeriesList[seriesIndex] = newSeries;

      // 创建新的图表数据
      final newChartData = currentData.copyWith(series: newSeriesList);

      chartSignal.value = newChartData;
    } catch (e) {
      setChartError(chartId, '移除数据点失败: $e');
    }
  }

  /// 更新图表配置
  void updateChartConfig(String chartId, ChartConfig newConfig) {
    try {
      final chartSignal = getChartSignal(chartId);
      final currentData = chartSignal.value;

      if (currentData == null) {
        throw Exception('Chart data not found for $chartId');
      }

      final newChartData = currentData.copyWith(config: newConfig);
      chartSignal.value = newChartData;
    } catch (e) {
      setChartError(chartId, '更新图表配置失败: $e');
    }
  }

  /// 清除图表数据
  void clearChart(String chartId) {
    final chartSignal = getChartSignal(chartId);
    chartSignal.value = null;

    final errorSignal = getErrorSignal(chartId);
    errorSignal.value = null;

    setChartLoading(chartId, false);
  }

  /// 清除所有图表数据
  void clearAllCharts() {
    for (final chartId in _charts.keys) {
      clearChart(chartId);
    }
  }

  /// 获取图表统计信息
  Map<String, dynamic> getChartStats(String chartId) {
    final chartSignal = getChartSignal(chartId);
    final chartData = chartSignal.value;

    if (chartData == null) {
      return {'error': 'Chart not found'};
    }

    final stats = <String, dynamic>{
      'chartId': chartId,
      'title': chartData.config.title,
      'type': chartData.config.type.toString(),
      'seriesCount': chartData.series.length,
      'totalDataPoints': chartData.series.fold<int>(
        0,
        (sum, series) => sum + series.data.length,
      ),
    };

    // 计算数据范围
    if (chartData.series.isNotEmpty) {
      final allPoints =
          chartData.series.expand((series) => series.data).toList();

      if (allPoints.isNotEmpty) {
        stats['minX'] =
            allPoints.map((p) => p.x).reduce((a, b) => a < b ? a : b);
        stats['maxX'] =
            allPoints.map((p) => p.x).reduce((a, b) => a > b ? a : b);
        stats['minY'] =
            allPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b);
        stats['maxY'] =
            allPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b);
      }
    }

    return stats;
  }

  /// 导出图表数据为JSON
  Map<String, dynamic> exportChartData(String chartId) {
    final chartSignal = getChartSignal(chartId);
    final chartData = chartSignal.value;

    if (chartData == null) {
      throw Exception('Chart data not found for $chartId');
    }

    return chartData.toJson();
  }

  /// 从JSON导入图表数据
  void importChartData(String chartId, Map<String, dynamic> json) {
    try {
      final chartData = ChartData.fromJson(json);
      setChartData(chartId, chartData);
    } catch (e) {
      setChartError(chartId, '导入图表数据失败: $e');
    }
  }
}

/// 图表服务扩展
extension ChartServiceExtension on ChartService {
  /// 创建实时数据图表
  void createRealtimeChart(
    String chartId, {
    required String title,
    required ChartType type,
    int maxDataPoints = 50,
  }) {
    final config = ChartConfig(
      title: title,
      type: type,
      showGrid: true,
      showLegend: true,
      animate: true,
    );

    final chartData = ChartData(
      id: chartId,
      config: config,
      series: [],
      createdAt: DateTime.now(),
    );

    setChartData(chartId, chartData);
  }

  /// 添加实时数据点
  void addRealtimeDataPoint(
    String chartId,
    String seriesId,
    double x,
    double y, {
    String? label,
    Color? color,
    int maxDataPoints = 50,
  }) {
    final chartSignal = getChartSignal(chartId);
    final currentData = chartSignal.value;

    if (currentData == null) return;

    // 查找或创建系列
    int seriesIndex = currentData.series.indexWhere(
      (series) => series.id == seriesId,
    );

    ChartSeries targetSeries;
    if (seriesIndex == -1) {
      // 创建新系列
      targetSeries = ChartSeries(
        id: seriesId,
        name: seriesId,
        data: [],
        color: color ?? Colors.blue,
      );
      seriesIndex = currentData.series.length;
    } else {
      targetSeries = currentData.series[seriesIndex];
    }

    // 添加新数据点
    final newDataPoint = DataPoint(
      x: x,
      y: y,
      label: label,
      color: color,
    );

    final newDataPoints = List<DataPoint>.from(targetSeries.data)
      ..add(newDataPoint);

    // 限制数据点数量
    if (newDataPoints.length > maxDataPoints) {
      newDataPoints.removeAt(0);
    }

    final newSeries = targetSeries.copyWith(data: newDataPoints);

    // 更新系列列表
    final newSeriesList = List<ChartSeries>.from(currentData.series);
    if (seriesIndex >= newSeriesList.length) {
      newSeriesList.add(newSeries);
    } else {
      newSeriesList[seriesIndex] = newSeries;
    }

    final newChartData = currentData.copyWith(series: newSeriesList);
    chartSignal.value = newChartData;
  }
}
