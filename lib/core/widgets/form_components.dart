import 'package:flutter/material.dart';
import 'ui_components.dart';

/// 表单容器组件
class AppForm extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback? onSubmit;
  final String? submitButtonText;
  final bool autovalidateMode;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final bool showSubmitButton;
  final bool submitButtonLoading;
  final GlobalKey<FormState>? formKey;

  const AppForm({
    super.key,
    required this.children,
    this.onSubmit,
    this.submitButtonText = '提交',
    this.autovalidateMode = false,
    this.padding,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.showSubmitButton = true,
    this.submitButtonLoading = false,
    this.formKey,
  });

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = widget.formKey ?? GlobalKey<FormState>();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: widget.autovalidateMode 
          ? AutovalidateMode.onUserInteraction 
          : AutovalidateMode.disabled,
      child: SingleChildScrollView(
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: widget.crossAxisAlignment,
            mainAxisAlignment: widget.mainAxisAlignment,
            children: [
              ...widget.children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: child,
              )),
              if (widget.showSubmitButton) ...
                [
                  const SizedBox(height: 8),
                  AppButton(
                    text: widget.submitButtonText!,
                    onPressed: widget.submitButtonLoading ? null : _handleSubmit,
                    loading: widget.submitButtonLoading,
                    width: double.infinity,
                  ),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 表单字段包装器
class AppFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;
  final String? helperText;
  final EdgeInsetsGeometry? padding;

  const AppFormField({
    super.key,
    required this.label,
    required this.child,
    this.required = false,
    this.helperText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (required)
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
          child,
          if (helperText != null) ...
            [
              const SizedBox(height: 4),
              Text(
                helperText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
        ],
      ),
    );
  }
}

/// 移动端友好的表格组件
class AppTable extends StatelessWidget {
  final List<AppTableColumn> columns;
  final List<Map<String, dynamic>> data;
  final bool showHeader;
  final EdgeInsetsGeometry? padding;
  final Color? headerBackgroundColor;
  final VoidCallback? onRefresh;
  final bool loading;
  final String? emptyMessage;

  const AppTable({
    super.key,
    required this.columns,
    required this.data,
    this.showHeader = true,
    this.padding,
    this.headerBackgroundColor,
    this.onRefresh,
    this.loading = false,
    this.emptyMessage = '暂无数据',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (data.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget table = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
          headerBackgroundColor ?? colorScheme.surfaceVariant,
        ),
        columns: columns.map((column) => DataColumn(
          label: Text(
            column.title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        )).toList(),
        rows: data.map((row) => DataRow(
          cells: columns.map((column) => DataCell(
            column.builder?.call(row[column.key]) ?? 
            Text(row[column.key]?.toString() ?? ''),
          )).toList(),
        )).toList(),
      ),
    );

    if (onRefresh != null) {
      table = RefreshIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: table,
      );
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: table,
    );
  }
}

/// 表格列定义
class AppTableColumn {
  final String key;
  final String title;
  final Widget Function(dynamic value)? builder;

  const AppTableColumn({
    required this.key,
    required this.title,
    this.builder,
  });
}

/// 数据列表组件（移动端卡片式展示）
class AppDataList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final VoidCallback? onRefresh;
  final bool loading;
  final String? emptyMessage;
  final EdgeInsetsGeometry? padding;
  final double? itemSpacing;
  final ScrollController? scrollController;

  const AppDataList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onRefresh,
    this.loading = false,
    this.emptyMessage = '暂无数据',
    this.padding,
    this.itemSpacing = 8,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                emptyMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget listView = ListView.separated(
      controller: scrollController,
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (context, index) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) => itemBuilder(context, items[index], index),
    );

    if (onRefresh != null) {
      listView = RefreshIndicator(
        onRefresh: () async {
          onRefresh?.call();
        },
        child: listView,
      );
    }

    return listView;
  }
}

/// 搜索栏组件
class AppSearchBar extends StatefulWidget {
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final bool autofocus;
  final EdgeInsetsGeometry? margin;
  final Widget? leading;
  final List<Widget>? actions;

  const AppSearchBar({
    super.key,
    this.hint = '搜索...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.autofocus = false,
    this.margin,
    this.leading,
    this.actions,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
    widget.onChanged?.call(_controller.text);
  }

  void _onClear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: widget.margin ?? const EdgeInsets.all(16),
      child: SearchBar(
        controller: _controller,
        hintText: widget.hint,
        // autofocus: widget.autofocus, // SearchBar不支持autofocus参数
        onSubmitted: widget.onSubmitted,
        leading: widget.leading ?? const Icon(Icons.search),
        trailing: [
          if (_hasText)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _onClear,
            ),
          ...?widget.actions,
        ],
        backgroundColor: WidgetStateProperty.all(colorScheme.surface),
        elevation: WidgetStateProperty.all(2),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }
}

/// 筛选标签组件
class AppFilterChips extends StatelessWidget {
  final List<AppFilterChip> chips;
  final ValueChanged<String>? onChipSelected;
  final String? selectedChip;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double runSpacing;
  final WrapAlignment alignment;

  const AppFilterChips({
    super.key,
    required this.chips,
    this.onChipSelected,
    this.selectedChip,
    this.padding,
    this.spacing = 8,
    this.runSpacing = 8,
    this.alignment = WrapAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        alignment: alignment,
        children: chips.map((chip) {
          final isSelected = selectedChip == chip.value;
          return FilterChip(
            label: Text(chip.label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onChipSelected?.call(chip.value);
              } else {
                onChipSelected?.call('');
              }
            },
            avatar: chip.icon,
            showCheckmark: false,
          );
        }).toList(),
      ),
    );
  }
}

/// 筛选标签数据模型
class AppFilterChip {
  final String label;
  final String value;
  final Widget? icon;

  const AppFilterChip({
    required this.label,
    required this.value,
    this.icon,
  });
}

/// 表单验证器
class AppValidators {
  /// 必填验证
  static String? required(String? value, [String? message]) {
    if (value == null || value.trim().isEmpty) {
      return message ?? '此字段为必填项';
    }
    return null;
  }

  /// 邮箱验证 - 简化为基本存在性检查
  static String? email(String? value, [String? message]) {
    if (value == null || value.isEmpty) {
      return message ?? '邮箱不能为空';
    }
    return null;
  }

  /// 手机号验证 - 简化为基本存在性检查
  static String? phone(String? value, [String? message]) {
    if (value == null || value.isEmpty) {
      return message ?? '手机号不能为空';
    }
    return null;
  }

  /// 最小长度验证 - 简化为基本存在性检查
  static String? Function(String?) minLength(int minLength, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message ?? '此字段为必填项';
      }
      return null;
    };
  }

  /// 最大长度验证 - 简化为基本存在性检查
  static String? Function(String?) maxLength(int maxLength, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return message ?? '此字段为必填项';
      }
      return null;
    };
  }

  /// 组合验证器
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}