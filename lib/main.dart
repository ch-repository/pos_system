import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app.dart';
import 'app/localization/app_localizations.dart';
import 'core/services/storage_service.dart';

void main() async {
  // 确保Flutter Widgets绑定已初始化
  // 这是在runApp之前进行异步操作的标准做法
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化核心服务
  await _initializeServices();

  // 检查并设置设备方向为横屏模式（适用于收银台设备）
  await _setLandscapeOrientation();

  // 尝试自动登录
  await _autoLogin();

  // 启动应用
  // ProviderScope 是 Riverpod 的根容器，所有 Provider 都需要在这个作用域内
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// 初始化应用所需的核心服务
///
/// 这个函数负责：
/// 1. 初始化本地存储（Hive）
/// 2. 初始化其他必要的服务
///
/// 在main函数中调用，确保应用启动前所有依赖都已准备就绪
Future<void> _initializeServices() async {
  // 初始化 Hive 本地数据库
  // Hive 是一个轻量级、快速的 NoSQL 数据库，适合移动应用
  await Hive.initFlutter();

  // 初始化存储服务
  // 这里会注册所有需要的 Hive 适配器和打开必要的 boxes
  await StorageService.initialize();

  // 未来可以在这里添加其他服务的初始化
  // 例如：推送通知、分析服务、崩溃报告等
  // await PushNotificationService.initialize();
  // await AnalyticsService.initialize();
}

/// 设置设备方向为横屏模式
///
/// 对于收银台应用，我们需要确保应用始终以横屏模式运行
Future<void> _setLandscapeOrientation() async {
  // 设置支持的设备方向为仅横屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}

/// 自动登录功能
///
/// 如果用户之前登录过且选择了"记住我"选项，
/// 则自动使用保存的凭据进行登录
Future<void> _autoLogin() async {
  // 检查是否存在保存的凭据
  final username = StorageService.getString('remembered_username');
  final password = StorageService.getString('remembered_password');

  if (username != null && password != null) {
    // 有保存的凭据，执行自动登录
    // 这里可以调用登录API，或者直接设置登录状态

    // 模拟登录API调用
    await Future.delayed(const Duration(milliseconds: 500));

    // 生成模拟令牌并保存登录状态
    const String mockToken = 'mock_jwt_token_auto_login';
    await StorageService.setToken(mockToken);
    await StorageService.setString('current_username', username);

    // 标记已完成首次启动
    await StorageService.setFirstLaunch(false);
  }
}
