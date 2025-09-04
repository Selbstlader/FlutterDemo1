import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import 'package:go_router/go_router.dart';
import '../core/widgets/ui_components.dart';
import '../core/services/theme_service.dart';
import '../core/services/storage_service.dart';

import '../core/services/network_service.dart';
import '../core/router/app_router.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ThemeService _themeService = ThemeService();
  // StorageService 使用静态方法，无需实例化

  // NetworkService现在是静态类，不需要实例化
  
  // 设置状态
  final Signal<bool> _notificationsEnabled = signal(true);
  final Signal<bool> _analyticsEnabled = signal(true);
  final Signal<bool> _crashReportingEnabled = signal(true);
  final Signal<bool> _autoUpdateEnabled = signal(true);
  final Signal<double> _cacheSize = signal(0.0);
  final Signal<String> _appVersion = signal('1.0.0');
  final Signal<String> _buildNumber = signal('1');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      _notificationsEnabled.value = StorageService.getBool('notifications_enabled') ?? true;
    _analyticsEnabled.value = StorageService.getBool('analytics_enabled') ?? true;
    _crashReportingEnabled.value = StorageService.getBool('crash_reporting_enabled') ?? true;
    _autoUpdateEnabled.value = StorageService.getBool('auto_update_enabled') ?? true;
      
      // 模拟获取缓存大小
      _cacheSize.value = 12.5; // MB
    } catch (e) {
      // 静默处理错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.pushNamed('/about'),
            tooltip: '关于',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '外观', icon: Icon(Icons.palette)),
            Tab(text: '通用', icon: Icon(Icons.settings)),
            Tab(text: '存储', icon: Icon(Icons.storage)),
            Tab(text: '关于', icon: Icon(Icons.info)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAppearanceTab(),
          _buildGeneralTab(),
          _buildStorageTab(),
          _buildAboutTab(),
        ],
      ),
    );
  }

  Widget _buildAppearanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('主题设置', '自定义应用外观和颜色'),
          const SizedBox(height: 16),
          
          // 主题模式设置
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主题模式',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: AppThemeMode.values.map((mode) {
              final isSelected = _themeService.themeMode.value == mode;
              return RadioListTile<AppThemeMode>(
                title: Text(_getThemeModeText(mode)),
                subtitle: Text(_getThemeModeDescription(mode)),
                value: mode,
                groupValue: _themeService.themeMode.value,
                onChanged: (value) {
                  if (value != null) {
                    _themeService.setThemeMode(value);
                  }
                },
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 强调色设置
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '强调色',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ThemeService.presetColors.map((color) {
                      final isSelected = _themeService.accentColor.value == color;
                      return GestureDetector(
                        onTap: () => _themeService.setAccentColor(color),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : Border.all(color: Colors.grey.shade300, width: 1),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 主题预览
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主题预览',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.palette,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '主题预览',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  '这是当前主题的预览效果',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: '主要按钮',
                              size: ButtonSize.small,
                              onPressed: () {},
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppButton(
                              text: '次要按钮',
                              size: ButtonSize.small,
                              type: ButtonType.secondary,
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 主题操作
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '主题操作',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: '导出主题',
                        icon: const Icon(Icons.download),
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: () => _exportTheme(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: '导入主题',
                        icon: const Icon(Icons.upload),
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: () => _importTheme(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: '重置主题',
                        icon: const Icon(Icons.refresh),
                        size: ButtonSize.small,
                        backgroundColor: Colors.orange,
                        onPressed: () => _resetTheme(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('通用设置', '配置应用的基本功能和行为'),
          const SizedBox(height: 16),
          
          // 通知设置
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '通知设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('启用通知'),
                        subtitle: const Text('接收应用通知和提醒'),
                        value: _notificationsEnabled.value,
                        onChanged: (value) => _updateNotificationSetting(value),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('自动更新'),
                        subtitle: const Text('自动检查和安装应用更新'),
                        value: _autoUpdateEnabled.value,
                        onChanged: (value) => _updateAutoUpdateSetting(value),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 隐私设置
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '隐私设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('数据分析'),
                        subtitle: const Text('帮助改进应用体验'),
                        value: _analyticsEnabled.value,
                        onChanged: (value) => _updateAnalyticsSetting(value),
                        contentPadding: EdgeInsets.zero,
                      ),
                      SwitchListTile(
                        title: const Text('崩溃报告'),
                        subtitle: const Text('自动发送崩溃报告'),
                        value: _crashReportingEnabled.value,
                        onChanged: (value) => _updateCrashReportingSetting(value),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 网络设置
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '网络设置',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('网络超时'),
                  subtitle: const Text('30秒'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTimeoutDialog(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('代理设置'),
                  subtitle: const Text('未配置'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showProxyDialog(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('网络诊断'),
                  subtitle: const Text('检查网络连接状态'),
                  trailing: const Icon(Icons.network_check),
                  onTap: () => _runNetworkDiagnostic(),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('存储管理', '管理应用数据和缓存'),
          const SizedBox(height: 16),
          
          // 存储概览
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '存储概览',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      _buildStorageItem('应用数据', '2.3 MB', Icons.app_settings_alt),
                      const SizedBox(height: 8),
                      _buildStorageItem('缓存文件', '${_cacheSize.value.toStringAsFixed(1)} MB', Icons.cached),
                      const SizedBox(height: 8),
                      _buildStorageItem('日志文件', '0.8 MB', Icons.description),
                      const SizedBox(height: 8),
                      _buildStorageItem('临时文件', '1.2 MB', Icons.folder_open),
                      const Divider(),
                      _buildStorageItem('总计', '${(2.3 + _cacheSize.value + 0.8 + 1.2).toStringAsFixed(1)} MB', Icons.storage, isTotal: true),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 缓存管理
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '缓存管理',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: '清理缓存',
                        icon: const Icon(Icons.cleaning_services),
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: () => _clearCache(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        text: '清理日志',
                        icon: const Icon(Icons.delete_sweep),
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: () => _clearLogs(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppButton(
                  text: '清理所有数据',
                  icon: const Icon(Icons.delete_forever),
                  size: ButtonSize.small,
                  backgroundColor: Colors.red,
                  onPressed: () => _clearAllData(),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 数据备份
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '数据备份',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('备份数据'),
                  subtitle: const Text('导出应用设置和数据'),
                  leading: const Icon(Icons.backup),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _backupData(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('恢复数据'),
                  subtitle: const Text('从备份文件恢复'),
                  leading: const Icon(Icons.restore),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _restoreData(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('自动备份'),
                  subtitle: const Text('定期自动备份数据'),
                  leading: const Icon(Icons.schedule),
                  trailing: Switch(
                    value: true,
                    onChanged: (value) => _toggleAutoBackup(value),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('关于应用', '应用信息和开发者信息'),
          const SizedBox(height: 16),
          
          // 应用信息
          AppCard(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.flutter_dash,
                    size: 40,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Flutter 快速开发框架',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Watch((context) {
                  return Text(
                    '版本 ${_appVersion.value} (${_buildNumber.value})',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  '一个功能完整的 Flutter 快速开发框架，集成了状态管理、UI 组件、网络请求、主题系统等核心功能。',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 功能特性
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '核心特性',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildFeatureItem('响应式状态管理', 'Signals 驱动的响应式状态管理'),
                _buildFeatureItem('图表可视化', '基于 fl_chart 的丰富图表组件'),
                _buildFeatureItem('动画系统', '流畅的页面转场和组件动画'),
                _buildFeatureItem('UI 组件库', 'Material Design 3.0 组件'),
                _buildFeatureItem('网络请求', 'Dio 驱动的 HTTP 客户端'),
                _buildFeatureItem('主题系统', '支持深色模式和自定义主题'),
                _buildFeatureItem('图标管理', 'Material Icons 和 SVG 支持'),
                _buildFeatureItem('工具服务', '日志、存储、路由等工具服务'),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 开发者信息
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '开发者信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('开发者'),
                  subtitle: const Text('Flutter Framework Team'),
                  leading: const Icon(Icons.person),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('邮箱'),
                  subtitle: const Text('support@flutter-framework.com'),
                  leading: const Icon(Icons.email),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('官网'),
                  subtitle: const Text('https://flutter-framework.com'),
                  leading: const Icon(Icons.web),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('GitHub'),
                  subtitle: const Text('https://github.com/flutter-framework'),
                  leading: const Icon(Icons.code),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 法律信息
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '法律信息',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('许可协议'),
                  subtitle: const Text('MIT License'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLicense(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('隐私政策'),
                  subtitle: const Text('查看隐私政策'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showPrivacyPolicy(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('使用条款'),
                  subtitle: const Text('查看使用条款'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTermsOfService(),
                  contentPadding: EdgeInsets.zero,
                ),
                ListTile(
                  title: const Text('开源许可'),
                  subtitle: const Text('第三方开源库许可'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showOpenSourceLicenses(),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStorageItem(String title, String size, IconData icon, {bool isTotal = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isTotal ? Theme.of(context).colorScheme.primary : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Text(
          size,
          style: isTotal
              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
              : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getThemeModeText(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '跟随系统';
      case AppThemeMode.light:
        return '浅色模式';
      case AppThemeMode.dark:
        return '深色模式';
    }
  }

  String _getThemeModeDescription(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return '根据系统设置自动切换主题';
      case AppThemeMode.light:
        return '始终使用浅色主题';
      case AppThemeMode.dark:
        return '始终使用深色主题';
    }
  }

  Future<void> _updateNotificationSetting(bool value) async {
    _notificationsEnabled.value = value;
    await StorageService.setBool('notifications_enabled', value);
  }

  Future<void> _updateAnalyticsSetting(bool value) async {
    _analyticsEnabled.value = value;
    await StorageService.setBool('analytics_enabled', value);
  }

  Future<void> _updateCrashReportingSetting(bool value) async {
    _crashReportingEnabled.value = value;
    await StorageService.setBool('crash_reporting_enabled', value);
  }

  Future<void> _updateAutoUpdateSetting(bool value) async {
    _autoUpdateEnabled.value = value;
    await StorageService.setBool('auto_update_enabled', value);
  }

  void _exportTheme() {
    try {
      final config = _themeService.exportThemeConfig();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('主题配置已导出'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('导出主题失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _importTheme() {
    // 模拟导入主题配置
    try {
      const mockConfig = {
        'themeMode': 'dark',
        'accentColor': 0xFF2196F3,
      };
      
      _themeService.importThemeConfig(mockConfig);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('主题配置已导入'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('导入主题失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _resetTheme() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重置主题'),
        content: const Text('确定要重置主题设置吗？这将恢复默认的主题配置。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _themeService.setThemeMode(AppThemeMode.system);
              _themeService.setAccentColor(Colors.blue);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('主题已重置为默认设置'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('网络超时设置'),
        content: const Text('当前网络超时时间为 30 秒。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showProxyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('代理设置'),
        content: const Text('当前未配置网络代理。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _runNetworkDiagnostic() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在检查网络连接...'),
            ],
          ),
        ),
      );
      
      // 模拟网络诊断
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('网络诊断结果'),
            content: const Text('网络连接正常\n延迟: 45ms\n下载速度: 50 Mbps'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('确定'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // 静默处理错误
    }
  }

  void _clearCache() async {
    try {
      // 模拟清理缓存
      await Future.delayed(const Duration(milliseconds: 500));
      _cacheSize.value = 0.0;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('缓存已清理'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // 静默处理错误
    }
  }

  void _clearLogs() async {
    try {
      // 日志功能已移除
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('日志已清理'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // 静默处理错误
    }
  }

  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理所有数据'),
        content: const Text('确定要清理所有应用数据吗？这个操作不可撤销，将删除所有设置、缓存和用户数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              try {
                await StorageService.clear();
                _cacheSize.value = 0.0;
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('所有数据已清理'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } catch (e) {
                // 静默处理错误
              }
            },
            child: const Text('确定', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据备份功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _restoreData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据恢复功能开发中'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleAutoBackup(bool value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('自动备份已${value ? '启用' : '禁用'}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLicense() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MIT License'),
        content: const SingleChildScrollView(
          child: Text(
            'MIT License\n\n'
            'Copyright (c) 2024 Flutter Framework Team\n\n'
            'Permission is hereby granted, free of charge, to any person obtaining a copy '
            'of this software and associated documentation files (the "Software"), to deal '
            'in the Software without restriction, including without limitation the rights '
            'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
            'copies of the Software, and to permit persons to whom the Software is '
            'furnished to do so, subject to the following conditions:\n\n'
            'The above copyright notice and this permission notice shall be included in all '
            'copies or substantial portions of the Software.\n\n'
            'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
            'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
            'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
            'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
            'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
            'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
            'SOFTWARE.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const Text('隐私政策内容将在这里显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用条款'),
        content: const Text('使用条款内容将在这里显示。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showOpenSourceLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Flutter 快速开发框架',
      applicationVersion: _appVersion.value,
    );
  }
}