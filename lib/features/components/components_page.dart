import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_constants.dart';

/// UI组件库展示页面
class ComponentsPage extends StatefulWidget {
  const ComponentsPage({super.key});
  
  @override
  State<ComponentsPage> createState() => _ComponentsPageState();
}

class _ComponentsPageState extends State<ComponentsPage> {
  bool switchValue = false;
  bool checkboxValue = false;
  double sliderValue = 50.0;
  String? dropdownValue = '选项1';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI组件库'),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(AppConstants.paddingMedium.w),
        children: [
          // 按钮组件
          _buildSection(
            title: '按钮组件',
            children: [
              Wrap(
                spacing: AppConstants.paddingSmall.w,
                runSpacing: AppConstants.paddingSmall.h,
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated Button'),
                  ),
                  FilledButton(
                    onPressed: () {},
                    child: const Text('Filled Button'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outlined Button'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          
          // 输入组件
          _buildSection(
            title: '输入组件',
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '用户名',
                  hintText: '请输入用户名',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                  ),
                ),
              ),
              SizedBox(height: AppConstants.paddingMedium.h),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '密码',
                  hintText: '请输入密码',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: const Icon(Icons.visibility),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                  ),
                ),
              ),
            ],
          ),
          
          // 选择组件
          _buildSection(
            title: '选择组件',
            children: [
              Row(
                children: [
                  Checkbox(
                    value: checkboxValue,
                    onChanged: (value) {
                      setState(() {
                        checkboxValue = value ?? false;
                      });
                    },
                  ),
                  const Text('复选框'),
                  const Spacer(),
                  const Text('开关'),
                  Switch(
                    value: switchValue,
                    onChanged: (value) {
                      setState(() {
                        switchValue = value;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: AppConstants.paddingMedium.h),
              Text('滑块: ${sliderValue.round()}'),
              Slider(
                value: sliderValue,
                min: 0,
                max: 100,
                divisions: 10,
                label: sliderValue.round().toString(),
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                },
              ),
              SizedBox(height: AppConstants.paddingMedium.h),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                decoration: InputDecoration(
                  labelText: '下拉选择',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium.r),
                  ),
                ),
                items: ['选项1', '选项2', '选项3'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    dropdownValue = value;
                  });
                },
              ),
            ],
          ),
          
          // 展示组件
          _buildSection(
            title: '展示组件',
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: const Text('列表项标题'),
                  subtitle: const Text('这是一个列表项的副标题'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ),
              SizedBox(height: AppConstants.paddingMedium.h),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.paddingMedium.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '卡片标题',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppConstants.paddingSmall.h),
                      Text(
                        '这是一个卡片组件的内容区域，可以包含各种信息和操作按钮。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: AppConstants.paddingMedium.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
                            child: const Text('取消'),
                          ),
                          SizedBox(width: AppConstants.paddingSmall.w),
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('确认'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // 反馈组件
          _buildSection(
            title: '反馈组件',
            children: [
              Wrap(
                spacing: AppConstants.paddingSmall.w,
                runSpacing: AppConstants.paddingSmall.h,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('这是一个 SnackBar 消息'),
                        ),
                      );
                    },
                    child: const Text('显示 SnackBar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('对话框'),
                          content: const Text('这是一个对话框的内容'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('取消'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('确认'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('显示对话框'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          padding: EdgeInsets.all(AppConstants.paddingLarge.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '底部弹窗',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(height: AppConstants.paddingMedium.h),
                              const Text('这是一个底部弹窗的内容'),
                              SizedBox(height: AppConstants.paddingLarge.h),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('关闭'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: const Text('显示底部弹窗'),
                  ),
                ],
              ),
            ],
          ),
          
          // 进度指示器
          _buildSection(
            title: '进度指示器',
            children: [
              const LinearProgressIndicator(),
              SizedBox(height: AppConstants.paddingMedium.h),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircularProgressIndicator(),
                  CircularProgressIndicator.adaptive(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppConstants.paddingMedium.h),
        ...children,
        SizedBox(height: AppConstants.paddingLarge.h),
      ],
    );
  }
}