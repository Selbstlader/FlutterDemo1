import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../core/services/auth_service.dart';
import '../core/models/auth_models.dart';

/// 开发模式首页
/// 这是一个简单的占位页面，用于开发模式下的首页显示
class HomePage extends StatelessWidget {
  HomePage({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发模式首页'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // 用户信息展示区域
          _buildUserInfoSection(),
          // 主要内容区域
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    size: 64,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '开发模式首页',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '这是开发模式的占位页面',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '功能正在开发中...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建用户信息展示区域
  Widget _buildUserInfoSection() {
    return Watch((context) {
      final authState = _authService.authState.value;
      
      if (authState.status != AuthStatus.authenticated || authState.profile == null) {
        return const SizedBox.shrink();
      }

      final profile = authState.profile!;
      
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
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
                         color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.6),
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
      );
    });
  }
}