# Flutter快速开发框架 - 开发规则文档

## 1. 项目架构概览

### 1.1 整体架构设计

本项目采用分层架构设计，遵循关注点分离原则：

```
应用层 (Application Layer)
├── 页面层 (Pages)
├── 功能模块层 (Features)
└── 共享组件层 (Shared Widgets)

框架核心层 (Core Layer)
├── 服务层 (Services)
├── 组件库 (Widgets)
├── 路由管理 (Router)
├── 模型定义 (Models)
└── 常量配置 (Constants)

基础服务层 (Infrastructure Layer)
├── 网络请求 (Network)
├── 本地存储 (Storage)
├── 状态管理 (State Management)
└── 主题管理 (Theme Management)
```

### 1.2 技术栈

- **前端框架**: Flutter 3.x
- **状态管理**: Signals (响应式状态管理)
- **路由管理**: go_router 12.x
- **网络请求**: dio 5.x
- **图表可视化**: fl_chart 0.66.x
- **动画系统**: Flutter内置动画 + 自定义动画服务
- **图标管理**: Material Icons + SVG支持
- **UI组件库**: Material Design 3.0
- **本地存储**: shared_preferences
- **屏幕适配**: flutter_screenutil

## 2. 目录结构规范

### 2.1 核心目录结构

```
lib/
├── core/                    # 核心模块
│   ├── config/             # 配置文件
│   ├── constants/          # 常量定义
│   ├── models/             # 数据模型
│   ├── router/             # 路由配置
│   ├── services/           # 核心服务
│   └── widgets/            # 核心组件
├── features/               # 功能模块
│   ├── home/              # 首页模块
│   ├── charts/            # 图表模块
│   ├── animations/        # 动画模块
│   ├── icons/             # 图标模块
│   └── components/        # 组件展示模块
├── pages/                  # 页面层
│   └── demo/              # 演示页面
├── shared/                 # 共享资源
│   ├── themes/            # 主题配置
│   └── widgets/           # 共享组件
└── widgets/               # 通用组件
```

### 2.2 文件命名规范

- **页面文件**: `*_page.dart` (如: `home_page.dart`)
- **组件文件**: `*_widget.dart` 或 `*_components.dart`
- **服务文件**: `*_service.dart` (如: `theme_service.dart`)
- **模型文件**: `*_models.dart` 或 `*_model.dart`
- **常量文件**: `*_constants.dart`
- **配置文件**: `*_config.dart`

## 3. 服务层架构

### 3.1 服务设计模式

所有服务采用单例模式，通过工厂构造函数提供全局访问：

```dart
class ServiceName {
  static final ServiceName _instance = ServiceName._internal();
  factory ServiceName() => _instance;
  ServiceName._internal();
  
  // 服务实现
}
```

### 3.2 核心服务列表

#### 3.2.1 主题服务 (ThemeService)
- **功能**: 主题模式管理、颜色配置、系统主题监听
- **状态管理**: 基于Signals的响应式状态
- **支持功能**:
  - 主题模式切换 (system/light/dark)
  - 自定义强调色
  - 主题持久化存储
  - 系统主题变化监听

#### 3.2.2 网络服务 (NetworkService)
- **功能**: HTTP请求封装、拦截器管理、加载状态控制
- **基础库**: Dio
- **支持功能**:
  - RESTful API封装 (GET/POST/PUT/DELETE/PATCH)
  - 全局加载状态管理
  - 请求/响应拦截器
  - 错误处理机制
  - 超时配置

#### 3.2.3 状态服务 (StateService)
- **功能**: 全局状态管理、响应式编程支持
- **基础库**: Signals
- **支持功能**:
  - 全局Signal管理
  - Computed信号
  - Effect副作用管理
  - 批量更新
  - 状态清理

#### 3.2.4 存储服务 (StorageService)
- **功能**: 本地数据持久化
- **基础库**: shared_preferences
- **支持功能**:
  - 键值对存储
  - 类型安全的数据访问
  - 异步操作支持

#### 3.2.5 动画服务 (AnimationService)
- **功能**: 动画配置管理、预设动画
- **支持功能**:
  - 动画配置管理
  - 页面转场动画
  - 组件动画效果

#### 3.2.6 图标服务 (IconService)
- **功能**: 图标资源管理
- **支持功能**:
  - Material Icons管理
  - SVG图标支持
  - 图标缓存机制

#### 3.2.7 图表服务 (ChartService)
- **功能**: 图表配置和数据管理
- **基础库**: fl_chart
- **支持功能**:
  - 图表配置管理
  - 数据格式化
  - 主题适配

#### 3.2.8 加载管理器 (LoadingManager)
- **功能**: 全局加载状态控制
- **支持功能**:
  - 加载遮罩显示/隐藏
  - 自定义加载消息
  - 强制隐藏机制

## 4. 组件库规范

### 4.1 基础UI组件

#### 4.1.1 AppButton
- **位置**: `lib/core/widgets/ui_components.dart`
- **功能**: 统一的按钮组件
- **支持属性**:
  - 类型: primary, secondary, text
  - 尺寸: small, medium, large
  - 状态: loading, disabled
  - 自定义: 颜色、宽度、内边距

#### 4.1.2 AppTextField
- **位置**: `lib/core/widgets/ui_components.dart`
- **功能**: 统一的输入框组件
- **支持属性**:
  - 输入类型配置
  - 验证规则
  - 样式定制

#### 4.1.3 AppCard
- **位置**: `lib/core/widgets/ui_components.dart`
- **功能**: 统一的卡片容器
- **支持属性**:
  - 圆角配置
  - 阴影效果
  - 内边距设置

### 4.2 高级组件

#### 4.2.1 表单组件 (AppForm)
- **位置**: `lib/core/widgets/form_components.dart`
- **功能**: 表单容器和字段管理
- **包含组件**:
  - `AppForm`: 表单容器
  - `AppFormField`: 表单字段包装器
  - `AppTable`: 移动端友好的表格

#### 4.2.2 图表组件 (ChartWidget)
- **位置**: `lib/core/widgets/chart_widget.dart`
- **功能**: 图表展示组件
- **支持类型**:
  - 折线图
  - 柱状图
  - 饼图
  - 散点图

#### 4.2.3 加载覆盖 (LoadingOverlay)
- **位置**: `lib/core/widgets/loading_overlay.dart`
- **功能**: 全局加载遮罩
- **支持功能**:
  - 自定义加载动画
  - 加载消息显示
  - 背景遮罩

### 4.3 功能组件

#### 4.3.1 特性卡片 (FeatureCard)
- **位置**: `lib/shared/widgets/feature_card.dart`
- **功能**: 功能展示卡片
- **用途**: 首页功能入口展示

#### 4.3.2 动画组件
- **位置**: `lib/widgets/animation_widgets.dart`
- **功能**: 预设动画效果组件

#### 4.3.3 图标组件
- **位置**: `lib/widgets/icon_widgets.dart`
- **功能**: 图标展示和管理组件

## 5. 状态管理规范

### 5.1 Signals使用规范

#### 5.1.1 基础Signal
```dart
// 创建Signal
final Signal<int> counter = signal(0);

// 使用Signal
Watch((context) {
  return Text('${counter.value}');
});

// 更新Signal
counter.value = newValue;
```

#### 5.1.2 Computed Signal
```dart
// 创建Computed
final Computed<String> displayText = computed(() => 
  'Count: ${counter.value}'
);
```

#### 5.1.3 Effect
```dart
// 创建Effect
final effect = Effect(() {
  print('Counter changed: ${counter.value}');
});

// 清理Effect
effect.dispose();
```

### 5.2 全局状态管理

#### 5.2.1 StateService使用
```dart
// 创建全局Signal
final stateService = StateService();
final globalCounter = stateService.signal<int>('counter', 0);

// 获取全局状态
final value = stateService.getSignalValue<int>('counter');

// 设置全局状态
stateService.setSignalValue('counter', 10);
```

#### 5.2.2 预定义全局状态键
```dart
class GlobalStateKeys {
  static const String theme = 'global_theme';
  static const String locale = 'global_locale';
  static const String user = 'global_user';
  static const String loading = 'global_loading';
  static const String error = 'global_error';
  static const String networkStatus = 'global_network_status';
}
```

### 5.3 响应式Widget

#### 5.3.1 ReactiveWidget基类
```dart
class MyWidget extends ReactiveWidget {
  @override
  Widget buildReactive(BuildContext context) {
    return Watch((context) {
      // 响应式UI构建
    });
  }
  
  @override
  void initState() {
    // 初始化状态
  }
  
  @override
  void dispose() {
    // 清理状态
  }
}
```

## 6. 路由管理规范

### 6.1 路由配置

#### 6.1.2 路由定义
- 路由配置位于: `lib/core/router/app_router.dart`
- 支持多模式路由 (demo模式、feature模式)
- 支持嵌套路由和参数传递

#### 6.1.2 路由常量
```dart
class AppConstants {
  static const String homeRoute = '/';
  static const String chartsRoute = '/charts';
  static const String animationsRoute = '/animations';
  static const String iconsRoute = '/icons';
  static const String componentsRoute = '/components';
}
```

### 6.2 页面导航

#### 6.2.1 基础导航
```dart
// 导航到指定页面
context.go('/charts');

// 带参数导航
context.go('/charts?type=line');

// 返回上一页
context.pop();
```

## 7. 网络请求规范

### 7.1 NetworkService使用

#### 7.1.1 基础请求
```dart
// GET请求
final data = await NetworkService.get<Map<String, dynamic>>(
  '/api/data',
  queryParameters: {'page': 1},
  showLoading: true,
  loadingMessage: '加载中...',
);

// POST请求
final result = await NetworkService.post<Map<String, dynamic>>(
  '/api/submit',
  data: {'name': 'value'},
  showLoading: true,
);
```

#### 7.1.2 错误处理
```dart
try {
  final data = await NetworkService.get('/api/data');
  // 处理成功响应
} catch (e) {
  // 处理错误
  print('Request failed: $e');
}
```

### 7.2 网络配置

#### 7.2.1 初始化配置
```dart
NetworkService.init(
  baseUrl: 'https://api.example.com',
  context: context,
  globalLoadingEnabled: true,
);
```

## 8. 主题管理规范

### 8.1 ThemeService使用

#### 8.1.1 主题切换
```dart
final themeService = ThemeService();

// 设置主题模式
await themeService.setThemeMode(AppThemeMode.dark);

// 设置强调色
await themeService.setAccentColor(Colors.purple);
```

#### 8.1.2 响应式主题
```dart
Watch((context) {
  final themeService = ThemeService();
  final isDark = themeService.isDarkMode();
  
  return Container(
    color: isDark ? Colors.black : Colors.white,
  );
});
```

### 8.2 主题配置

#### 8.2.1 主题模式
```dart
enum AppThemeMode {
  system,  // 跟随系统
  light,   // 浅色模式
  dark,    // 深色模式
}
```

## 9. 开发指南

### 9.1 组件开发规范

#### 9.1.1 组件命名
- 所有自定义组件以 `App` 前缀命名
- 使用驼峰命名法
- 组件名称应清晰表达功能

#### 9.1.2 组件结构
```dart
class AppComponentName extends StatelessWidget {
  // 必需参数
  final String requiredParam;
  
  // 可选参数
  final String? optionalParam;
  final VoidCallback? onTap;
  
  // 样式参数
  final Color? color;
  final EdgeInsets? padding;
  
  const AppComponentName({
    super.key,
    required this.requiredParam,
    this.optionalParam,
    this.onTap,
    this.color,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      // 组件实现
    );
  }
}
```

#### 9.1.3 组件文档
```dart
/// 应用按钮组件
/// 
/// 支持多种类型和尺寸的按钮样式
/// 
/// 示例:
/// ```dart
/// AppButton(
///   text: '确定',
///   type: AppButtonType.primary,
///   onPressed: () => print('按钮点击'),
/// )
/// ```
class AppButton extends StatelessWidget {
  // 组件实现
}
```

### 9.2 服务开发规范

#### 9.2.1 服务结构
```dart
/// 服务描述
class ServiceName {
  // 单例模式
  static final ServiceName _instance = ServiceName._internal();
  factory ServiceName() => _instance;
  ServiceName._internal();
  
  // 私有属性
  late final Signal<Type> _privateSignal;
  
  // 公共访问器
  Signal<Type> get publicSignal => _privateSignal;
  
  /// 初始化服务
  Future<void> init() async {
    // 初始化逻辑
  }
  
  /// 公共方法
  Future<void> publicMethod() async {
    // 方法实现
  }
  
  /// 私有方法
  void _privateMethod() {
    // 私有逻辑
  }
}
```

#### 9.2.2 服务初始化
```dart
// 在main.dart中初始化所有服务
Future<void> _initializeServices() async {
  await StorageService.init();
  StateService();
  await ThemeService().init();
  NetworkService.init(baseUrl: 'https://api.example.com');
  AnimationService.init();
  await IconService().init();
}
```

### 9.3 页面开发规范

#### 9.3.1 页面结构
```dart
class PageName extends StatefulWidget {
  const PageName({super.key});
  
  @override
  State<PageName> createState() => _PageNameState();
}

class _PageNameState extends State<PageName> {
  // 状态变量
  
  @override
  void initState() {
    super.initState();
    // 初始化逻辑
  }
  
  @override
  void dispose() {
    // 清理逻辑
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
  
  Widget _buildAppBar() {
    return AppBar(
      title: const Text('页面标题'),
    );
  }
  
  Widget _buildBody() {
    return const Center(
      child: Text('页面内容'),
    );
  }
}
```

### 9.4 常量管理规范

#### 9.4.1 常量分类
```dart
class AppConstants {
  // 应用信息
  static const String appName = 'Flutter Framework';
  static const String appVersion = '1.0.0';
  
  // 动画配置
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // 间距配置
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  
  // 网络配置
  static const Duration networkTimeout = Duration(seconds: 30);
  
  // 路由配置
  static const String homeRoute = '/';
}
```

## 10. 代码复用规范

### 10.1 组件复用

#### 10.1.1 基础组件复用
- 优先使用 `lib/core/widgets/` 中的基础组件
- 避免重复实现相似功能的组件
- 通过参数配置实现组件的灵活性

#### 10.1.2 高级组件复用
- 复杂组件应提供充分的配置选项
- 支持自定义样式和行为
- 提供默认配置以简化使用

### 10.2 服务复用

#### 10.2.1 服务访问
```dart
// 通过单例访问服务
final themeService = ThemeService();
final networkService = NetworkService();
final stateService = StateService();
```

#### 10.2.2 服务扩展
- 新功能优先考虑扩展现有服务
- 避免创建功能重叠的服务
- 保持服务职责单一

### 10.3 工具类复用

#### 10.3.1 常用工具
- 使用 `AppConstants` 中的预定义常量
- 复用 `app_models.dart` 中的数据模型
- 利用扩展方法简化常用操作

### 10.4 样式复用

#### 10.4.1 主题样式
```dart
// 使用主题中的预定义样式
Text(
  'Title',
  style: Theme.of(context).textTheme.titleLarge,
);

// 使用主题颜色
Container(
  color: Theme.of(context).colorScheme.primary,
);
```

#### 10.4.2 常量样式
```dart
// 使用预定义间距
Padding(
  padding: const EdgeInsets.all(AppConstants.paddingMedium),
);

// 使用预定义圆角
BorderRadius.circular(AppConstants.radiusMedium);
```

## 11. 质量保证规范

### 11.1 代码质量

#### 11.1.1 代码格式
- 使用 `dart format` 格式化代码
- 遵循 Dart 官方代码风格指南
- 保持一致的命名规范

#### 11.1.2 代码注释
- 为公共API提供文档注释
- 复杂逻辑添加行内注释
- 使用示例代码说明用法

### 11.2 性能优化

#### 11.2.1 Widget优化
- 使用 `const` 构造函数
- 避免在 `build` 方法中创建对象
- 合理使用 `StatelessWidget` 和 `StatefulWidget`

#### 11.2.2 状态管理优化
- 避免不必要的状态更新
- 使用 `Computed` 缓存计算结果
- 及时清理不需要的 `Effect`

### 11.3 错误处理

#### 11.3.1 异常捕获
```dart
try {
  // 可能出错的代码
} catch (e) {
  // 错误处理
  debugPrint('Error: $e');
} finally {
  // 清理代码
}
```

#### 11.3.2 用户友好的错误提示
- 网络错误提供重试机制
- 表单验证提供清晰的错误信息
- 使用 `SnackBar` 显示操作结果

## 12. 部署和维护

### 12.1 构建配置

#### 12.1.1 环境配置
- 开发环境: `flutter run`
- 生产构建: `flutter build`
- Web部署: `flutter build web`

#### 12.1.2 资源优化
- 图片资源压缩
- 字体文件优化
- 代码混淆配置

### 12.2 版本管理

#### 12.2.1 版本号规范
- 遵循语义化版本控制
- 主版本.次版本.修订版本
- 在 `pubspec.yaml` 中维护版本号

#### 12.2.2 更新日志
- 记录功能变更
- 记录API变更
- 记录已知问题和修复

## 13. 最佳实践总结

### 13.1 开发流程
1. 分析需求，确定使用的组件和服务
2. 检查现有实现，避免重复开发
3. 遵循项目架构和命名规范
4. 编写清晰的文档和注释
5. 进行充分的测试验证

### 13.2 代码审查要点
1. 是否复用了现有组件和服务
2. 是否遵循了项目架构规范
3. 是否提供了适当的错误处理
4. 是否考虑了性能优化
5. 是否添加了必要的文档

### 13.3 持续改进
1. 定期重构和优化代码
2. 更新依赖库到最新稳定版本
3. 收集用户反馈，改进用户体验
4. 监控应用性能，及时优化
5. 保持技术栈的先进性

---

**注意**: 本文档应随项目发展持续更新，确保规范的时效性和准确性。所有开发人员都应熟悉并遵循本规范，以保证项目的一致性和可维护性。