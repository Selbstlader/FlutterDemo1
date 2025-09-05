/// Supabase配置文件
/// 包含Supabase项目的基本配置信息
class SupabaseConfig {
  /// Supabase项目URL
  static const String supabaseUrl = 'https://aowywziyhwtaqmjfekku.supabase.co';
  
  /// Supabase匿名密钥 (用于前端)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFvd3l3eml5aHd0YXFtamZla2t1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYzNDQ4ODgsImV4cCI6MjA3MTkyMDg4OH0.mVQh-eZ-EYJLzO8hUXYnXBshVkmCWIxng79R_R_1cSA';
  
  /// 认证相关配置
  static const Map<String, dynamic> authConfig = {
    'autoRefreshToken': true,
    'persistSession': true,
    'detectSessionInUrl': true,
  };
  
  /// 本地存储配置
  static const Map<String, dynamic> storageConfig = {
    'encryptionKey': 'supabase_flutter_auth',
    'requireAuthentication': false,
  };
}