import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 用户资料页面
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  
  bool _isEditing = false;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = '中文';
  
  // 模拟用户数据
  final UserProfile _userProfile = UserProfile(
    name: '张三',
    email: 'zhangsan@example.com',
    phone: '+86 138 0013 8000',
    bio: '这是一个简单的个人简介，展示用户的基本信息和兴趣爱好。',
    avatar: 'https://via.placeholder.com/150',
    joinDate: DateTime(2023, 1, 15),
    lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
  );

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  /// 加载用户数据
  void _loadUserData() {
    _nameController.text = _userProfile.name;
    _emailController.text = _userProfile.email;
    _phoneController.text = _userProfile.phone;
    _bioController.text = _userProfile.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleEditMode,
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            tooltip: _isEditing ? '保存' : '编辑',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),
            _buildProfileForm(),
            const SizedBox(height: 16),
            _buildSettingsSection(),
            const SizedBox(height: 16),
            _buildStatsSection(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// 构建资料头部
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: NetworkImage(_userProfile.avatar),
                      onBackgroundImageError: (_, __) {},
                      child: _userProfile.avatar.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _changeAvatar,
                          icon: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _userProfile.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userProfile.email,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    '加入时间',
                    _formatDate(_userProfile.joinDate),
                    Icons.calendar_today,
                  ),
                  _buildInfoItem(
                    '最后登录',
                    _formatRelativeTime(_userProfile.lastLogin),
                    Icons.access_time,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建信息项
  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.9),
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 构建资料表单
  Widget _buildProfileForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '基本信息',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    labelText: '姓名',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入姓名';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: '邮箱',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '手机号',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入手机号';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bioController,
                  enabled: _isEditing,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: '个人简介',
                    prefixIcon: Icon(Icons.description),
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建设置区域
  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '应用设置',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('推送通知'),
                subtitle: const Text('接收应用推送消息'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                secondary: const Icon(Icons.notifications),
              ),
              SwitchListTile(
                title: const Text('深色模式'),
                subtitle: const Text('使用深色主题'),
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
                secondary: const Icon(Icons.dark_mode),
              ),
              ListTile(
                title: const Text('语言设置'),
                subtitle: Text(_selectedLanguage),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showLanguageSelector,
              ),
              const Divider(),
              ListTile(
                title: const Text('清除缓存'),
                subtitle: const Text('清理应用缓存数据'),
                leading: const Icon(Icons.cleaning_services),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _clearCache,
              ),
              ListTile(
                title: const Text('关于应用'),
                subtitle: const Text('版本信息和帮助'),
                leading: const Icon(Icons.info),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showAbout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计区域
  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '使用统计',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '登录次数',
                      '156',
                      Icons.login,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '使用天数',
                      '89',
                      Icons.calendar_month,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '数据同步',
                      '2.3MB',
                      Icons.sync,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      '活跃度',
                      '85%',
                      Icons.trending_up,
                      Colors.purple,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 切换编辑模式
  void _toggleEditMode() {
    if (_isEditing) {
      // 保存数据
      if (_formKey.currentState?.validate() ?? false) {
        _saveProfile();
      } else {
        return;
      }
    }
    
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  /// 保存资料
  void _saveProfile() {
    // 模拟保存操作
    _userProfile.name = _nameController.text.trim();
    _userProfile.email = _emailController.text.trim();
    _userProfile.phone = _phoneController.text.trim();
    _userProfile.bio = _bioController.text.trim();
    
    _showSnackBar('资料保存成功');
  }

  /// 更换头像
  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('拍照功能待实现');
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('相册选择功能待实现');
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示语言选择器
  void _showLanguageSelector() {
    final languages = ['中文', 'English', '日本語', '한국어'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('语言已切换到 $value');
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 清除缓存
  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存数据吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('缓存清除成功');
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 显示关于信息
  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Flutter Demo',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 64),
      children: [
        const Text('这是一个Flutter演示应用，展示了各种功能和组件的使用。'),
        const SizedBox(height: 16),
        const Text('开发者：Flutter Team'),
        const Text('联系方式：support@flutter.dev'),
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }

  /// 格式化相对时间
  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  /// 显示提示信息
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// 用户资料模型
class UserProfile {
  String name;
  String email;
  String phone;
  String bio;
  String avatar;
  DateTime joinDate;
  DateTime lastLogin;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    required this.avatar,
    required this.joinDate,
    required this.lastLogin,
  });
}