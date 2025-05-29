import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'localization/app_localizations.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// 应用程序的根Widget
///
/// 这个类负责：
/// 1. 配置应用级别的主题
/// 2. 配置路由系统
/// 3. 配置国际化支持
/// 4. 集成屏幕适配
///
/// 使用 ConsumerWidget 而不是 StatelessWidget，以便可以使用 Riverpod 的状态管理
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听路由状态
    // appRouterProvider 提供了应用的路由配置
    final GoRouter router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      // 设计稿尺寸，根据你的设计稿调整
      // 375x812 是iPhone X的尺寸，也是常用的设计稿尺寸
      designSize: const Size(375, 812),

      // 最小文字大小缩放比例，防止文字过小
      minTextAdapt: true,

      // 是否根据宽度或高度中较小的一个进行缩放
      splitScreenMode: true,

      builder: (context, child) {
        return MaterialApp.router(
          // 应用标题
          title: '收银系统',

          // 是否显示Debug标识
          debugShowCheckedModeBanner: false,

          // 路由配置
          routerConfig: router,

          // 主题配置
          // 使用 Material 3 设计规范
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system, // 跟随系统主题

          // 国际化配置
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          // 默认语言设置
          locale: const Locale('zh', 'CN'), // 默认中文

          // 应用构建器，用于全局错误处理、加载状态等
          builder: (context, child) {
            // 确保屏幕适配初始化
            ScreenUtil.init(context);

            // 这里可以添加全局的Widget，比如：
            // - 全局加载遮罩
            // - 全局错误处理
            // - 网络状态监听
            return child ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}
