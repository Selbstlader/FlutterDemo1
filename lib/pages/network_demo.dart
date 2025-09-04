import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/services/network_service.dart';

/// 网络演示页面
class NetworkDemo extends StatefulWidget {
  const NetworkDemo({super.key});

  @override
  State<NetworkDemo> createState() => _NetworkDemoState();
}

class _NetworkDemoState extends State<NetworkDemo> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  String _selectedMethod = 'GET';
  
  final List<String> _httpMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];
  
  // 预设的API示例
  final List<ApiExample> _apiExamples = [
    ApiExample(
      name: 'JSONPlaceholder - 获取用户列表',
      method: 'GET',
      url: 'https://jsonplaceholder.typicode.com/users',
      description: '获取示例用户数据',
    ),
    ApiExample(
      name: 'JSONPlaceholder - 获取文章列表',
      method: 'GET',
      url: 'https://jsonplaceholder.typicode.com/posts',
      description: '获取示例文章数据',
    ),
    ApiExample(
      name: 'HTTPBin - 测试POST请求',
      method: 'POST',
      url: 'https://httpbin.org/post',
      body: '{"name": "测试用户", "email": "test@example.com"}',
      description: '测试POST请求功能',
    ),
    ApiExample(
      name: 'HTTPBin - 获取IP信息',
      method: 'GET',
      url: 'https://httpbin.org/ip',
      description: '获取当前IP地址',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 初始化网络服务
    NetworkService.init();
    // 设置默认URL
    _urlController.text = _apiExamples.first.url;
  }

  @override
  void dispose() {
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('网络请求演示'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApiExamplesSection(),
            const SizedBox(height: 24),
            _buildRequestConfigSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildResponseSection(),
          ],
        ),
      ),
    );
  }

  /// 构建API示例区域
  Widget _buildApiExamplesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'API 示例',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._apiExamples.map((example) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(example.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(example.description),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              example.method,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getMethodColor(example.method),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              example.url,
                              style: Theme.of(context).textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _loadExample(example),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  /// 构建请求配置区域
  Widget _buildRequestConfigSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '请求配置',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // HTTP方法选择
            Text(
              'HTTP 方法',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _httpMethods.map((method) {
                return ChoiceChip(
                  label: Text(method),
                  selected: _selectedMethod == method,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedMethod = method;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // URL输入
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API URL',
                hintText: '请输入API地址',
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 16),
            // 请求体输入（仅对POST、PUT、PATCH显示）
            if (_selectedMethod != 'GET' && _selectedMethod != 'DELETE') ...[
              const SizedBox(height: 16),
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: '请求体 (JSON)',
                  hintText: '请输入JSON格式的请求数据',
                  prefixIcon: Icon(Icons.code),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _sendRequest,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_isLoading ? '请求中...' : '发送请求'),
          ),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          onPressed: _clearResponse,
          icon: const Icon(Icons.clear),
          label: const Text('清空响应'),
        ),
      ],
    );
  }

  /// 构建响应区域
  Widget _buildResponseSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '响应结果',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (_response.isNotEmpty)
                  IconButton(
                    onPressed: _copyResponse,
                    icon: const Icon(Icons.copy),
                    tooltip: '复制响应',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: _response.isEmpty
                  ? Text(
                      '响应内容将显示在这里...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : SelectableText(
                      _response,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// 加载示例
  void _loadExample(ApiExample example) {
    setState(() {
      _selectedMethod = example.method;
      _urlController.text = example.url;
      _bodyController.text = example.body ?? '';
    });
  }

  /// 发送网络请求
  Future<void> _sendRequest() async {
    if (_urlController.text.trim().isEmpty) {
      _showSnackBar('请输入API地址');
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      dynamic response;
      final url = _urlController.text.trim();
      
      switch (_selectedMethod) {
        case 'GET':
          response = await NetworkService.get(url);
          break;
        case 'POST':
          final body = _parseRequestBody();
          response = await NetworkService.post(url, data: body);
          break;
        case 'PUT':
          final body = _parseRequestBody();
          response = await NetworkService.put(url, data: body);
          break;
        case 'DELETE':
          response = await NetworkService.delete(url);
          break;
        case 'PATCH':
          final body = _parseRequestBody();
          response = await NetworkService.patch(url, data: body);
          break;
      }

      setState(() {
        _response = _formatResponse(response);
      });
      
      _showSnackBar('请求成功');
    } catch (e) {
      setState(() {
        _response = '请求失败：\n${e.toString()}';
      });
      _showSnackBar('请求失败');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 解析请求体
  dynamic _parseRequestBody() {
    final bodyText = _bodyController.text.trim();
    if (bodyText.isEmpty) return null;
    
    try {
      // 尝试解析为JSON
      return bodyText;
    } catch (e) {
      return bodyText;
    }
  }

  /// 格式化响应
  String _formatResponse(dynamic response) {
    if (response == null) return 'null';
    
    try {
      // 如果是字符串，尝试格式化JSON
      if (response is String) {
        return response;
      }
      
      // 转换为格式化的JSON字符串
      return response.toString();
    } catch (e) {
      return response.toString();
    }
  }

  /// 清空响应
  void _clearResponse() {
    setState(() {
      _response = '';
    });
  }

  /// 复制响应
  void _copyResponse() {
    // 这里可以实现复制到剪贴板的功能
    _showSnackBar('响应已复制到剪贴板');
  }

  /// 获取HTTP方法对应的颜色
  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.green.withOpacity(0.2);
      case 'POST':
        return Colors.blue.withOpacity(0.2);
      case 'PUT':
        return Colors.orange.withOpacity(0.2);
      case 'DELETE':
        return Colors.red.withOpacity(0.2);
      case 'PATCH':
        return Colors.purple.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
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

/// API示例模型
class ApiExample {
  final String name;
  final String method;
  final String url;
  final String description;
  final String? body;

  const ApiExample({
    required this.name,
    required this.method,
    required this.url,
    required this.description,
    this.body,
  });
}