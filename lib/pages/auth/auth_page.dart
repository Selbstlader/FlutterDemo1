import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals.dart';
import '../../core/models/auth_models.dart';
import '../../core/services/auth_service.dart';
import '../../core/router/app_router.dart';
import '../../widgets/auth/login_form.dart';
import '../../widgets/auth/register_form.dart';

/// 认证页面
/// 包含登录和注册的Tab切换界面
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();
  late final Signal<AuthState> _authState;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _authState = _authService.authState;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 30.h),
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildTabBar(),
              SizedBox(height: 16.h),
              Expanded(
                child: _buildTabBarView(),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建页面头部
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo或图标
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.lock_outline,
            size: 30.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        // 标题
        Text(
          '欢迎使用',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 6.h),
        // 副标题
        Text(
          '请登录或注册您的账户',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建Tab栏
  Widget _buildTabBar() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(25.r),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey[600],
        labelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: '登录'),
          Tab(text: '注册'),
        ],
      ),
    );
  }

  /// 构建Tab内容视图
  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        // 登录表单
        SingleChildScrollView(
          child: LoginForm(
            onLoginSuccess: _handleLoginSuccess,
            onSwitchToRegister: () => _tabController.animateTo(1),
          ),
        ),
        // 注册表单
        SingleChildScrollView(
          child: RegisterForm(
            onRegisterSuccess: _handleRegisterSuccess,
            onSwitchToLogin: () => _tabController.animateTo(0),
          ),
        ),
      ],
    );
  }

  /// 处理登录成功
  void _handleLoginSuccess(AuthResult result) {
    if (result.isSuccess) {
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? '登录成功'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 导航到主页面
      _navigateToHome();
    } else {
      // 显示错误消息
      // _showErrorMessage(result.message ?? '登录失败');
    }
  }

  /// 处理注册成功
  void _handleRegisterSuccess(AuthResult result) {
    if (result.isSuccess) {
      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message ?? '注册成功'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 导航到主页面
      _navigateToHome();
    } else {
      // 显示错误消息
      // _showErrorMessage(result.message ?? '注册失败');
    }
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 导航到主页面
  void _navigateToHome() {
    // 使用AppRouter导航到首页
    AppRouter.go(AppRoutes.home);
  }
}
