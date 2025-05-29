import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务
///
/// 这个类负责：
/// 1. 管理 Hive 数据库的初始化和配置
/// 2. 提供统一的存储接口
/// 3. 处理不同类型数据的存储需求
///
/// 使用说明：
/// - 复杂对象和列表使用 Hive（性能更好）
/// - 简单的键值对使用 SharedPreferences（更轻量）
class StorageService {
  static SharedPreferences? _prefs;
  static Box? _box;

  /// 初始化存储服务
  ///
  /// 这个方法必须在应用启动时调用，用于：
  /// 1. 初始化 SharedPreferences
  /// 2. 打开 Hive 默认 box
  /// 3. 注册必要的适配器（如果有的话）
  static Future<void> initialize() async {
    // 初始化 SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // 打开 Hive 默认 box
    // box 是 Hive 中数据的容器，类似于数据库中的表
    _box = await Hive.openBox('app_data');

    // 如果有自定义的数据模型，在这里注册适配器
    // 例如：Hive.registerAdapter(UserModelAdapter());
  }

  /// SharedPreferences 实例
  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception(
          'StorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  /// Hive Box 实例
  static Box get box {
    if (_box == null) {
      throw Exception(
          'StorageService not initialized. Call initialize() first.');
    }
    return _box!;
  }

  // ==================== SharedPreferences 方法 ====================
  // 用于存储简单的基本数据类型

  /// 存储字符串
  static Future<bool> setString(String key, String value) async {
    return await prefs.setString(key, value);
  }

  /// 获取字符串
  static String? getString(String key) {
    return prefs.getString(key);
  }

  /// 存储整数
  static Future<bool> setInt(String key, int value) async {
    return await prefs.setInt(key, value);
  }

  /// 获取整数
  static int? getInt(String key) {
    return prefs.getInt(key);
  }

  /// 存储布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await prefs.setBool(key, value);
  }

  /// 获取布尔值
  static bool? getBool(String key) {
    return prefs.getBool(key);
  }

  /// 存储双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    return await prefs.setDouble(key, value);
  }

  /// 获取双精度浮点数
  static double? getDouble(String key) {
    return prefs.getDouble(key);
  }

  /// 存储字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    return await prefs.setStringList(key, value);
  }

  /// 获取字符串列表
  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }

  /// 删除指定键的数据
  static Future<bool> remove(String key) async {
    return await prefs.remove(key);
  }

  /// 清除所有 SharedPreferences 数据
  static Future<bool> clearPrefs() async {
    return await prefs.clear();
  }

  // ==================== Hive 方法 ====================
  // 用于存储复杂对象、大量数据等

  /// 存储数据到 Hive
  ///
  /// Hive 支持存储任何 Dart 对象，但复杂对象需要注册适配器
  static Future<void> putData(String key, dynamic value) async {
    await box.put(key, value);
  }

  /// 从 Hive 获取数据
  static T? getData<T>(String key) {
    return box.get(key) as T?;
  }

  /// 从 Hive 删除数据
  static Future<void> deleteData(String key) async {
    await box.delete(key);
  }

  /// 清除所有 Hive 数据
  static Future<void> clearBox() async {
    await box.clear();
  }

  /// 检查 Hive 中是否存在指定键
  static bool containsKey(String key) {
    return box.containsKey(key);
  }

  /// 获取 Hive 中所有的键
  static Iterable<dynamic> getAllKeys() {
    return box.keys;
  }

  /// 获取 Hive 中所有的值
  static Iterable<dynamic> getAllValues() {
    return box.values;
  }

  // ==================== 便捷方法 ====================
  // 针对常见使用场景的封装

  /// 存储用户令牌
  static Future<bool> setToken(String token) async {
    return await setString('user_token', token);
  }

  /// 获取用户令牌
  static String? getToken() {
    return getString('user_token');
  }

  /// 删除用户令牌
  static Future<bool> removeToken() async {
    return await remove('user_token');
  }

  /// 检查用户是否已登录
  static bool isLoggedIn() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// 存储用户首次启动标记
  static Future<bool> setFirstLaunch(bool isFirst) async {
    return await setBool('is_first_launch', isFirst);
  }

  /// 检查是否是首次启动
  static bool isFirstLaunch() {
    return getBool('is_first_launch') ?? true;
  }

  /// 存储应用语言设置
  static Future<bool> setLanguage(String languageCode) async {
    return await setString('app_language', languageCode);
  }

  /// 获取应用语言设置
  static String? getLanguage() {
    return getString('app_language');
  }

  /// 存储主题模式设置
  static Future<bool> setThemeMode(String themeMode) async {
    return await setString('theme_mode', themeMode);
  }

  /// 获取主题模式设置
  static String? getThemeMode() {
    return getString('theme_mode');
  }
}
