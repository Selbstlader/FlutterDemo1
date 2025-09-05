import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../services/loading_service.dart';

/// 全局加载覆盖组件
class LoadingOverlayWidget extends StatelessWidget {
  final Widget child;
  final bool showGlobalLoading;
  final String? customMessage;
  final Color? overlayColor;
  final Color? indicatorColor;

  const LoadingOverlayWidget({
    super.key,
    required this.child,
    this.showGlobalLoading = true,
    this.customMessage,
    this.overlayColor,
    this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!showGlobalLoading) {
      return child;
    }

    final loadingService = LoadingService();
    final theme = Theme.of(context);

    return Stack(
      children: [
        child,
        Watch((context) {
          final isLoading = loadingService.globalLoading.value;
          final message = loadingService.globalMessage.value;
          
          if (!isLoading) {
            return const SizedBox.shrink();
          }

          return Container(
            color: overlayColor ?? Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            indicatorColor ?? theme.colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        customMessage ?? message ?? '加载中...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// 局部加载指示器组件
class LocalLoadingIndicator extends StatelessWidget {
  final String loadingId;
  final Widget child;
  final Widget? loadingWidget;
  final bool showMessage;
  final EdgeInsetsGeometry? padding;

  const LocalLoadingIndicator({
    super.key,
    required this.loadingId,
    required this.child,
    this.loadingWidget,
    this.showMessage = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final loadingService = LoadingService();
    final theme = Theme.of(context);

    return Watch((context) {
      final loadingState = loadingService.getLoadingState(loadingId);
      final isLoading = loadingState?.isLoading ?? false;

      if (!isLoading) {
        return child;
      }

      return Container(
        padding: padding,
        child: loadingWidget ??
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (showMessage && loadingState?.message != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    loadingState!.message!,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
      );
    });
  }
}

/// 带加载状态的按钮组件
class LoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final String? operationId;
  final String? loadingText;
  final Widget? icon;
  final ButtonStyle? style;
  final bool preventDuplicate;

  const LoadingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.operationId,
    this.loadingText,
    this.icon,
    this.style,
    this.preventDuplicate = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingService = LoadingService();
    final opId = operationId ?? text;

    return Watch((context) {
      final isLoading = loadingService.isOperationPending(opId);
      final isDisabled = onPressed == null || isLoading;

      Widget buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          else if (icon != null)
            icon!,
          if ((isLoading || icon != null) && text.isNotEmpty)
            const SizedBox(width: 8),
          Text(isLoading ? (loadingText ?? '处理中...') : text),
        ],
      );

      return ElevatedButton(
        onPressed: isDisabled
            ? null
            : () async {
                if (preventDuplicate && !loadingService.startOperation(opId)) {
                  return; // 防止重复提交
                }
                
                try {
                  onPressed?.call();
                } finally {
                  if (preventDuplicate) {
                    loadingService.completeOperation(opId);
                  }
                }
              },
        style: style,
        child: buttonChild,
      );
    });
  }
}

/// 带加载状态的刷新指示器
class LoadingRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? operationId;
  final bool preventDuplicate;

  const LoadingRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.operationId,
    this.preventDuplicate = true,
  });

  @override
  Widget build(BuildContext context) {
    final loadingService = LoadingService();
    final opId = operationId ?? 'refresh';

    return RefreshIndicator(
      onRefresh: () async {
        if (preventDuplicate && !loadingService.startOperation(opId)) {
          return; // 防止重复刷新
        }
        
        try {
          await onRefresh();
        } finally {
          if (preventDuplicate) {
            loadingService.completeOperation(opId);
          }
        }
      },
      child: child,
    );
  }
}

/// 加载状态构建器
class LoadingBuilder extends StatelessWidget {
  final String? loadingId;
  final Widget Function(BuildContext context, bool isLoading, LoadingState? state) builder;

  const LoadingBuilder({
    super.key,
    this.loadingId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final loadingService = LoadingService();

    return Watch((context) {
      if (loadingId != null) {
        final state = loadingService.getLoadingState(loadingId!);
        return builder(context, state?.isLoading ?? false, state);
      } else {
        final isGlobalLoading = loadingService.globalLoading.value;
        final hasAnyLoading = loadingService.loadingStates.value.isNotEmpty;
        return builder(context, isGlobalLoading || hasAnyLoading, null);
      }
    });
  }
}

/// 加载状态监听器
class LoadingListener extends StatefulWidget {
  final Widget child;
  final void Function(bool isLoading)? onLoadingChanged;
  final void Function(LoadingState state)? onLoadingStarted;
  final void Function(String id)? onLoadingStopped;

  const LoadingListener({
    super.key,
    required this.child,
    this.onLoadingChanged,
    this.onLoadingStarted,
    this.onLoadingStopped,
  });

  @override
  State<LoadingListener> createState() => _LoadingListenerState();
}

class _LoadingListenerState extends State<LoadingListener> {
  late final Effect _loadingEffect;
  bool _previousLoading = false;
  Set<String> _previousLoadingIds = {};

  @override
  void initState() {
    super.initState();
    final loadingService = LoadingService();
    
    _loadingEffect = Effect(() {
      final isGlobalLoading = loadingService.globalLoading.value;
      final loadingStates = loadingService.loadingStates.value;
      final hasAnyLoading = isGlobalLoading || loadingStates.isNotEmpty;
      
      // 检查总体加载状态变化
      if (_previousLoading != hasAnyLoading) {
        _previousLoading = hasAnyLoading;
        widget.onLoadingChanged?.call(hasAnyLoading);
      }
      
      // 检查新开始的加载
      final currentLoadingIds = loadingStates.keys.toSet();
      final newLoadingIds = currentLoadingIds.difference(_previousLoadingIds);
      for (final id in newLoadingIds) {
        final state = loadingStates[id];
        if (state != null) {
          widget.onLoadingStarted?.call(state);
        }
      }
      
      // 检查已停止的加载
      final stoppedLoadingIds = _previousLoadingIds.difference(currentLoadingIds);
      for (final id in stoppedLoadingIds) {
        widget.onLoadingStopped?.call(id);
      }
      
      _previousLoadingIds = currentLoadingIds;
    });
  }

  @override
  void dispose() {
    _loadingEffect.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}