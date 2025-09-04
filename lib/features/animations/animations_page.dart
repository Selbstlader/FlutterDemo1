import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';

/// 动画展示页面
class AnimationsPage extends StatefulWidget {
  const AnimationsPage({super.key});
  
  @override
  State<AnimationsPage> createState() => _AnimationsPageState();
}

class _AnimationsPageState extends State<AnimationsPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _fadeController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: AppConstants.defaultAnimationDuration,
      vsync: this,
    );
    
    // 初始化动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _slideController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('动画系统'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium.w),
        child: Column(
          children: [
            // 控制按钮
            Wrap(
              spacing: AppConstants.paddingSmall.w,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_fadeController.isCompleted) {
                      _fadeController.reverse();
                    } else {
                      _fadeController.forward();
                    }
                  },
                  child: const Text('淡入淡出'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_scaleController.isCompleted) {
                      _scaleController.reverse();
                    } else {
                      _scaleController.forward();
                    }
                  },
                  child: const Text('缩放动画'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_rotationController.isAnimating) {
                      _rotationController.stop();
                    } else {
                      _rotationController.repeat();
                    }
                  },
                  child: const Text('旋转动画'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_slideController.isCompleted) {
                      _slideController.reverse();
                    } else {
                      _slideController.forward();
                    }
                  },
                  child: const Text('滑动动画'),
                ),
              ],
            ),
            
            SizedBox(height: AppConstants.paddingLarge.h),
            
            // 动画展示区域
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMedium.w,
                mainAxisSpacing: AppConstants.paddingMedium.h,
                children: [
                  // 淡入淡出动画
                  _buildAnimationCard(
                    title: '淡入淡出',
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  
                  // 缩放动画
                  _buildAnimationCard(
                    title: '缩放动画',
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  
                  // 旋转动画
                  _buildAnimationCard(
                    title: '旋转动画',
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                        ),
                        child: const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                  
                  // 滑动动画
                  _buildAnimationCard(
                    title: '滑动动画',
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        width: 80.w,
                        height: 80.h,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimationCard({required String title, required Widget child}) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.paddingMedium.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppConstants.paddingMedium.h),
            child,
          ],
        ),
      ),
    );
  }
}