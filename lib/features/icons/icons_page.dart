import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';

/// 图标展示页面
class IconsPage extends StatefulWidget {
  const IconsPage({super.key});
  
  @override
  State<IconsPage> createState() => _IconsPageState();
}

class _IconsPageState extends State<IconsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> tabs = ['Material Icons', 'MDI Icons', 'SVG Icons'];
  
  // Material Icons 示例
  final List<IconData> materialIcons = [
    Icons.home,
    Icons.favorite,
    Icons.star,
    Icons.settings,
    Icons.person,
    Icons.search,
    Icons.notifications,
    Icons.shopping_cart,
    Icons.camera,
    Icons.music_note,
    Icons.phone,
    Icons.email,
    Icons.location_on,
    Icons.calendar_today,
    Icons.bookmark,
    Icons.share,
  ];
  
  // MDI Icons 示例
  final List<IconData> mdiIcons = [
    MdiIcons.heart,
    MdiIcons.account,
    MdiIcons.cog,
    MdiIcons.bell,
    MdiIcons.cart,
    MdiIcons.camera,
    MdiIcons.music,
    MdiIcons.phone,
    MdiIcons.email,
    MdiIcons.mapMarker,
    MdiIcons.calendar,
    MdiIcons.bookmark,
    MdiIcons.share,
    MdiIcons.download,
    MdiIcons.upload,
    MdiIcons.delete,
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('图标管理'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMaterialIcons(),
          _buildMdiIcons(),
          _buildSvgIcons(),
        ],
      ),
    );
  }
  
  Widget _buildMaterialIcons() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium.w),
      child: _buildMaterialIconsContent(),
    );
  }

  Widget _buildMaterialIconsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Material Icons',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppConstants.paddingMedium.h),
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: AppConstants.paddingMedium.w,
              mainAxisSpacing: AppConstants.paddingMedium.h,
            ),
            itemCount: materialIcons.length,
            itemBuilder: (context, index) {
              return _buildIconCard(
                icon: Icon(
                  materialIcons[index],
                  size: AppConstants.iconSizeLarge.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                name: materialIcons[index].toString().split('.').last,
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildMdiIcons() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Material Design Icons',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: AppConstants.paddingMedium.w,
                mainAxisSpacing: AppConstants.paddingMedium.h,
              ),
              itemCount: mdiIcons.length,
              itemBuilder: (context, index) {
                return _buildIconCard(
                  icon: Icon(
                    mdiIcons[index],
                    size: AppConstants.iconSizeLarge.sp,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  name: mdiIcons[index].toString().split('.').last,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSvgIcons() {
    return Padding(
      padding: EdgeInsets.all(AppConstants.paddingMedium.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SVG Icons',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppConstants.paddingMedium.h),
          Text(
            '将SVG图标文件放置在 assets/icons/ 目录下',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          SizedBox(height: AppConstants.paddingLarge.h),
          
          // SVG 图标示例（需要实际的SVG文件）
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingLarge.w),
              child: Column(
                children: [
                  Text(
                    'SVG 图标使用示例',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppConstants.paddingMedium.h),
                  Container(
                    padding: EdgeInsets.all(AppConstants.paddingMedium.w),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                    ),
                    child: const Text(
                      'SvgPicture.asset(\n  "assets/icons/example.svg",\n  width: 24,\n  height: 24,\n  colorFilter: ColorFilter.mode(\n    Colors.blue,\n    BlendMode.srcIn,\n  ),\n)',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
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
  
  Widget _buildIconCard({required Widget icon, required String name}) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('图标: $name'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingSmall.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              SizedBox(height: AppConstants.paddingSmall.h),
              Text(
                name,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}