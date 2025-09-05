import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals.dart';
import '../../core/models/auth_models.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/form_components.dart';
import '../../core/widgets/ui_components.dart';
import '../../core/widgets/adaptive_form_field.dart';

/// 登录表单组件
class LoginForm extends StatefulWidget {
  final Function(AuthResult) onLoginSuccess;
  final VoidCallback? onSwitchToRegister;

  const LoginForm({
    super.key,
    required this.onLoginSuccess,
    this.onSwitchToRegister,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late final Signal<AuthState> _authState;

  @override
  void initState() {
    super.initState();
    _authState = _authService.authState;

    // 监听认证状态变化
    effect(() {
      final state = _authState.value;
      if (mounted) {
        setState(() {
          _isLoading = state.isLoading;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppForm(
      formKey: _formKey,
      showSubmitButton: false,
      padding: EdgeInsets.zero,
      keyboardAdaptive: true,
      children: [
        _buildUsernameField(),
        _buildPasswordField(),
        SizedBox(height: 16.h),
        _buildLoginButton(),
        SizedBox(height: 8.h),
        _buildForgotPasswordButton(),
        if (widget.onSwitchToRegister != null) ...[
          SizedBox(height: 12.h),
          _buildSwitchToRegisterButton(),
        ],
      ],
    );
  }

  /// 构建用户名输入框
  Widget _buildUsernameField() {
    return AdaptiveFormField(
      labelText: '登录邮箱',
      required: true,
      keyboardAdaptive: true,
      controller: _usernameController,
      hintText: '请输入登录邮箱',
      prefixIcon: const Icon(Icons.person_outline),
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      validator: AppValidators.required,
    );
  }

  /// 构建密码输入框
  Widget _buildPasswordField() {
    return AdaptiveFormField(
      labelText: '密码',
      required: true,
      keyboardAdaptive: true,
      controller: _passwordController,
      hintText: '请输入密码',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isPasswordVisible = !_isPasswordVisible;
          });
        },
      ),
      obscureText: !_isPasswordVisible,
      enabled: !_isLoading,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleLogin(),
      validator: AppValidators.required,
    );
  }

  /// 构建登录按钮
  Widget _buildLoginButton() {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '登录',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// 构建忘记密码按钮
  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _isLoading ? null : _handleForgotPassword,
      child: Text(
        '忘记密码？',
        style: TextStyle(
          fontSize: 14.sp,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  /// 构建切换到注册按钮
  Widget _buildSwitchToRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账户？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : widget.onSwitchToRegister,
          child: Text(
            '立即注册',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 处理登录
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 隐藏键盘
    FocusScope.of(context).unfocus();

    final request = LoginRequest(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
    );

    try {
      final result = await _authService.loginWithUsername(request);
      widget.onLoginSuccess(result);
    } catch (e) {
      // 错误处理已在AuthService中完成
      widget.onLoginSuccess(AuthResult.failure(
        type: AuthResultType.failure,
        message: '登录失败，请重试',
      ));
    }
  }

  /// 处理忘记密码
  void _handleForgotPassword() {
    // 显示忘记密码对话框或导航到忘记密码页面
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('忘记密码'),
        content: const Text('忘记密码功能暂未开放，请联系管理员重置密码。'),
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
