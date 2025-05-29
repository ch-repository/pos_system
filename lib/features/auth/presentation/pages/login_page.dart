import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_utils.dart';
import '../../../../core/services/storage_service.dart';

/// 登录页面
///
/// 这个页面负责：
/// 1. 用户身份验证
/// 2. 表单验证
/// 3. 登录状态管理
/// 4. 错误处理和用户反馈
///
/// 使用 ConsumerStatefulWidget 来管理表单状态和用户交互
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // 应用配色 - 与POS页面保持一致
  static const Color primaryColor = Color(0xFF1E8449); // 深绿色
  static const Color secondaryColor = Color(0xFF27AE60); // 浅绿色
  static const Color accentColor = Color(0xFFF39C12); // 橙色强调色
  static const Color backgroundColor = Color(0xFFF5F5F5); // 浅灰色背景
  static const Color cardColor = Colors.white; // 卡片白色
  static const Color textDarkColor = Color(0xFF2D3436); // 深色文字
  static const Color textLightColor = Color(0xFF7F8C8D); // 浅色文字

  /// 表单key，用于表单验证
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// 文本控制器
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// 状态变量
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true; // 默认选中记住我

  @override
  void initState() {
    super.initState();
    // 加载记住的用户信息
    _loadRememberedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 加载记住的用户凭据
  void _loadRememberedCredentials() {
    final rememberedUsername = StorageService.getString('remembered_username');
    final rememberedPassword = StorageService.getString('remembered_password');

    if (rememberedUsername != null) {
      _usernameController.text = rememberedUsername;
    }

    if (rememberedPassword != null) {
      _passwordController.text = rememberedPassword;
    }
  }

  /// 登录处理
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟登录API调用
      await Future.delayed(const Duration(seconds: 1));

      // 生成模拟令牌
      const String mockToken = 'mock_jwt_token_12345';

      // 保存登录状态
      await StorageService.setToken(mockToken);

      // 保存用户名到本地
      await StorageService.setString(
          'current_username', _usernameController.text);

      // 如果选择记住我，保存用户名和密码
      if (_rememberMe) {
        await StorageService.setString(
            'remembered_username', _usernameController.text);
        await StorageService.setString(
            'remembered_password', _passwordController.text);
      } else {
        await StorageService.remove('remembered_username');
        await StorageService.remove('remembered_password');
      }

      // 设置首次启动标记为false，确保下次直接跳过引导页
      await StorageService.setFirstLaunch(false);

      // 显示成功消息
      if (mounted) {
        _showSnackBar('登录成功！', isError: false);

        // 跳转到收银台界面
        context.go(AppRoutes.pos);
      }
    } catch (e) {
      // 处理登录错误
      if (mounted) {
        _showSnackBar('登录失败：${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 显示消息提示
  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// 验证用户名
  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名';
    }
    return null;
  }

  /// 验证密码
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }

    if (value.length < 4) {
      return '密码长度至少4个字符';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Center(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFFF0F8F1), // 特别浅的浅绿色
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 应用Logo和标题
                      Column(
                        children: [
                          // Logo容器
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.shopping_cart,
                              size: 40,
                              color: primaryColor,
                            ),
                          ),

                          const SizedBox(height: 40),

                          Text(
                            '智慧收银系统登录',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textDarkColor,
                                ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            '请输入您的账户信息',
                            style: TextStyle(
                              fontSize: 16,
                              color: textLightColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 用户名输入框
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        validator: _validateUsername,
                        decoration: InputDecoration(
                          labelText: '用户名',
                          hintText: '请输入您的用户名',
                          prefixIcon:
                              Icon(Icons.person_outlined, color: primaryColor),
                          labelStyle: TextStyle(color: textDarkColor),
                          hintStyle: TextStyle(color: textLightColor),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 密码输入框
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        validator: _validatePassword,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: '密码',
                          hintText: '请输入您的密码',
                          prefixIcon:
                              Icon(Icons.lock_outlined, color: primaryColor),
                          labelStyle: TextStyle(color: textDarkColor),
                          hintStyle: TextStyle(color: textLightColor),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: primaryColor, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: Colors.red, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: primaryColor,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 记住我
                      Row(
                        children: [
                          Theme(
                            data: Theme.of(context).copyWith(
                              checkboxTheme: CheckboxThemeData(
                                fillColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return primaryColor;
                                  }
                                  return Colors.grey.shade300;
                                }),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            child: Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                            ),
                          ),
                          Text(
                            '记住账号密码',
                            style: TextStyle(
                              color: textDarkColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 登录按钮
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                            disabledBackgroundColor:
                                primaryColor.withOpacity(0.6),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  '登录',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // 版权信息
                      Center(
                        child: Text(
                          '© 2023 智慧收银系统 - 版权所有',
                          style: TextStyle(
                            color: textLightColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 第三方登录按钮组件
class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(
              icon,
              color: color,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
