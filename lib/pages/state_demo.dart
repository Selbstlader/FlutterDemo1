import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';
import '../core/widgets/ui_components.dart';
import '../core/services/state_service.dart';

class StateDemo extends StatefulWidget {
  const StateDemo({super.key});

  @override
  State<StateDemo> createState() => _StateDemoState();
}

class _StateDemoState extends State<StateDemo>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final StateService _stateService = StateService();
  
  // 基础信号演示
  final Signal<int> _counter = signal(0);
  final Signal<String> _text = signal('Hello Signals!');
  final Signal<bool> _isEnabled = signal(true);
  final Signal<double> _slider = signal(50.0);
  final Signal<Color> _selectedColor = signal(Colors.blue);
  
  // 计算信号演示
  late final Computed<String> _counterText;
  late final Computed<bool> _isEven;
  late final Computed<String> _colorName;
  late final Computed<double> _progress;
  
  // 列表信号演示
  final ListSignal<String> _items = listSignal(['Item 1', 'Item 2', 'Item 3']);
  final MapSignal<String, dynamic> _userInfo = mapSignal({
    'name': 'John Doe',
    'age': 25,
    'email': 'john@example.com',
  });
  
  // 异步信号演示
  final Signal<bool> _isLoading = signal(false);
  final Signal<String> _asyncResult = signal('');
  
  // 表单演示
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  
  // Effect演示
  late EffectCleanup _counterEffect;
  late EffectCleanup _colorEffect;
  final Signal<List<String>> _logs = signal([]);
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _initializeComputedSignals();
    _initializeEffects();
    _initializeControllers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _itemController.dispose();
    _counterEffect();
    _colorEffect();
    super.dispose();
  }

  void _initializeComputedSignals() {
    _counterText = computed(() => 'Count: ${_counter.value}');
    _isEven = computed(() => _counter.value % 2 == 0);
    _colorName = computed(() => _getColorName(_selectedColor.value));
    _progress = computed(() => _slider.value / 100);
  }

  void _initializeEffects() {
    // 监听计数器变化
    _counterEffect = effect(() {
      // 使用 untracked 避免循环依赖
      untracked(() {
        _addLog('Counter changed to: ${_counter.value}');
      });
    });
    
    // 监听颜色变化
    _colorEffect = effect(() {
      // 使用 untracked 避免循环依赖
      untracked(() {
        _addLog('Color changed to: ${_getColorName(_selectedColor.value)}');
      });
    });
  }

  void _initializeControllers() {
    _nameController.text = _userInfo.value['name'];
    _emailController.text = _userInfo.value['email'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('状态管理演示'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _resetAll(),
            tooltip: '重置所有状态',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '基础信号', icon: Icon(Icons.radio_button_checked)),
            Tab(text: '计算信号', icon: Icon(Icons.calculate)),
            Tab(text: '集合信号', icon: Icon(Icons.list)),
            Tab(text: '异步状态', icon: Icon(Icons.sync)),
            Tab(text: 'Effect监听', icon: Icon(Icons.visibility)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasicSignalsTab(),
          _buildComputedSignalsTab(),
          _buildCollectionSignalsTab(),
          _buildAsyncStateTab(),
          _buildEffectsTab(),
        ],
      ),
    );
  }

  Widget _buildBasicSignalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('基础信号', '演示Signal的基本用法和响应式更新'),
          const SizedBox(height: 16),
          
          // 计数器演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '计数器信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Center(
                    child: Column(
                      children: [
                        Text(
                          '${_counter.value}',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppButton(
                              text: '-',
                              size: ButtonSize.small,
                              type: ButtonType.secondary,
                              onPressed: () => _counter.value--,
                            ),
                            const SizedBox(width: 16),
                            AppButton(
                              text: 'Reset',
                              size: ButtonSize.small,
                              backgroundColor: Colors.orange,
                              onPressed: () => _counter.value = 0,
                            ),
                            const SizedBox(width: 16),
                            AppButton(
                              text: '+',
                              size: ButtonSize.small,
                              onPressed: () => _counter.value++,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 文本信号演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '文本信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _text.value,
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppButton(
                            text: 'Hello',
                            size: ButtonSize.small,
                            onPressed: () => _text.value = 'Hello Signals!',
                          ),
                          AppButton(
                            text: 'World',
                            size: ButtonSize.small,
                            type: ButtonType.secondary,
                            onPressed: () => _text.value = 'World of Signals!',
                          ),
                          AppButton(
                            text: 'Flutter',
                            size: ButtonSize.small,
                            backgroundColor: Colors.blue,
                            onPressed: () => _text.value = 'Flutter + Signals = 💙',
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 滑块和开关演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '滑块和开关信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Text('启用状态: '),
                          Switch(
                            value: _isEnabled.value,
                            onChanged: (value) => _isEnabled.value = value,
                          ),
                          const Spacer(),
                          Text(_isEnabled.value ? '已启用' : '已禁用'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text('滑块值: ${_slider.value.toInt()}'),
                      Slider(
                        value: _slider.value,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: _isEnabled.value
                            ? (value) => _slider.value = value
                            : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 颜色选择演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '颜色信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _selectedColor.value,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _getColorName(_selectedColor.value),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                        ].map((color) {
                          return GestureDetector(
                            onTap: () => _selectedColor.value = color,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _selectedColor.value == color
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComputedSignalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('计算信号', '演示Computed信号的自动计算和依赖追踪'),
          const SizedBox(height: 16),
          
          // 计算信号演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基于计数器的计算信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      // 显示原始值和计算值
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '原始值',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    '${_counter.value}',
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '计算值',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    _counterText.value,
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 奇偶判断
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _isEven.value ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isEven.value ? '当前数字是偶数' : '当前数字是奇数',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: _isEven.value ? Colors.green.shade800 : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 控制按钮
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AppButton(
                            text: '-5',
                            size: ButtonSize.small,
                            type: ButtonType.secondary,
                            onPressed: () => _counter.value -= 5,
                          ),
                          AppButton(
                            text: '-1',
                            size: ButtonSize.small,
                            type: ButtonType.secondary,
                            onPressed: () => _counter.value--,
                          ),
                          AppButton(
                            text: '+1',
                            size: ButtonSize.small,
                            onPressed: () => _counter.value++,
                          ),
                          AppButton(
                            text: '+5',
                            size: ButtonSize.small,
                            onPressed: () => _counter.value += 5,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 滑块进度计算
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '进度计算信号',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Text(
                        '滑块值: ${_slider.value.toInt()}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _slider.value,
                        min: 0,
                        max: 100,
                        divisions: 100,
                        onChanged: (value) => _slider.value = value,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '计算进度: ${(_progress.value * 100).toInt()}%',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress.value,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 颜色名称计算
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '颜色名称计算',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _selectedColor.value,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '选中颜色',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _colorName.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '点击下方颜色块查看计算信号的自动更新',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                          Colors.pink,
                          Colors.indigo,
                        ].map((color) {
                          return GestureDetector(
                            onTap: () => _selectedColor.value = color,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _selectedColor.value == color
                                    ? Border.all(color: Colors.black, width: 3)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionSignalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('集合信号', '演示ListSignal和MapSignal的响应式集合操作'),
          const SizedBox(height: 16),
          
          // 列表信号演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '列表信号 (ListSignal)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _itemController,
                        label: '新项目',
                        hint: '输入要添加的项目',
                        prefixIcon: const Icon(Icons.add),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: '添加',
                      icon: const Icon(Icons.add),
                      onPressed: () => _addItem(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '项目列表 (${_items.length} 项)',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      if (_items.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '列表为空，添加一些项目吧！',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        )
                      else
                        ...List.generate(_items.length, (index) {
                          final item = _items[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _removeItem(index),
                                  tooltip: '删除',
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          AppButton(
                            text: '清空列表',
                            size: ButtonSize.small,
                            type: ButtonType.secondary,
                            onPressed: _items.isNotEmpty ? () => _clearItems() : null,
                          ),
                          const SizedBox(width: 8),
                          AppButton(
                            text: '随机排序',
                            size: ButtonSize.small,
                            backgroundColor: Colors.orange,
                            onPressed: _items.length > 1 ? () => _shuffleItems() : null,
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 映射信号演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '映射信号 (MapSignal)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    AppTextField(
                      controller: _nameController,
                      label: '姓名',
                      hint: '输入姓名',
                      prefixIcon: const Icon(Icons.person),
                      onChanged: (value) => _updateUserInfo('name', value),
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _emailController,
                      label: '邮箱',
                      hint: '输入邮箱',
                      prefixIcon: const Icon(Icons.email),
                      onChanged: (value) => _updateUserInfo('email', value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '用户信息预览',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text('姓名: ${_userInfo.value['name']}'),
                        Text('年龄: ${_userInfo.value['age']}'),
                        Text('邮箱: ${_userInfo.value['email']}'),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppButton(
                      text: '年龄+1',
                      size: ButtonSize.small,
                      onPressed: () => _incrementAge(),
                    ),
                    const SizedBox(width: 8),
                    AppButton(
                      text: '重置信息',
                      size: ButtonSize.small,
                      type: ButtonType.secondary,
                      onPressed: () => _resetUserInfo(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncStateTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('异步状态', '演示异步操作的状态管理'),
          const SizedBox(height: 16),
          
          // 异步操作演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '异步操作演示',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      if (_isLoading.value)
                        const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('正在加载数据...'),
                          ],
                        )
                      else if (_asyncResult.value.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '异步结果:',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(_asyncResult.value),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '点击下方按钮开始异步操作',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppButton(
                            text: '快速请求 (1s)',
                            size: ButtonSize.small,
                            loading: _isLoading.value,
                            onPressed: _isLoading.value ? null : () => _simulateAsyncOperation(1),
                          ),
                          AppButton(
                            text: '中等请求 (3s)',
                            size: ButtonSize.small,
                            type: ButtonType.secondary,
                            loading: _isLoading.value,
                            onPressed: _isLoading.value ? null : () => _simulateAsyncOperation(3),
                          ),
                          AppButton(
                            text: '慢速请求 (5s)',
                            size: ButtonSize.small,
                            backgroundColor: Colors.orange,
                            loading: _isLoading.value,
                            onPressed: _isLoading.value ? null : () => _simulateAsyncOperation(5),
                          ),
                          AppButton(
                            text: '模拟错误',
                            size: ButtonSize.small,
                            backgroundColor: Colors.red,
                            loading: _isLoading.value,
                            onPressed: _isLoading.value ? null : () => _simulateAsyncError(),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 状态组合演示
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '状态组合演示',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Watch((context) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isLoading.value
                                    ? Colors.orange.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '加载状态',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    _isLoading.value ? '加载中' : '空闲',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _asyncResult.value.contains('错误')
                                    ? Colors.red.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '结果状态',
                                    style: Theme.of(context).textTheme.labelMedium,
                                  ),
                                  Text(
                                    _asyncResult.value.isEmpty
                                        ? '无数据'
                                        : _asyncResult.value.contains('错误')
                                            ? '错误'
                                            : '成功',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppButton(
                        text: '清空结果',
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: _asyncResult.value.isNotEmpty && !_isLoading.value
                            ? () => _clearAsyncResult()
                            : null,
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Effect监听', '演示Effect的副作用监听和日志记录'),
          const SizedBox(height: 16),
          
          // Effect说明
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Effect监听说明',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Effect会自动监听信号的变化，并在信号值改变时执行副作用操作。下面的日志会记录所有被监听的信号变化。',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 控制面板
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '控制面板',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  '修改下面的值来触发Effect监听：',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                
                // 计数器控制
                Watch((context) {
                  return Row(
                    children: [
                      Text('计数器: ${_counter.value}'),
                      const Spacer(),
                      AppButton(
                        text: '-',
                        size: ButtonSize.small,
                        type: ButtonType.secondary,
                        onPressed: () => _counter.value--,
                      ),
                      const SizedBox(width: 8),
                      AppButton(
                        text: '+',
                        size: ButtonSize.small,
                        onPressed: () => _counter.value++,
                      ),
                    ],
                  );
                }),
                
                const SizedBox(height: 16),
                
                // 颜色控制
                Watch((context) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('当前颜色: ${_getColorName(_selectedColor.value)}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Colors.red,
                          Colors.green,
                          Colors.blue,
                          Colors.orange,
                          Colors.purple,
                          Colors.teal,
                        ].map((color) {
                          return GestureDetector(
                            onTap: () => _selectedColor.value = color,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: _selectedColor.value == color
                                    ? Border.all(color: Colors.black, width: 2)
                                    : null,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 日志显示
          Watch((context) {
            return AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Effect日志 (${_logs.value.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _clearEffectLogs(),
                        tooltip: '清空日志',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _logs.value.isEmpty
                        ? Center(
                            child: Text(
                              '暂无日志，修改上面的值来触发Effect',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _logs.value.length,
                            itemBuilder: (context, index) {
                              final log = _logs.value[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  '[${DateTime.now().toString().substring(11, 19)}] $log',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontFamily: 'monospace',
                                      ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return '红色';
    if (color == Colors.green) return '绿色';
    if (color == Colors.blue) return '蓝色';
    if (color == Colors.orange) return '橙色';
    if (color == Colors.purple) return '紫色';
    if (color == Colors.teal) return '青色';
    if (color == Colors.pink) return '粉色';
    if (color == Colors.indigo) return '靛蓝';
    return '未知颜色';
  }

  void _addItem() {
    final text = _itemController.text.trim();
    if (text.isNotEmpty) {
      _items.add(text);
      _itemController.clear();
    }
  }

  void _removeItem(int index) {
    _items.removeAt(index);
  }

  void _clearItems() {
    _items.clear();
  }

  void _shuffleItems() {
    _items.shuffle();
  }

  void _updateUserInfo(String key, String value) {
    _userInfo.value = {
      ..._userInfo.value,
      key: value,
    };
  }

  void _incrementAge() {
    _userInfo.value = {
      ..._userInfo.value,
      'age': (_userInfo.value['age'] as int) + 1,
    };
  }

  void _resetUserInfo() {
    _userInfo.value = {
      'name': 'John Doe',
      'age': 25,
      'email': 'john@example.com',
    };
    _nameController.text = 'John Doe';
    _emailController.text = 'john@example.com';
  }

  void _simulateAsyncOperation(int seconds) async {
    _isLoading.value = true;
    _asyncResult.value = '';
    
    try {
      await Future.delayed(Duration(seconds: seconds));
      _asyncResult.value = '异步操作成功完成！\n耗时: ${seconds}秒\n时间: ${DateTime.now().toString()}';
    } catch (e) {
      _asyncResult.value = '异步操作失败: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _simulateAsyncError() async {
    _isLoading.value = true;
    _asyncResult.value = '';
    
    try {
      await Future.delayed(const Duration(seconds: 2));
      throw Exception('模拟的网络错误');
    } catch (e) {
      _asyncResult.value = '操作失败: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _clearAsyncResult() {
    _asyncResult.value = '';
  }

  void _addLog(String log) {
    final newLogs = List<String>.from(_logs.value);
    newLogs.add(log);
    if (newLogs.length > 50) {
      newLogs.removeAt(0); // 保持日志数量在50条以内
    }
    _logs.value = newLogs;
  }

  void _clearEffectLogs() {
    _logs.value = [];
  }

  void _resetAll() {
    _counter.value = 0;
    _text.value = 'Hello Signals!';
    _isEnabled.value = true;
    _slider.value = 50.0;
    _selectedColor.value = Colors.blue;
    _items.clear();
    _items.addAll(['Item 1', 'Item 2', 'Item 3']);
    _resetUserInfo();
    _clearAsyncResult();
    _clearEffectLogs();
    _itemController.clear();
  }
}