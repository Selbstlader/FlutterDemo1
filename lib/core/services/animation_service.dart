import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../models/app_models.dart';

/// 动画服务
class AnimationService {
  static final AnimationService _instance = AnimationService._internal();
  factory AnimationService() => _instance;
  AnimationService._internal();

  // 动画控制器缓存
  final Map<String, AnimationController> _controllers = {};
  
  // Rive动画控制器缓存
  final Map<String, RiveAnimationController> _riveControllers = {};

  /// 初始化动画服务
  static void init() {
  }

  /// 释放动画服务
  static void dispose() {
    _instance.disposeAllControllers();
    _instance.disposeAllRiveControllers();
  }

  /// 创建动画控制器
  AnimationController createController({
    required String id,
    required Duration duration,
    required TickerProvider vsync,
    Duration? reverseDuration,
    String? debugLabel,
  }) {
    // 如果已存在，先释放旧的控制器
    disposeController(id);
    
    final controller = AnimationController(
      duration: duration,
      reverseDuration: reverseDuration,
      vsync: vsync,
      debugLabel: debugLabel ?? id,
    );
    
    _controllers[id] = controller;
    
    return controller;
  }

  /// 获取动画控制器
  AnimationController? getController(String id) {
    return _controllers[id];
  }

  /// 释放动画控制器
  void disposeController(String id) {
    final controller = _controllers.remove(id);
    controller?.dispose();
  }

  /// 释放所有动画控制器
  void disposeAllControllers() {
    for (final entry in _controllers.entries) {
      entry.value.dispose();
    }
    _controllers.clear();
  }

  /// 创建Rive动画控制器
  RiveAnimationController createRiveController({
    required String id,
    required String animationName,
    bool autoplay = true,
  }) {
    // 如果已存在，先释放旧的控制器
    disposeRiveController(id);
    
    final controller = SimpleAnimation(
      animationName,
      autoplay: autoplay,
    );
    
    _riveControllers[id] = controller;
    
    return controller;
  }

  /// 获取Rive动画控制器
  RiveAnimationController? getRiveController(String id) {
    return _riveControllers[id];
  }

  /// 释放Rive动画控制器
  void disposeRiveController(String id) {
    final controller = _riveControllers.remove(id);
    controller?.dispose();
  }

  /// 释放所有Rive动画控制器
  void disposeAllRiveControllers() {
    for (final entry in _riveControllers.entries) {
      entry.value.dispose();
    }
    _riveControllers.clear();
  }

  /// 创建淡入淡出动画
  Animation<double> createFadeAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// 创建缩放动画
  Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.elasticOut,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// 创建滑动动画
  Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
    Curve curve = Curves.easeInOut,
  }) {
    return Tween<Offset>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// 创建旋转动画
  Animation<double> createRotationAnimation(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
    Curve curve = Curves.linear,
  }) {
    return Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// 创建颜色动画
  Animation<Color?> createColorAnimation(
    AnimationController controller, {
    required Color begin,
    required Color end,
    Curve curve = Curves.easeInOut,
  }) {
    return ColorTween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: curve,
    ));
  }

  /// 创建序列动画
  Animation<double> createSequenceAnimation(
    AnimationController controller,
    List<TweenSequenceItem<double>> items,
  ) {
    return TweenSequence<double>(items).animate(controller);
  }

  /// 播放动画
  Future<void> playAnimation(String controllerId) async {
    final controller = getController(controllerId);
    if (controller != null) {
      await controller.forward();
    }
  }

  /// 反向播放动画
  Future<void> reverseAnimation(String controllerId) async {
    final controller = getController(controllerId);
    if (controller != null) {
      await controller.reverse();
    }
  }

  /// 重置动画
  void resetAnimation(String controllerId) {
    final controller = getController(controllerId);
    if (controller != null) {
      controller.reset();
    }
  }

  /// 停止动画
  void stopAnimation(String controllerId) {
    final controller = getController(controllerId);
    if (controller != null) {
      controller.stop();
    }
  }

  /// 播放Rive动画
  void playRiveAnimation(String controllerId) {
    final controller = getRiveController(controllerId);
    if (controller is SimpleAnimation) {
      controller.isActive = true;
    }
  }

  /// 停止Rive动画
  void stopRiveAnimation(String controllerId) {
    final controller = getRiveController(controllerId);
    if (controller is SimpleAnimation) {
      controller.isActive = false;
    }
  }
}

/// 动画组件基类
abstract class AnimatedWidget extends StatefulWidget {
  final AnimationConfig? config;
  
  const AnimatedWidget({
    super.key,
    this.config,
  });
}

/// 淡入淡出动画组件
class FadeInWidget extends AnimatedWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const FadeInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.autoPlay = true,
    this.onComplete,
    super.config,
  });

  @override
  State<FadeInWidget> createState() => _FadeInWidgetState();
}

class _FadeInWidgetState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}

/// 滑入动画组件
class SlideInWidget extends AnimatedWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final Offset begin;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const SlideInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.begin = const Offset(1.0, 0.0),
    this.autoPlay = true,
    this.onComplete,
    super.config,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<Offset>(
      begin: widget.begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}

/// 缩放动画组件
class ScaleInWidget extends AnimatedWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double begin;
  final bool autoPlay;
  final VoidCallback? onComplete;

  const ScaleInWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.elasticOut,
    this.begin = 0.0,
    this.autoPlay = true,
    this.onComplete,
    super.config,
  });

  @override
  State<ScaleInWidget> createState() => _ScaleInWidgetState();
}

class _ScaleInWidgetState extends State<ScaleInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: widget.begin,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    if (widget.autoPlay) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: widget.child,
    );
  }
}

/// 页面转场动画
class PageTransitions {
  /// 淡入淡出转场
  static PageRouteBuilder fadeTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// 滑动转场
  static PageRouteBuilder slideTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
    Offset begin = const Offset(1.0, 0.0),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return SlideTransition(
          position: slideAnimation,
          child: child,
        );
      },
    );
  }

  /// 缩放转场
  static PageRouteBuilder scaleTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        ));

        return ScaleTransition(
          scale: scaleAnimation,
          child: child,
        );
      },
    );
  }

  /// 旋转转场
  static PageRouteBuilder rotationTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final rotationAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ));

        return RotationTransition(
          turns: rotationAnimation,
          child: child,
        );
      },
    );
  }
}

/// 加载动画组件
class LoadingAnimation extends StatefulWidget {
  final AnimationType type;
  final Color? color;
  final double size;
  final Duration duration;

  const LoadingAnimation({
    super.key,
    this.type = AnimationType.fade,
    this.color,
    this.size = 24.0,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;
    
    switch (widget.type) {
      case AnimationType.fade:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: (_controller.value * 2 - 1).abs(),
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      case AnimationType.scale:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = 0.5 + (0.5 * (1 - (_controller.value - 0.5).abs() * 2));
            return Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      case AnimationType.rotation:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _controller.value * 2 * 3.14159,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          },
        );
      case AnimationType.slide:
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final offset = Offset((_controller.value - 0.5) * 2, 0);
            return Transform.translate(
              offset: offset * widget.size,
              child: Container(
                width: widget.size / 2,
                height: widget.size / 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      default:
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            color: color,
          ),
        );
    }
  }


}