import 'package:flutter/material.dart';

/// 图表类型枚举
enum ChartType {
  line('line', '折线图', Icons.show_chart),
  bar('bar', '柱状图', Icons.bar_chart),
  pie('pie', '饼图', Icons.pie_chart),
  scatter('scatter', '散点图', Icons.scatter_plot),
  radar('radar', '雷达图', Icons.radar);

  const ChartType(this.value, this.label, this.icon);
  
  final String value;
  final String label;
  final IconData icon;
}

/// 数据点模型
class DataPoint {
  final double x;
  final double y;
  final String? label;
  final Color? color;
  final Map<String, dynamic>? metadata;

  const DataPoint({
    required this.x,
    required this.y,
    this.label,
    this.color,
    this.metadata,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      label: json['label'] as String?,
      color: json['color'] != null 
          ? Color(json['color'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      if (label != null) 'label': label,
      if (color != null) 'color': color!.value,
      if (metadata != null) 'metadata': metadata,
    };
  }

  DataPoint copyWith({
    double? x,
    double? y,
    String? label,
    Color? color,
    Map<String, dynamic>? metadata,
  }) {
    return DataPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() {
    return 'DataPoint(x: $x, y: $y, label: $label)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DataPoint &&
        other.x == x &&
        other.y == y &&
        other.label == label &&
        other.color == color;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, label, color);
  }
}

/// 图表数据系列
class ChartSeries {
  final String id;
  final String name;
  final List<DataPoint> data;
  final Color color;
  final bool visible;
  final Map<String, dynamic>? style;

  const ChartSeries({
    required this.id,
    required this.name,
    required this.data,
    required this.color,
    this.visible = true,
    this.style,
  });

  factory ChartSeries.fromJson(Map<String, dynamic> json) {
    return ChartSeries(
      id: json['id'] as String,
      name: json['name'] as String,
      data: (json['data'] as List)
          .map((item) => DataPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      color: Color(json['color'] as int),
      visible: json['visible'] as bool? ?? true,
      style: json['style'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'data': data.map((point) => point.toJson()).toList(),
      'color': color.value,
      'visible': visible,
      if (style != null) 'style': style,
    };
  }

  ChartSeries copyWith({
    String? id,
    String? name,
    List<DataPoint>? data,
    Color? color,
    bool? visible,
    Map<String, dynamic>? style,
  }) {
    return ChartSeries(
      id: id ?? this.id,
      name: name ?? this.name,
      data: data ?? this.data,
      color: color ?? this.color,
      visible: visible ?? this.visible,
      style: style ?? this.style,
    );
  }

  @override
  String toString() {
    return 'ChartSeries(id: $id, name: $name, dataCount: ${data.length})';
  }
}

/// 图表配置
class ChartConfig {
  final String title;
  final String? subtitle;
  final ChartType type;
  final bool showLegend;
  final bool showGrid;
  final bool animate;
  final Duration animationDuration;
  final Map<String, dynamic>? customOptions;

  const ChartConfig({
    required this.title,
    this.subtitle,
    required this.type,
    this.showLegend = true,
    this.showGrid = true,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.customOptions,
  });

  factory ChartConfig.fromJson(Map<String, dynamic> json) {
    return ChartConfig(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
      type: ChartType.values.firstWhere(
        (type) => type.value == json['type'],
        orElse: () => ChartType.line,
      ),
      showLegend: json['showLegend'] as bool? ?? true,
      showGrid: json['showGrid'] as bool? ?? true,
      animate: json['animate'] as bool? ?? true,
      animationDuration: Duration(
        milliseconds: json['animationDuration'] as int? ?? 300,
      ),
      customOptions: json['customOptions'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      'type': type.value,
      'showLegend': showLegend,
      'showGrid': showGrid,
      'animate': animate,
      'animationDuration': animationDuration.inMilliseconds,
      if (customOptions != null) 'customOptions': customOptions,
    };
  }

  ChartConfig copyWith({
    String? title,
    String? subtitle,
    ChartType? type,
    bool? showLegend,
    bool? showGrid,
    bool? animate,
    Duration? animationDuration,
    Map<String, dynamic>? customOptions,
  }) {
    return ChartConfig(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      showLegend: showLegend ?? this.showLegend,
      showGrid: showGrid ?? this.showGrid,
      animate: animate ?? this.animate,
      animationDuration: animationDuration ?? this.animationDuration,
      customOptions: customOptions ?? this.customOptions,
    );
  }
}

/// 完整的图表数据模型
class ChartData {
  final String id;
  final ChartConfig config;
  final List<ChartSeries> series;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ChartData({
    required this.id,
    required this.config,
    required this.series,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      id: json['id'] as String,
      config: ChartConfig.fromJson(json['config'] as Map<String, dynamic>),
      series: (json['series'] as List)
          .map((item) => ChartSeries.fromJson(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'config': config.toJson(),
      'series': series.map((s) => s.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ChartData copyWith({
    String? id,
    ChartConfig? config,
    List<ChartSeries>? series,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChartData(
      id: id ?? this.id,
      config: config ?? this.config,
      series: series ?? this.series,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 获取所有可见的数据系列
  List<ChartSeries> get visibleSeries => 
      series.where((s) => s.visible).toList();

  /// 获取数据点总数
  int get totalDataPoints => 
      series.fold(0, (sum, s) => sum + s.data.length);

  @override
  String toString() {
    return 'ChartData(id: $id, type: ${config.type.label}, seriesCount: ${series.length})';
  }
}