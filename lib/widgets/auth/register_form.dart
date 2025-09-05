import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signals/signals.dart';
import '../../core/models/auth_models.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/form_components.dart';
import '../../core/widgets/ui_components.dart';
import '../../core/widgets/adaptive_form_field.dart';

/// 注册表单组件
class RegisterForm extends StatefulWidget {
  final Function(AuthResult) onRegisterSuccess;
  final VoidCallback? onSwitchToLogin;

  const RegisterForm({
    super.key,
    required this.onRegisterSuccess,
    this.onSwitchToLogin,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
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
    _displayNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        // _buildDisplayNameField(),
        _buildPasswordField(),
        _buildConfirmPasswordField(),
        // SizedBox(height: 8.h),
        _buildTermsCheckbox(),
        // SizedBox(height: 12.h),
        _buildRegisterButton(),
        if (widget.onSwitchToLogin != null) ...[
          // SizedBox(height: 8.h),
          _buildSwitchToLoginButton(),
        ],
      ],
    );
  }

  /// 构建用户名输入框
  Widget _buildUsernameField() {
    return AdaptiveFormField(
      labelText: '邮箱',
      required: true,
      keyboardAdaptive: true,
      controller: _usernameController,
      hintText: '请输入注册邮箱',
      prefixIcon: const Icon(Icons.person_outline),
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      validator: AppValidators.required,
    );
  }

  /// 构建显示名称输入框
  Widget _buildDisplayNameField() {
    return AdaptiveFormField(
      labelText: '显示名称',
      required: false,
      keyboardAdaptive: true,
      helperText: '可选，用于显示的昵称',
      controller: _displayNameController,
      hintText: '请输入显示名称',
      prefixIcon: const Icon(Icons.badge_outlined),
      enabled: !_isLoading,
      textInputAction: TextInputAction.next,
      validator: null, // Optional field, no validation needed
    );
  }

  /// 构建密码输入框
  Widget _buildPasswordField() {
    return AdaptiveFormField(
      labelText: '密码',
      required: true,
      keyboardAdaptive: true,
      // helperText: '请输入密码',
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
      textInputAction: TextInputAction.next,
      validator: AppValidators.required,
    );
  }

  /// 构建确认密码输入框
  Widget _buildConfirmPasswordField() {
    return AdaptiveFormField(
      labelText: '确认密码',
      required: true,
      keyboardAdaptive: true,
      controller: _confirmPasswordController,
      hintText: '请再次输入密码',
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: IconButton(
        icon: Icon(
          _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
        ),
        onPressed: () {
          setState(() {
            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
          });
        },
      ),
      obscureText: !_isConfirmPasswordVisible,
      enabled: !_isLoading,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _handleRegister(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '此字段为必填项';
        }
        if (value != _passwordController.text) {
          return '两次输入的密码不一致';
        }
        return null;
      },
    );
  }

  /// 构建服务条款复选框
  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _agreeToTerms,
          onChanged: _isLoading
              ? null
              : (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
          activeColor: Theme.of(context).primaryColor,
        ),
        Expanded(
          child: GestureDetector(
            onTap: _isLoading
                ? null
                : () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
                children: [
                  const TextSpan(text: '我已阅读并同意'),
                  TextSpan(
                    text: '《服务条款》',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建注册按钮
  Widget _buildRegisterButton() {
    return SizedBox(
      height: 50.h,
      child: ElevatedButton(
        onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister,
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
                '注册',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  /// 构建切换到登录按钮
  Widget _buildSwitchToLoginButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '已有账户？',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : widget.onSwitchToLogin,
          child: Text(
            '立即登录',
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

  /// 处理注册
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先同意服务条款和隐私政策'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // 隐藏键盘
    FocusScope.of(context).unfocus();

    final request = RegisterRequest(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim().isEmpty
          ? null
          : _displayNameController.text.trim(),
    );

    try {
      final result = await _authService.registerWithUsername(request);
      widget.onRegisterSuccess(result);
    } catch (e) {
      // 错误处理已在AuthService中完成
      widget.onRegisterSuccess(AuthResult.failure(
        type: AuthResultType.failure,
        message: '注册失败，请重试',
      ));
    }
  }
}
