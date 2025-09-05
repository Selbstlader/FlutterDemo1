import 'package:flutter/material.dart';
import 'adaptive_text_field.dart';
import '../services/keyboard_service.dart';

/// 自适应表单字段组件
/// 支持键盘适配和自动滚动
class AdaptiveFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final bool keyboardAdaptive;
  final bool required;
  final EdgeInsetsGeometry? margin;

  const AdaptiveFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.border,
    this.keyboardAdaptive = true,
    this.required = false,
    this.margin,
  });

  @override
  State<AdaptiveFormField> createState() => _AdaptiveFormFieldState();
}

class _AdaptiveFormFieldState extends State<AdaptiveFormField> {
  late FocusNode _focusNode;
  final _keyboardService = KeyboardService();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    
    if (widget.keyboardAdaptive) {
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    if (widget.keyboardAdaptive) {
      _focusNode.removeListener(_onFocusChanged);
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && widget.keyboardAdaptive) {
      // 延迟执行，确保键盘已经显示
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _focusNode.hasFocus) {
          _keyboardService.ensureVisible(
            context: context,
            widgetKey: GlobalKey(),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget field;
    
    if (widget.keyboardAdaptive) {
      field = AdaptiveTextField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSubmitted: widget.onFieldSubmitted,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        autofocus: widget.autofocus,
        labelText: widget.labelText,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding as EdgeInsets?,
        border: widget.border,
      );
    } else {
      field = TextFormField(
        controller: widget.controller,
        focusNode: _focusNode,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        maxLength: widget.maxLength,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          helperText: widget.helperText,
          errorText: widget.errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          contentPadding: widget.contentPadding as EdgeInsets?,
          border: widget.border,
        ),
      );
    }

    // 添加必填标记
    if (widget.required && widget.labelText != null) {
      field = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.labelText!,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                ' *',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onFieldSubmitted,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            maxLength: widget.maxLength,
            autofocus: widget.autofocus,
            decoration: InputDecoration(
              hintText: widget.hintText,
              helperText: widget.helperText,
              errorText: widget.errorText,
              prefixIcon: widget.prefixIcon,
              suffixIcon: widget.suffixIcon,
              contentPadding: widget.contentPadding,
              border: widget.border,
            ),
          ),
        ],
      );
    }

    if (widget.margin != null) {
      field = Padding(
        padding: widget.margin!,
        child: field,
      );
    }

    return field;
  }
}

/// 快速创建常用表单字段的工厂方法
class FormFields {
  /// 创建邮箱输入字段
  static AdaptiveFormField email({
    Key? key,
    TextEditingController? controller,
    String? labelText = '邮箱',
    String? hintText = '请输入邮箱地址',
    bool required = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool keyboardAdaptive = true,
  }) {
    return AdaptiveFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      keyboardAdaptive: keyboardAdaptive,
      prefixIcon: const Icon(Icons.email_outlined),
    );
  }

  /// 创建密码输入字段
  static AdaptiveFormField password({
    Key? key,
    TextEditingController? controller,
    String? labelText = '密码',
    String? hintText = '请输入密码',
    bool required = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool keyboardAdaptive = true,
  }) {
    return AdaptiveFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      obscureText: true,
      textInputAction: TextInputAction.done,
      validator: validator,
      onChanged: onChanged,
      keyboardAdaptive: keyboardAdaptive,
      prefixIcon: const Icon(Icons.lock_outlined),
    );
  }

  /// 创建手机号输入字段
  static AdaptiveFormField phone({
    Key? key,
    TextEditingController? controller,
    String? labelText = '手机号',
    String? hintText = '请输入手机号',
    bool required = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool keyboardAdaptive = true,
  }) {
    return AdaptiveFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      keyboardAdaptive: keyboardAdaptive,
      prefixIcon: const Icon(Icons.phone_outlined),
    );
  }

  /// 创建用户名输入字段
  static AdaptiveFormField username({
    Key? key,
    TextEditingController? controller,
    String? labelText = '用户名',
    String? hintText = '请输入用户名',
    bool required = false,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool keyboardAdaptive = true,
  }) {
    return AdaptiveFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      textInputAction: TextInputAction.next,
      validator: validator,
      onChanged: onChanged,
      keyboardAdaptive: keyboardAdaptive,
      prefixIcon: const Icon(Icons.person_outlined),
    );
  }

  /// 创建多行文本输入字段
  static AdaptiveFormField multiline({
    Key? key,
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    bool required = false,
    int maxLines = 3,
    int? maxLength,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    bool keyboardAdaptive = true,
  }) {
    return AdaptiveFormField(
      key: key,
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      required: required,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: TextInputAction.newline,
      validator: validator,
      onChanged: onChanged,
      keyboardAdaptive: keyboardAdaptive,
    );
  }
}