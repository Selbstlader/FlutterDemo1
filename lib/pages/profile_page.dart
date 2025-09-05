import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/models/auth_models.dart';
import '../core/widgets/ui_components.dart';
import '../core/constants/app_constants.dart';

/// 我的页面
/// 显示用户信息、设置选项和其他个人相关功能
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: 导航到设置页面
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 用户信息卡片
            _buildUserInfoCard(authService),
            const SizedBox(height: AppConstants.paddingLarge),

            // 功能菜单
            _buildMenuSection(context),
            const SizedBox(height: AppConstants.paddingLarge),

            // 统计信息
            _buildStatsSection(context),
            const SizedBox(height: AppConstants.paddingLarge),

            // 其他选项
            _buildOtherSection(context),
          ],
        ),
      ),
    );
  }

  /// 构建用户信息卡片
  Widget _buildUserInfoCard(AuthService authService) {
    return Watch((context) {
      final authState = authService.authState.value;

      if (authState.status != AuthStatus.authenticated ||
          authState.profile == null) {
        return _buildGuestCard(context, authService);
      }

      final profile = authState.profile!;

      return AppCard(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Row(
            children: [
              // 用户头像
              CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: profile.avatarUrl != null
                    ? NetworkImage(profile.avatarUrl!)
                    : null,
                child: profile.avatarUrl == null
                    ? Icon(
                        Icons.person,
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : null,
              ),
              const SizedBox(width: AppConstants.paddingMedium),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName ?? profile.username ?? '用户',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                    ),
                    if (profile.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        profile.email!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer
                                  .withOpacity(0.7),
                            ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      '已登录',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              // 编辑按钮
              IconButton(
                onPressed: () {
                  // TODO: 编辑用户信息
                },
                icon: Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                tooltip: '编辑资料',
              ),
            ],
          ),
        ),
      );
    });
  }

  /// 构建游客卡片
  Widget _buildGuestCard(BuildContext context, AuthService authService) {
    return AppCard(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.outline,
              child: Icon(
                Icons.person_outline,
                size: 40,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '游客模式',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '登录后享受更多功能',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            AppButton(
              text: '登录',
              type: ButtonType.primary,
              size: ButtonSize.small,
              onPressed: () {
                // TODO: 导航到登录页面
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建功能菜单区域
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '功能菜单',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        AppCard(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          elevation: 2,
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.favorite,
                title: '我的收藏',
                subtitle: '查看收藏的内容',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.history,
                title: '浏览历史',
                subtitle: '查看最近浏览记录',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.download,
                title: '我的下载',
                subtitle: '管理下载的文件',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.share,
                title: '分享应用',
                subtitle: '推荐给朋友使用',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建统计信息区域
  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '使用统计',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.access_time,
                title: '使用时长',
                value: '2.5小时',
                subtitle: '今日',
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.trending_up,
                title: '活跃天数',
                value: '15天',
                subtitle: '本月',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建其他选项区域
  Widget _buildOtherSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '其他',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        AppCard(
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          elevation: 2,
          child: Column(
            children: [
              _buildMenuItem(
                context,
                icon: Icons.help_outline,
                title: '帮助与反馈',
                subtitle: '获取帮助或提供反馈',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                title: '关于应用',
                subtitle: '版本信息和开发者信息',
                onTap: () {},
              ),
              _buildDivider(),
              _buildMenuItem(
                context,
                icon: Icons.privacy_tip_outlined,
                title: '隐私政策',
                subtitle: '了解我们如何保护您的隐私',
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建菜单项
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          size: AppConstants.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.outline,
      ),
      onTap: onTap,
    );
  }

  /// 构建统计卡片
  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return AppCard(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(
              icon,
              size: AppConstants.iconSizeLarge,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSecondaryContainer
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分割线
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}
