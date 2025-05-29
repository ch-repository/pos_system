import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/storage_service.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import 'route_utils.dart';

/// 路由配置 Provider
///
/// 这是应用的核心路由配置，负责：
/// 1. 定义所有路由路径
/// 2. 处理路由守卫逻辑
/// 3. 管理路由状态
///
/// 使用 Riverpod 的 Provider 模式，确保路由状态可以被全局访问和管理
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // 初始路由
    // 应用启动时会根据用户状态决定显示哪个页面
    initialLocation: _getInitialRoute(),

    // 路由配置
    routes: [
      // 登录页路由
      GoRoute(
        path: AppRoutes.login,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginPage(),
      ),

      // 收银台页面路由
      GoRoute(
        path: AppRoutes.pos,
        name: AppRoutes.posName,
        builder: (context, state) => const PosPage(),
      ),
    ],

    // 错误页面处理
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('页面未找到'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '抱歉，页面未找到',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '路径: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.pos),
              child: const Text('返回收银台'),
            ),
          ],
        ),
      ),
    ),

    // 路由重定向逻辑
    // 这里实现路由守卫的核心逻辑
    redirect: (context, state) {
      final location = state.uri.toString();

      // 检查用户是否已登录
      final isLoggedIn = StorageService.isLoggedIn();

      // 路由守卫逻辑

      // 1. 未登录，且不在登录页面，重定向到登录页
      if (!isLoggedIn && location != AppRoutes.login) {
        return AppRoutes.login;
      }

      // 2. 已登录但在登录页面，重定向到收银台页面
      if (isLoggedIn && location == AppRoutes.login) {
        return AppRoutes.pos;
      }

      // 不需要重定向
      return null;
    },
  );
});

/// 获取初始路由
///
/// 根据用户的当前状态决定应用启动时显示的页面：
/// 1. 已登录 -> 收银台页面
/// 2. 未登录 -> 登录页
String _getInitialRoute() {
  try {
    final isLoggedIn = StorageService.isLoggedIn();
    if (isLoggedIn) {
      return AppRoutes.pos;
    } else {
      return AppRoutes.login;
    }
  } catch (e) {
    return AppRoutes.login;
  }
}
