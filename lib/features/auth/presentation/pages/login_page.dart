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
        backgroundColor: isError ? Colors.red : Colors.green,
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
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
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.shopping_cart,
                          size: 40,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        '收银系统登录',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        '请输入您的账户信息',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // 用户名输入框
                  TextFormField(
                    controller: _usernameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: _validateUsername,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                      hintText: '请输入您的用户名',
                      prefixIcon: Icon(Icons.person_outlined),
                    ),
                  ),

                  const SizedBox(height: 16),

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
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
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
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('记住账号密码'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // 登录按钮
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
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
                ],
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
