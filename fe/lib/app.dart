// lib/app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'modules/auth/providers/auth_provider.dart';
import 'modules/auth/views/login_page.dart';
import 'modules/auth/views/register_page.dart';
import 'modules/user/models/mall_provider.dart';
import 'modules/user/providers/address_provider.dart';
import 'modules/user/providers/cart_provider.dart';
import 'modules/user/providers/home_provider.dart';
import 'modules/user/providers/notification_provider.dart';
import 'modules/user/providers/order_provider.dart';
import 'modules/user/providers/review_provider.dart';
import 'modules/user/providers/voucher_provider.dart';
import 'modules/user/providers/wishlist_provider.dart';
import 'modules/user/providers/image_search_provider.dart';
import 'modules/user/screens/cart_page.dart';
import 'modules/user/screens/checkout_page.dart';
import 'modules/user/user_main_page.dart';
import 'modules/user/models/payment_intent_model.dart';
import 'modules/admin/admin_home_page.dart';
import 'modules/admin/admin_provider.dart';
import 'routes/app_routes.dart';
import 'modules/admin/admin_routes.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Chạy sau khi frame đầu tiên render xong → MultiProvider đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeAuth();
      }
    });
  }

  Future<void> _initializeAuth() async {
    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null || !mounted) return;

    final authProvider = Provider.of<AuthProvider>(overlay.context, listen: false);

    await authProvider.checkAuthStatus();

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      await _checkPendingIntentOnStartup();
    } else {
      print('User not authenticated, skip pending intent check');
    }
  }

  Future<void> _checkPendingIntentOnStartup() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    print('\nChecking for pending paid intent on startup...');

    final overlay = _navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    final orderProvider = Provider.of<OrderProvider>(overlay.context, listen: false);
    final pendingIntent = await orderProvider.checkPendingPaidIntent();

    if (pendingIntent != null && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showPendingIntentDialog(pendingIntent);
        }
      });
    }
  }

  void _showPendingIntentDialog(PaymentIntentModel intent) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Đơn hàng chưa hoàn tất',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có 1 đơn hàng đã thanh toán VNPay nhưng chưa hoàn tất đặt hàng.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số tiền đã thanh toán:', style: TextStyle(fontSize: 13)),
                      Text(
                        '${intent.totalAmount.toStringAsFixed(0)}đ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  if (intent.voucherCode != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_offer, size: 14, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text('Mã giảm giá: ${intent.voucherCode}', style: const TextStyle(fontSize: 12, color: Colors.blue)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng hoàn tất đặt hàng để nhận sản phẩm.',
              style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Để sau', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _navigatorKey.currentState?.pushNamed(AppRoutes.checkout);
            },
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text('Tiếp tục đặt hàng'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => MallProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => VoucherProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ImageSearchProvider()),
        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
          create: (_) => AddressProvider(AuthProvider()),
          update: (_, auth, __) => AddressProvider(auth),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AdminProvider>(
          create: (_) => AdminProvider(AuthProvider(), ApiClient()),
          update: (_, auth, __) => AdminProvider(auth, ApiClient()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Fashion App',
        theme: ThemeData(primarySwatch: Colors.pink),
        initialRoute: AppRoutes.login,
        routes: {
          AppRoutes.login: (_) => const LoginPage(),
          AppRoutes.register: (_) => const RegisterPage(),
          AppRoutes.userHome: (_) => const UserMainPage(),
          AdminRoutes.adminHome: (_) => const AdminHomePage(),
          '/cart': (_) => const CartPage(),
          AppRoutes.checkout: (_) => const CheckoutPage(),
        },
      ),
    );
  }
}