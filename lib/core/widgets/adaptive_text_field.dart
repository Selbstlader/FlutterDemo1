import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../services/keyboard_service.dart';

/// 自适应文本输入框
/// 支持键盘适配、自动滚动、输入验证等功能
class AdaptiveTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final EdgeInsets? contentPadding;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final Color? fillColor;
  final bool filled;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final bool enableSuggestions;
  final bool autocorrect;
  final String? scrollControllerKey;
  final bool autoAdjustScroll;
  final Duration scrollAnimationDuration;
  final Curve scrollAnimationCurve;
  final double scrollExtraOffset;
  
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.validator,
    this.autovalidateMode,
    this.contentPadding,
    this.border,
    this.focusedBorder,
    this.errorBorder,
    this.fillColor,
    this.filled = true,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.scrollControllerKey,
    this.autoAdjustScroll = true,
    this.scrollAnimationDuration = const Duration(milliseconds: 300),
    this.scrollAnimationCurve = Curves.easeInOut,
    this.scrollExtraOffset = 20.0,
  });
  
  @override
  State<AdaptiveTextField> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  late final FocusNode _focusNode;
  late final GlobalKey _fieldKey;
  final _keyboardService = KeyboardService();
  
  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _fieldKey = GlobalKey();
    
    // 监听焦点变化
    _focusNode.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }
  
  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      _keyboardService.handleKeyboardShow(context, _focusNode);
      
      if (widget.autoAdjustScroll) {
        // 延迟执行，等待键盘弹出动画
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _focusNode.hasFocus) {
            _keyboardService.ensureVisible(
              context: context,
              widgetKey: _fieldKey,
              scrollControllerKey: widget.scrollControllerKey,
              duration: widget.scrollAnimationDuration,
              curve: widget.scrollAnimationCurve,
              extraOffset: widget.scrollExtraOffset,
            );
          }
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;
      
      return Container(
        key: _fieldKey,
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          onEditingComplete: widget.onEditingComplete,
          validator: widget.validator,
          autovalidateMode: widget.autovalidateMode,
          style: widget.style ?? theme.textTheme.bodyLarge,
          textAlign: widget.textAlign,
          textCapitalization: widget.textCapitalization,
          enableSuggestions: widget.enableSuggestions,
          autocorrect: widget.autocorrect,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            contentPadding: widget.contentPadding ?? 
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: widget.border ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: widget.focusedBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            errorBorder: widget.errorBorder ?? OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
            fillColor: widget.fillColor ?? colorScheme.surface,
            filled: widget.filled,
            labelStyle: widget.labelStyle,
            hintStyle: widget.hintStyle ?? TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ),
      );
    });
  }
}

/// 键盘适配的表单容器
class AdaptiveForm extends StatefulWidget {
  final Widget child;
  final String? scrollControllerKey;
  final EdgeInsets? padding;
  final bool avoidKeyboard;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const AdaptiveForm({
    super.key,
    required this.child,
    this.scrollControllerKey = 'main',
    this.padding,
    this.avoidKeyboard = true,
    this.shrinkWrap = false,
    this.physics,
  });
  
  @override
  State<AdaptiveForm> createState() => _AdaptiveFormState();
}

class _AdaptiveFormState extends State<AdaptiveForm> {
  late final ScrollController _scrollController;
  final _keyboardService = KeyboardService();
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // 注册滚动控制器
    if (widget.scrollControllerKey != null) {
      _keyboardService.registerScrollController(
        widget.scrollControllerKey!,
        _scrollController,
      );
    }
  }
  
  @override
  void dispose() {
    if (widget.scrollControllerKey != null) {
      _keyboardService.unregisterScrollController(widget.scrollControllerKey!);
    }
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final keyboardHeight = _keyboardService.keyboardHeight.value;
      final isKeyboardVisible = _keyboardService.isKeyboardVisible.value;
      
      EdgeInsets effectivePadding = widget.padding ?? const EdgeInsets.all(16);
      
      if (widget.avoidKeyboard && isKeyboardVisible) {
        effectivePadding = effectivePadding.copyWith(
          bottom: effectivePadding.bottom + keyboardHeight,
        );
      }
      
      return SingleChildScrollView(
        controller: _scrollController,
        padding: effectivePadding,
        physics: widget.physics,
        child: widget.child,
      );
    });
  }
}

/// 键盘感知的容器
class KeyboardAwareContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final bool avoidKeyboard;
  final Color? color;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  
  const KeyboardAwareContainer({
    super.key,
    required this.child,
    this.padding,
    this.avoidKeyboard = true,
    this.color,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });
  
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final keyboardService = KeyboardService();
      final keyboardHeight = keyboardService.keyboardHeight.value;
      final isKeyboardVisible = keyboardService.isKeyboardVisible.value;
      
      EdgeInsets effectivePadding = padding ?? EdgeInsets.zero;
      
      if (avoidKeyboard && isKeyboardVisible) {
        effectivePadding = effectivePadding.copyWith(
          bottom: effectivePadding.bottom + keyboardHeight,
        );
      }
      
      return Container(
        width: width,
        height: height,
        padding: effectivePadding,
        color: color,
        decoration: decoration,
        alignment: alignment,
        child: child,
      );
    });
  }
}

/// 键盘适配的底部按钮栏
class AdaptiveBottomBar extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double? elevation;
  final bool avoidKeyboard;
  
  const AdaptiveBottomBar({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.padding,
    this.backgroundColor,
    this.elevation,
    this.avoidKeyboard = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final keyboardService = KeyboardService();
      final keyboardHeight = keyboardService.keyboardHeight.value;
      final isKeyboardVisible = keyboardService.isKeyboardVisible.value;
      final safeAreaPadding = keyboardService.safeAreaPadding.value;
      
      EdgeInsets effectivePadding = padding ?? 
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      
      // 添加安全区域底部内边距
      effectivePadding = effectivePadding.copyWith(
        bottom: effectivePadding.bottom + safeAreaPadding.bottom,
      );
      
      // 如果键盘显示且需要避让，添加键盘高度
      if (avoidKeyboard && isKeyboardVisible) {
        effectivePadding = effectivePadding.copyWith(
          bottom: effectivePadding.bottom + keyboardHeight,
        );
      }
      
      return Container(
        width: double.infinity,
        padding: effectivePadding,
        decoration: BoxDecoration(
          color: backgroundColor ?? Theme.of(context).colorScheme.surface,
          boxShadow: elevation != null ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: elevation!,
              offset: Offset(0, -elevation! / 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: children,
        ),
      );
    });
  }
}