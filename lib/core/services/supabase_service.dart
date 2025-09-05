import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../config/supabase_config.dart';

/// Supabase服务
/// 负责Supabase客户端的初始化和管理
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  /// Supabase客户端实例
  supabase.SupabaseClient get client => supabase.Supabase.instance.client;

  /// 认证客户端
  supabase.GoTrueClient get auth => client.auth;

  /// 数据库客户端
  supabase.PostgrestClient get database => client.rest;

  /// 初始化Supabase
  /// 
  /// 在应用启动时调用此方法来初始化Supabase客户端
  static Future<void> initialize() async {
    try {
      await supabase.Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        authOptions: supabase.FlutterAuthClientOptions(
          authFlowType: supabase.AuthFlowType.pkce,
          autoRefreshToken: SupabaseConfig.authConfig['autoRefreshToken'] as bool,
        ),
        storageOptions: supabase.StorageClientOptions(
          retryAttempts: 3,
        ),
        realtimeClientOptions: supabase.RealtimeClientOptions(
          logLevel: kDebugMode ? supabase.RealtimeLogLevel.info : supabase.RealtimeLogLevel.error,
        ),
      );
      
      if (kDebugMode) {
        print('✅ Supabase initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize Supabase: $e');
      }
      rethrow;
    }
  }

  /// 检查Supabase是否已初始化
  static bool get isInitialized {
    try {
      supabase.Supabase.instance.client;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取当前用户
  supabase.User? get currentUser => auth.currentUser;

  /// 检查用户是否已登录
  bool get isLoggedIn => currentUser != null;

  /// 获取当前会话
  supabase.Session? get currentSession => auth.currentSession;

  /// 监听认证状态变化
  Stream<supabase.AuthState> get authStateChanges => auth.onAuthStateChange;
}