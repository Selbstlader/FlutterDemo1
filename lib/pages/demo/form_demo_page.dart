import 'package:flutter/material.dart';
import '../../core/widgets/form_components.dart';
import '../../core/widgets/ui_components.dart';

/// 表单和表格组件演示页面
class FormDemoPage extends StatefulWidget {
  const FormDemoPage({super.key});

  @override
  State<FormDemoPage> createState() => _FormDemoPageState();
}

class _FormDemoPageState extends State<FormDemoPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // 表单控制器
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _searchController = TextEditingController();

  // 状态变量
  bool _formLoading = false;
  bool _tableLoading = false;
  String _selectedFilter = '';

  // 模拟数据
  List<Map<String, dynamic>> _tableData = [
    {
      'id': 1,
      'name': '张三',
      'email': 'zhangsan@example.com',
      'phone': '13800138001',
      'status': '活跃'
    },
    {
      'id': 2,
      'name': '李四',
      'email': 'lisi@example.com',
      'phone': '13800138002',
      'status': '禁用'
    },
    {
      'id': 3,
      'name': '王五',
      'email': 'wangwu@example.com',
      'phone': '13800138003',
      'status': '活跃'
    },
  ];

  List<UserModel> _listData = [
    UserModel(
        id: 1,
        name: '张三',
        email: 'zhangsan@example.com',
        avatar: '👨',
        status: '活跃'),
    UserModel(
        id: 2,
        name: '李四',
        email: 'lisi@example.com',
        avatar: '👩',
        status: '禁用'),
    UserModel(
        id: 3,
        name: '王五',
        email: 'wangwu@example.com',
        avatar: '👨',
        status: '活跃'),
    UserModel(
        id: 4,
        name: '赵六',
        email: 'zhaoliu@example.com',
        avatar: '👩',
        status: '活跃'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('表单和表格组件演示'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '表单', icon: Icon(Icons.edit_note)),
            Tab(text: '表格', icon: Icon(Icons.table_chart)),
            Tab(text: '列表', icon: Icon(Icons.list)),
            Tab(text: '搜索筛选', icon: Icon(Icons.search)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormDemo(),
          _buildTableDemo(),
          _buildListDemo(),
          _buildSearchFilterDemo(),
        ],
      ),
    );
  }

  /// 表单演示
  Widget _buildFormDemo() {
    return SingleChildScrollView(
      child: AppForm(
        submitButtonText: '提交表单',
        submitButtonLoading: _formLoading,
        onSubmit: _handleFormSubmit,
        children: [
          AppFormField(
            label: '姓名',
            required: true,
            child: AppTextField(
              controller: _nameController,
              hint: '请输入姓名',
              validator: AppValidators.required,
            ),
          ),
          AppFormField(
            label: '邮箱',
            required: true,
            helperText: '用于接收重要通知',
            child: AppTextField(
              controller: _emailController,
              hint: '请输入邮箱地址',
              keyboardType: TextInputType.emailAddress,
              validator: AppValidators.combine([
                AppValidators.required,
                AppValidators.email,
              ]),
            ),
          ),
          AppFormField(
            label: '手机号',
            child: AppTextField(
              controller: _phoneController,
              hint: '请输入手机号码',
              keyboardType: TextInputType.phone,
              validator: AppValidators.phone,
            ),
          ),
          AppFormField(
            label: '个人简介',
            child: AppTextField(
              hint: '请输入个人简介（可选）',
              maxLines: 3,
              validator: AppValidators.maxLength(200),
            ),
          ),
        ],
      ),
    );
  }

  /// 表格演示
  Widget _buildTableDemo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '用户列表',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AppButton(
                text: '刷新',
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: const Icon(Icons.refresh),
                onPressed: _refreshTable,
              ),
            ],
          ),
        ),
        Expanded(
          child: AppTable(
            loading: _tableLoading,
            onRefresh: _refreshTable,
            columns: [
              const AppTableColumn(key: 'id', title: 'ID'),
              const AppTableColumn(key: 'name', title: '姓名'),
              const AppTableColumn(key: 'email', title: '邮箱'),
              const AppTableColumn(key: 'phone', title: '手机号'),
              AppTableColumn(
                key: 'status',
                title: '状态',
                builder: (value) => Chip(
                  label: Text(value.toString()),
                  backgroundColor: value == '活跃'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              ),
            ],
            data: _tableData,
          ),
        ),
      ],
    );
  }

  /// 列表演示
  Widget _buildListDemo() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '用户卡片列表',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              AppButton(
                text: '刷新',
                type: ButtonType.secondary,
                size: ButtonSize.small,
                icon: const Icon(Icons.refresh),
                onPressed: _refreshList,
              ),
            ],
          ),
        ),
        Expanded(
          child: AppDataList<UserModel>(
            items: _listData,
            onRefresh: _refreshList,
            itemBuilder: (context, user, index) => AppCard(
              onTap: () => _showUserDetail(user),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    child: Text(
                      user.avatar,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(user.status),
                    backgroundColor: user.status == '活跃'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 搜索筛选演示
  Widget _buildSearchFilterDemo() {
    return Column(
      children: [
        AppSearchBar(
          controller: _searchController,
          hint: '搜索用户姓名或邮箱',
          onChanged: _handleSearch,
          onClear: () => _handleSearch(''),
        ),
        AppFilterChips(
          chips: const [
            AppFilterChip(label: '全部', value: ''),
            AppFilterChip(label: '活跃用户', value: '活跃'),
            AppFilterChip(label: '禁用用户', value: '禁用'),
          ],
          selectedChip: _selectedFilter,
          onChipSelected: _handleFilterChange,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: AppDataList<UserModel>(
            items: _getFilteredUsers(),
            itemBuilder: (context, user, index) => AppCard(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(user.avatar),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                trailing: Chip(
                  label: Text(user.status),
                  backgroundColor: user.status == '活跃'
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 处理表单提交
  void _handleFormSubmit() async {
    setState(() {
      _formLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _formLoading = false;
    });

    if (mounted) {
      AppSnackBar.showSuccess(context, '表单提交成功！');
    }
  }

  /// 刷新表格
  void _refreshTable() async {
    setState(() {
      _tableLoading = true;
    });

    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _tableLoading = false;
    });

    if (mounted) {
      AppSnackBar.showInfo(context, '表格数据已刷新');
    }
  }

  /// 刷新列表
  void _refreshList() async {
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      AppSnackBar.showInfo(context, '列表数据已刷新');
    }
  }

  /// 显示用户详情
  void _showUserDetail(UserModel user) {
    AppBottomSheet.show(
      context,
      title: '用户详情',
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              child: Text(
                user.avatar,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            title: Text(user.name),
            subtitle: Text('ID: ${user.id}'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('邮箱'),
            subtitle: Text(user.email),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('状态'),
            subtitle: Text(user.status),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: '编辑',
                  type: ButtonType.secondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: AppButton(
                  text: '删除',
                  backgroundColor: Colors.red,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 处理搜索
  void _handleSearch(String query) {
    setState(() {
      // 这里可以实现搜索逻辑
    });
  }

  /// 处理筛选变化
  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  /// 获取筛选后的用户列表
  List<UserModel> _getFilteredUsers() {
    var filtered = _listData;

    // 根据搜索关键词筛选
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((user) =>
              user.name.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query))
          .toList();
    }

    // 根据状态筛选
    if (_selectedFilter.isNotEmpty) {
      filtered =
          filtered.where((user) => user.status == _selectedFilter).toList();
    }

    return filtered;
  }
}

/// 用户数据模型
class UserModel {
  final int id;
  final String name;
  final String email;
  final String avatar;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    required this.status,
  });
}
