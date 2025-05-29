/// 路由工具类
///
/// 这个类负责：
/// 1. 定义所有路由路径常量
/// 2. 定义路由名称常量
/// 3. 提供路由相关的工具方法
///
/// 使用常量可以避免硬编码，提高代码可维护性
class AppRoutes {
  // 私有构造函数，防止实例化
  AppRoutes._();

  // ==================== 路由路径 ====================

  /// 登录页路径
  static const String login = '/login';

  /// 收银台页面路径
  static const String pos = '/pos';

  // ==================== 路由名称 ====================

  /// 登录页名称
  static const String loginName = 'login';

  /// 收银台页面名称
  static const String posName = 'pos';

  // ==================== 工具方法 ====================

  /// 获取所有公共路由（不需要登录即可访问）
  static List<String> get publicRoutes => [
        login,
      ];

  /// 获取所有受保护路由（需要登录才能访问）
  static List<String> get protectedRoutes => [
        pos,
      ];

  /// 检查路由是否为公共路由
  static bool isPublicRoute(String route) {
    return publicRoutes.contains(route);
  }

  /// 检查路由是否为受保护路由
  static bool isProtectedRoute(String route) {
    return protectedRoutes.contains(route);
  }
}
