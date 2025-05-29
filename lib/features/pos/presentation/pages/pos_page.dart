import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_utils.dart';
import '../../../../core/services/storage_service.dart';

/// 收银台页面
///
/// 这个页面负责：
/// 1. 显示商品分类和商品列表
/// 2. 显示购物车商品
/// 3. 处理结算逻辑
/// 4. 管理订单操作
class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage>
    with SingleTickerProviderStateMixin {
  // 应用配色
  static const Color primaryColor = Color(0xFF1E8449); // 深绿色
  static const Color secondaryColor = Color(0xFF27AE60); // 浅绿色
  static const Color accentColor = Color(0xFFF39C12); // 橙色强调色
  static const Color backgroundColor = Color(0xFFF5F5F5); // 浅灰色背景
  static const Color cardColor = Colors.white; // 卡片白色
  static const Color textDarkColor = Color(0xFF2D3436); // 深色文字
  static const Color textLightColor = Color(0xFF7F8C8D); // 浅色文字

  // Tab控制器
  late TabController _tabController;

  // 购物车商品列表
  final List<CartItem> _cartItems = [];

  // 当前选中的商品分类索引
  int _selectedCategoryIndex = 0;

  // 净重和皮重
  double _netWeight = 0.0;
  double _tareWeight = 0.0;

  // 商品数量
  int _quantity = 1;

  // 是否显示数字键盘
  bool _showNumpad = false;

  // 当前用户名
  final String _currentUser = "收银员001";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _tabController.addListener(_handleTabChange);

    // 添加模拟数据
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  // 处理分类Tab变化
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
      });
    }
  }

  // 加载模拟数据
  void _loadMockData() {
    // 添加模拟购物车项目
    setState(() {
      _cartItems.add(
        CartItem(
          id: '1',
          name: '新鲜西瓜',
          unitPrice: 10.00,
          quantity: 8.0123,
          totalPrice: 80.12,
        ),
      );
      _cartItems.add(
        CartItem(
          id: '2',
          name: '红富士苹果',
          unitPrice: 12.50,
          quantity: 5.0,
          totalPrice: 62.50,
        ),
      );
      _cartItems.add(
        CartItem(
          id: '3',
          name: '临时商品',
          unitPrice: 10.00,
          quantity: 8.0123,
          totalPrice: 80.12,
          isTemporary: true,
        ),
      );
    });
  }

  // 添加商品到购物车
  void _addToCart(Product product) {
    setState(() {
      // 检查购物车中是否已存在该商品
      final existingItemIndex =
          _cartItems.indexWhere((item) => item.id == product.id);

      // 计算商品价格（考虑折扣）
      final price = product.discount != null
          ? product.price * product.discount!
          : product.price;

      if (existingItemIndex != -1) {
        // 已存在，更新数量
        final existingItem = _cartItems[existingItemIndex];
        _cartItems[existingItemIndex] = CartItem(
          id: existingItem.id,
          name: existingItem.name,
          unitPrice: existingItem.unitPrice,
          quantity: existingItem.quantity + _quantity,
          totalPrice:
              existingItem.unitPrice * (existingItem.quantity + _quantity),
          isTemporary: existingItem.isTemporary,
        );

        // 显示添加成功提示
        _showSnackBar('已添加 ${product.name} x$_quantity 到购物车');
      } else {
        // 不存在，添加新商品
        _cartItems.add(
          CartItem(
            id: product.id,
            name: product.name,
            unitPrice: price,
            quantity: _quantity.toDouble(),
            totalPrice: price * _quantity,
            isTemporary: product.isTemporary,
          ),
        );

        // 显示添加成功提示
        _showSnackBar('已添加 ${product.name} 到购物车');
      }

      // 重置数量为1
      _quantity = 1;
    });
  }

  // 显示提示信息
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : primaryColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // 从购物车移除商品
  void _removeFromCart(String cartItemId) {
    setState(() {
      final removedItem =
          _cartItems.firstWhere((item) => item.id == cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      _showSnackBar('已从购物车移除 ${removedItem.name}');
    });
  }

  // 更新购物车商品数量
  void _updateCartItemQuantity(String cartItemId, double newQuantity) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        final item = _cartItems[index];
        _cartItems[index] = CartItem(
          id: item.id,
          name: item.name,
          unitPrice: item.unitPrice,
          quantity: newQuantity,
          totalPrice: item.unitPrice * newQuantity,
          isTemporary: item.isTemporary,
        );
      }
    });
  }

  // 清空购物车
  void _clearCart() {
    if (_cartItems.isEmpty) {
      _showSnackBar('购物车已经是空的', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空购物车'),
        content: const Text('您确定要清空购物车吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
                _netWeight = 0.0;
                _tareWeight = 0.0;
                _quantity = 1;
              });
              Navigator.of(context).pop();
              _showSnackBar('购物车已清空');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  // 更新数量
  void _updateQuantity(int quantity) {
    setState(() {
      _quantity = quantity;
    });
  }

  // 处理数字键盘输入
  void _handleNumpadInput(String value) {
    setState(() {
      if (value == 'C') {
        // 清空
        _quantity = 0;
      } else if (value == '←') {
        // 退格
        if (_quantity > 0) {
          _quantity = _quantity ~/ 10;
        }
      } else {
        // 数字输入
        final digit = int.tryParse(value);
        if (digit != null) {
          if (_quantity == 0) {
            _quantity = digit;
          } else {
            _quantity = _quantity * 10 + digit;
          }
        }
      }
    });
  }

  // 计算总价
  double _calculateTotal() {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // 计算总商品数量
  int _calculateTotalItems() {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  // 模拟结账操作
  void _checkout() {
    if (_cartItems.isEmpty) {
      _showSnackBar('购物车为空，无法结账', isError: true);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('结账信息'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 订单摘要
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    // 头部
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '订单摘要',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${_calculateTotalItems()} 件商品',
                          style: TextStyle(
                            color: textLightColor,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // 商品列表 (限制显示前3个)
                    ...List.generate(
                      _cartItems.length > 3 ? 3 : _cartItems.length,
                      (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _cartItems[index].name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '×${_cartItems[index].quantity.toStringAsFixed(1)}',
                              style: TextStyle(
                                color: textLightColor,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              '¥${_cartItems[index].totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 更多商品提示
                    if (_cartItems.length > 3) ...[
                      const Divider(),
                      Text(
                        '还有 ${_cartItems.length - 3} 件商品...',
                        style: TextStyle(
                          color: textLightColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],

                    const Divider(),

                    // 总计
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '总计',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '¥${_calculateTotal().toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 支付选项
              const Text(
                '请选择支付方式:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildPaymentOption(
                    icon: Icons.money,
                    label: '现金',
                    isSelected: true,
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentOption(
                    icon: Icons.payment,
                    label: '刷卡',
                  ),
                  const SizedBox(width: 8),
                  _buildPaymentOption(
                    icon: Icons.qr_code,
                    label: '扫码',
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              // 模拟支付过程
              _showSnackBar('正在处理支付...');

              // 延迟后显示支付成功
              Future.delayed(const Duration(seconds: 1), () {
                _showPaymentSuccessDialog();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认支付'),
          ),
        ],
      ),
    );
  }

  // 构建支付选项
  Widget _buildPaymentOption({
    required IconData icon,
    required String label,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : textLightColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? primaryColor : textDarkColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 显示支付成功对话框
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '支付成功',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '订单金额: ¥${_calculateTotal().toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '感谢您的购买!',
              style: TextStyle(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _cartItems.clear();
                _netWeight = 0.0;
                _tareWeight = 0.0;
                _quantity = 1;
              });
              _showSnackBar('交易完成，购物车已清空');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  // 处理退出登录
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出'),
        content: const Text('您确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              // 清除登录状态
              await StorageService.removeToken();
              await StorageService.remove('current_username');

              // 跳转到登录页
              if (mounted) {
                Navigator.of(context).pop();
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('退出登录'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            // 顶部标题栏
            _buildHeader(),

            // 主体内容
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 左侧购物车区域
                  Container(
                    width: screenSize.width * 0.35, // 响应式宽度
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 购物车标题栏
                        _buildCartHeader(),

                        // 购物车商品列表
                        Expanded(
                          child: _cartItems.isEmpty
                              ? _buildEmptyCart()
                              : ListView.builder(
                                  itemCount: _cartItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _cartItems[index];
                                    return _buildCartItem(item);
                                  },
                                ),
                        ),

                        // 数量控制区域
                        _showNumpad ? _buildNumpad() : _buildCartFooter(),
                      ],
                    ),
                  ),

                  // 右侧商品区域
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // 分类标签页
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: true,
                              tabs: const [
                                Tab(text: '全部'),
                                Tab(text: '热带水果'),
                                Tab(text: '桃李杏'),
                                Tab(text: '水果'),
                                Tab(text: '瓜类'),
                                Tab(text: '苹果类'),
                              ],
                              labelColor: primaryColor,
                              unselectedLabelColor: textDarkColor,
                              indicatorColor: primaryColor,
                              indicatorWeight: 3,
                              dividerColor: Colors.transparent,
                            ),
                          ),

                          // 子分类快捷选择
                          Container(
                            color: backgroundColor,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, right: 16, bottom: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        '快速筛选',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textDarkColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.swipe,
                                        size: 14,
                                        color: textLightColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '左右滑动查看更多',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: textLightColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 32,
                                      child: ListView(
                                        scrollDirection: Axis.horizontal,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        children: [
                                          _buildSubCategoryChip('全部商品', true),
                                          _buildSubCategoryChip('热卖商品', false),
                                          _buildSubCategoryChip('特价商品', false),
                                          _buildSubCategoryChip('西瓜', false),
                                          _buildSubCategoryChip('甜瓜', false),
                                          _buildSubCategoryChip('哈密瓜', false),
                                          _buildSubCategoryChip('苹果', false),
                                          _buildSubCategoryChip('香蕉', false),
                                          _buildSubCategoryChip('草莓', false),
                                          _buildSubCategoryChip('橙子', false),
                                          _buildSubCategoryChip('猕猴桃', false),
                                        ],
                                      ),
                                    ),
                                    // 右侧渐变提示
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      child: Container(
                                        width: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              backgroundColor.withOpacity(0),
                                              backgroundColor,
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // 商品列表区域
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildProductsGrid(),
                                _buildProductsGrid(),
                                _buildProductsGrid(),
                                _buildProductsGrid(),
                                _buildProductsGrid(),
                                _buildProductsGrid(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建头部栏
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 左侧店铺名称和Logo
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                '智慧收银系统',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(width: 24),

          // 中间搜索框
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '输入商品简称/条码/唯一码后4位',
                  hintStyle: TextStyle(color: textLightColor),
                  prefixIcon: const Icon(Icons.search, color: primaryColor),
                  suffixIcon: IconButton(
                    icon:
                        const Icon(Icons.qr_code_scanner, color: primaryColor),
                    onPressed: () {
                      // TODO: 实现扫码功能
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // 右侧用户信息
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _currentUser,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 1,
                  height: 16,
                  color: Colors.white.withOpacity(0.5),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'account',
                      child: Row(
                        children: [
                          Icon(Icons.settings),
                          SizedBox(width: 8),
                          Text('账户设置'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('退出登录'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建购物车头部
  Widget _buildCartHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '购物清单',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDarkColor,
            ),
          ),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.file_download_outlined,
                label: '挂单',
                onTap: () {
                  // TODO: 实现挂单功能
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.file_upload_outlined,
                label: '取单',
                onTap: () {
                  // TODO: 实现取单功能
                },
              ),
              const SizedBox(width: 12),
              _buildActionButton(
                icon: Icons.delete_outline,
                label: '清空',
                onTap: _clearCart,
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color ?? textDarkColor,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color ?? textDarkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建空购物车提示
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: textLightColor,
          ),
          const SizedBox(height: 16),
          Text(
            '购物车为空',
            style: TextStyle(
              fontSize: 16,
              color: textLightColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '点击右侧商品添加到购物车',
            style: TextStyle(
              fontSize: 14,
              color: textLightColor,
            ),
          ),
        ],
      ),
    );
  }

  // 购物车商品项
  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: item.isTemporary ? accentColor.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: item.isTemporary
              ? accentColor.withOpacity(0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          // 商品名称和单价
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (item.isTemporary)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '临时',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: item.isTemporary ? accentColor : textDarkColor,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '¥${item.unitPrice.toStringAsFixed(2)}/kg',
                  style: TextStyle(
                    color: textLightColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // 商品数量
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '×${item.quantity.toStringAsFixed(1)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 商品总价
          SizedBox(
            width: 80,
            child: Text(
              '¥${item.totalPrice.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textDarkColor,
                fontSize: 15,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // 编辑和删除按钮
          SizedBox(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    // TODO: 实现编辑功能
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.edit_outlined,
                      color: primaryColor,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => _removeFromCart(item.id),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建购物车底部
  Widget _buildCartFooter() {
    return Column(
      children: [
        // 商品数量控制
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '数量:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDarkColor,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap:
                    _quantity > 1 ? () => _updateQuantity(_quantity - 1) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _quantity > 1 ? primaryColor : Colors.grey.shade300,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showNumpad = true;
                  });
                },
                child: Container(
                  width: 48,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    color: Colors.white,
                  ),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () => _updateQuantity(_quantity + 1),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              _buildFunctionButton('规格'),
              const SizedBox(width: 8),
              _buildFunctionButton('备注'),
              const SizedBox(width: 8),
              _buildFunctionButton('改价'),
            ],
          ),
        ),

        // 重量信息区域
        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: backgroundColor,
        //     borderRadius: BorderRadius.circular(4),
        //     border: Border.all(color: Colors.grey.shade200),
        //   ),
        //   margin: const EdgeInsets.symmetric(horizontal: 16),
        //   child: Column(
        //     children: [
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             '净重 (kg)',
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: textDarkColor,
        //             ),
        //           ),
        //           Text(
        //             _netWeight.toStringAsFixed(3),
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 18,
        //               color: textDarkColor,
        //             ),
        //           ),
        //         ],
        //       ),
        //       const SizedBox(height: 8),
        //       Row(
        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //         children: [
        //           Text(
        //             '皮重 (kg)',
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               color: textDarkColor,
        //             ),
        //           ),
        //           Text(
        //             _tareWeight.toStringAsFixed(3),
        //             style: TextStyle(
        //               fontWeight: FontWeight.bold,
        //               fontSize: 18,
        //               color: textDarkColor,
        //             ),
        //           ),
        //         ],
        //       ),
        //     ],
        //   ),
        // ),

        const SizedBox(height: 12),

        // 结算按钮
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: textDarkColor,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: textLightColor.withOpacity(0.5)),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money),
                      SizedBox(width: 8),
                      Text(
                        '现金收款',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _checkout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Container(
                    height: 40,
                    constraints: const BoxConstraints(maxHeight: 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.payment, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '收款',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 14,
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '¥${_calculateTotal().toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 构建数字键盘
  Widget _buildNumpad() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 显示区域
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '$_quantity',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.end,
            ),
          ),

          const SizedBox(height: 16),

          // 数字按钮
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildNumpadButton('1'),
                _buildNumpadButton('2'),
                _buildNumpadButton('3'),
                _buildNumpadButton('4'),
                _buildNumpadButton('5'),
                _buildNumpadButton('6'),
                _buildNumpadButton('7'),
                _buildNumpadButton('8'),
                _buildNumpadButton('9'),
                _buildNumpadButton('C', isFunction: true),
                _buildNumpadButton('0'),
                _buildNumpadButton('←', isFunction: true),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 确定和取消按钮
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showNumpad = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: textDarkColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showNumpad = false;
                      // 此处应该有数量更新逻辑
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('确定'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 构建数字按钮
  Widget _buildNumpadButton(String text, {bool isFunction = false}) {
    return ElevatedButton(
      onPressed: () => _handleNumpadInput(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFunction ? Colors.grey.shade200 : cardColor,
        foregroundColor: isFunction ? textDarkColor : textDarkColor,
        elevation: 0,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建功能按钮
  Widget _buildFunctionButton(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
        color: cardColor,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textDarkColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // 构建产品网格
  Widget _buildProductsGrid() {
    // 生成模拟产品列表
    final List<Product> products = List.generate(
      20,
      (index) => Product(
        id: 'prod_$index',
        name: _getProductName(index),
        price: _getProductPrice(index),
        imageUrl: 'assets/images/products/${index % 5 + 1}.jpg',
        isInStock: true,
        isTemporary: index % 7 == 0,
        discount: index % 5 == 0 ? 0.8 : null,
      ),
    );

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  // 构建商品卡片
  Widget _buildProductCard(Product product) {
    final hasDiscount = product.discount != null;
    final discountedPrice =
        hasDiscount ? product.price * product.discount! : product.price;

    return InkWell(
      onTap: () => _addToCart(product),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: product.isTemporary
                ? accentColor.withOpacity(0.3)
                : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 商品图片
            Expanded(
              child: Stack(
                children: [
                  // 商品图片或占位图标
                  Container(
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    width: double.infinity,
                    child: Center(
                      child: Icon(
                        Icons.shopping_basket,
                        size: 48,
                        color: textLightColor.withOpacity(0.5),
                      ),
                    ),
                  ),

                  // 临时商品标签
                  if (product.isTemporary)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '临时',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // 打折标签
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(product.discount! * 10).toStringAsFixed(1)}折',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 商品信息
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 商品名称
                  Text(
                    product.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textDarkColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 商品价格
                  Row(
                    children: [
                      Text(
                        '¥${discountedPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: hasDiscount ? Colors.red : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 4),
                        Text(
                          '¥${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: textLightColor,
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 添加按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '加入购物车',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建子分类选择按钮
  Widget _buildSubCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        height: 30,
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // 处理子分类选择
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 12,
                          color: primaryColor,
                        ),
                      ),
                    Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? primaryColor : textDarkColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 获取模拟商品名称
  String _getProductName(int index) {
    final List<String> names = [
      '新鲜西瓜',
      '红富士苹果',
      '有机香蕉',
      '甜心菠萝',
      '当季草莓',
      '新鲜哈密瓜',
      '有机猕猴桃',
      '进口橙子',
      '新鲜柠檬',
      '有机葡萄',
    ];
    return names[index % names.length];
  }

  // 获取模拟商品价格
  double _getProductPrice(int index) {
    final List<double> prices = [
      5.99,
      8.50,
      12.80,
      15.00,
      23.50,
      35.00,
      42.80,
      9.90,
      18.80,
      25.50
    ];
    return prices[index % prices.length];
  }
}

/// 购物车商品模型
class CartItem {
  final String id;
  final String name;
  final double unitPrice;
  final double quantity;
  final double totalPrice;
  final bool isTemporary;

  CartItem({
    required this.id,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.isTemporary = false,
  });
}

/// 商品模型
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final bool isInStock;
  final bool isTemporary;
  final double? discount;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.isInStock,
    this.isTemporary = false,
    this.discount,
  });
}
