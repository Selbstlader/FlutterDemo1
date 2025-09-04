import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals/signals_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/ui_components.dart';
import '../../core/router/app_router.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 应用信息
  final Signal<String> _appVersion = signal('1.0.0');
  final Signal<String> _buildNumber = signal('1');
  final Signal<String> _buildDate = signal('2024-01-15');
  final Signal<String> _flutterVersion = signal('3.16.0');
  final Signal<String> _dartVersion = signal('3.2.0');

  // 统计信息
  final Signal<int> _totalComponents = signal(25);
  final Signal<int> _totalServices = signal(8);
  final Signal<int> _totalPages = signal(12);
  final Signal<int> _codeLines = signal(5420);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadAppInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));

    _animationController.forward();
  }

  void _loadAppInfo() {
    // 模拟加载应用信息
    _appVersion.value = '1.0.0';
    _buildNumber.value = '1';
    _buildDate.value = '2024-01-15';
    _flutterVersion.value = '3.16.0';
    _dartVersion.value = '3.2.0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareApp(),
            tooltip: '分享应用',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: _buildContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAppHeader(),
          const SizedBox(height: 24),
          _buildAppInfo(),
          const SizedBox(height: 16),
          _buildTechnicalInfo(),
          const SizedBox(height: 16),
          _buildStatistics(),
          const SizedBox(height: 16),
          _buildFeatures(),
          const SizedBox(height: 16),
          _buildDeveloperInfo(),
          const SizedBox(height: 16),
          _buildActions(),
          const SizedBox(height: 16),
          _buildLegalInfo(),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return AppCard(
      child: Column(
        children: [
          Hero(
            tag: 'app_icon',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.flutter_dash,
                size: 50,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Flutter 快速开发框架',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Watch((context) {
            return Text(
              '版本 ${_appVersion.value}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            );
          }),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '功能完整 • 高性能 • 易扩展',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '一个功能完整的 Flutter 快速开发框架，集成了现代移动应用开发所需的核心功能模块，帮助开发者快速构建高质量的移动应用。',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '应用信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Watch((context) {
            return Column(
              children: [
                _buildInfoRow('应用版本', _appVersion.value, Icons.tag),
                _buildInfoRow('构建版本', _buildNumber.value, Icons.build),
                _buildInfoRow('构建日期', _buildDate.value, Icons.calendar_today),
                _buildInfoRow('应用大小', '15.2 MB', Icons.storage),
                _buildInfoRow(
                    '最低系统', 'Android 5.0 / iOS 11.0', Icons.phone_android),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '技术信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Watch((context) {
            return Column(
              children: [
                _buildInfoRow(
                    'Flutter 版本', _flutterVersion.value, Icons.flutter_dash),
                _buildInfoRow('Dart 版本', _dartVersion.value, Icons.code),
                _buildInfoRow('编译模式', 'Release', Icons.speed),
                _buildInfoRow('架构支持', 'ARM64, x86_64', Icons.memory),
                _buildInfoRow('渲染引擎', 'Impeller', Icons.brush),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '项目统计',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Watch((context) {
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '组件数量',
                    _totalComponents.value.toString(),
                    Icons.widgets,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '服务模块',
                    _totalServices.value.toString(),
                    Icons.settings,
                    Colors.green,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
          Watch((context) {
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '页面数量',
                    _totalPages.value.toString(),
                    Icons.pages,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '代码行数',
                    '${(_codeLines.value / 1000).toStringAsFixed(1)}K',
                    Icons.code,
                    Colors.purple,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final features = [
      {
        'title': '响应式状态管理',
        'description': 'Signals 驱动的响应式状态管理系统',
        'icon': Icons.sync
      },
      {
        'title': '图表可视化',
        'description': '基于 fl_chart 的丰富图表组件库',
        'icon': Icons.bar_chart
      },
      {
        'title': '动画系统',
        'description': '流畅的页面转场和组件动画效果',
        'icon': Icons.animation
      },
      {
        'title': 'UI 组件库',
        'description': 'Material Design 3.0 风格组件',
        'icon': Icons.widgets
      },
      {
        'title': '网络请求',
        'description': 'Dio 驱动的 HTTP 客户端封装',
        'icon': Icons.cloud
      },
      {'title': '主题系统', 'description': '支持深色模式和自定义主题配色', 'icon': Icons.palette},
      {
        'title': '图标管理',
        'description': 'Material Icons 和 SVG 图标支持',
        'icon': Icons.image
      },
      {'title': '工具服务', 'description': '日志、存储、路由等基础服务', 'icon': Icons.build},
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '核心特性',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureItem(
                feature['title'] as String,
                feature['description'] as String,
                feature['icon'] as IconData,
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 20,
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
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '开发者信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContactItem(
            '开发团队',
            'Flutter Framework Team',
            Icons.group,
            null,
          ),
          _buildContactItem(
            '邮箱地址',
            'support@flutter-framework.com',
            Icons.email,
            () => _copyToClipboard('support@flutter-framework.com', '邮箱地址已复制'),
          ),
          _buildContactItem(
            '官方网站',
            'https://flutter-framework.com',
            Icons.web,
            () => _copyToClipboard('https://flutter-framework.com', '网站地址已复制'),
          ),
          _buildContactItem(
            'GitHub',
            'https://github.com/flutter-framework',
            Icons.code,
            () => _copyToClipboard(
                'https://github.com/flutter-framework', 'GitHub 地址已复制'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      String title, String value, IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.copy,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.touch_app,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '快速操作',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '查看演示',
                  icon: Icon(Icons.play_arrow),
                  size: ButtonSize.small,
                  onPressed: () => context.pushNamed('/demo'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: '分享应用',
                  icon: Icon(Icons.share),
                  size: ButtonSize.small,
                  type: ButtonType.secondary,
                  onPressed: () => _shareApp(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '检查更新',
                  icon: Icon(Icons.system_update),
                  size: ButtonSize.small,
                  type: ButtonType.secondary,
                  onPressed: () => _checkForUpdates(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  text: '反馈建议',
                  icon: Icon(Icons.feedback),
                  size: ButtonSize.small,
                  type: ButtonType.secondary,
                  onPressed: () => _sendFeedback(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegalInfo() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '法律信息',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildLegalItem('许可协议', 'MIT License', () => _showLicense()),
          _buildLegalItem('隐私政策', '查看隐私政策', () => _showPrivacyPolicy()),
          _buildLegalItem('使用条款', '查看使用条款', () => _showTermsOfService()),
          _buildLegalItem('开源许可', '第三方开源库许可', () => _showOpenSourceLicenses()),
        ],
      ),
    );
  }

  Widget _buildLegalItem(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    const appInfo = 'Flutter 快速开发框架 - 一个功能完整的移动应用开发框架\n'
        '下载地址: https://flutter-framework.com';

    Clipboard.setData(const ClipboardData(text: appInfo));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('应用信息已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _checkForUpdates() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('正在检查更新...'),
          ],
        ),
      ),
    );

    // 模拟检查更新
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('检查更新'),
          content: const Text('当前已是最新版本！'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('确定'),
            ),
          ],
        ),
      );
    }
  }

  void _sendFeedback() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('反馈建议'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('感谢您使用我们的应用！您可以通过以下方式提供反馈：'),
            SizedBox(height: 16),
            Text('• 发送邮件至: support@flutter-framework.com'),
            Text('• 在 GitHub 上提交 Issue'),
            Text('• 通过应用内反馈功能'),
          ],
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
        content: const SingleChildScrollView(
          child: Text(
            '隐私政策\n\n'
            '我们非常重视您的隐私保护。本隐私政策说明了我们如何收集、使用和保护您的个人信息。\n\n'
            '信息收集\n'
            '• 我们不会收集您的个人身份信息\n'
            '• 应用使用数据仅用于改进用户体验\n'
            '• 所有数据均存储在本地设备上\n\n'
            '信息使用\n'
            '• 提供和改进应用功能\n'
            '• 分析应用使用情况\n'
            '• 提供技术支持\n\n'
            '信息保护\n'
            '• 采用行业标准的安全措施\n'
            '• 不会向第三方出售或共享您的信息\n'
            '• 您可以随时删除本地存储的数据',
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

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用条款'),
        content: const SingleChildScrollView(
          child: Text(
            '使用条款\n\n'
            '欢迎使用 Flutter 快速开发框架！通过使用本应用，您同意遵守以下条款：\n\n'
            '使用许可\n'
            '• 本应用基于 MIT 许可证开源\n'
            '• 您可以自由使用、修改和分发\n'
            '• 请保留原始版权声明\n\n'
            '使用限制\n'
            '• 不得用于非法用途\n'
            '• 不得恶意攻击或破坏系统\n'
            '• 不得侵犯他人知识产权\n\n'
            '免责声明\n'
            '• 本应用按"现状"提供\n'
            '• 不保证完全无错误或中断\n'
            '• 使用风险由用户自行承担\n\n'
            '条款变更\n'
            '• 我们保留随时修改条款的权利\n'
            '• 重大变更将通过应用内通知',
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

  void _showOpenSourceLicenses() {
    showLicensePage(
      context: context,
      applicationName: 'Flutter 快速开发框架',
      applicationVersion: _appVersion.value,
    );
  }
}
