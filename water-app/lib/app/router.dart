import 'package:go_router/go_router.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/phone_input_screen.dart';
import '../features/auth/screens/otp_verify_screen.dart';
import '../features/customer/home/screens/home_screen.dart';
import '../features/customer/cart/screens/cart_screen.dart';
import '../features/customer/checkout/screens/checkout_screen.dart';
import '../features/customer/tracking/screens/tracking_screen.dart';
import '../features/customer/orders/screens/order_history_screen.dart';
import '../features/customer/subscriptions/screens/subscription_list_screen.dart';
import '../features/customer/subscriptions/screens/create_subscription_screen.dart';
import '../features/customer/profile/screens/profile_screen.dart';
import '../features/vendor/dashboard/screens/vendor_dashboard_screen.dart';
import '../features/vendor/orders/screens/vendor_order_list_screen.dart';
import '../features/vendor/orders/screens/vendor_order_detail_screen.dart';
import '../features/vendor/products/screens/product_list_screen.dart';
import '../features/vendor/products/screens/product_form_screen.dart';
import '../features/vendor/delivery_boys/screens/delivery_boy_list_screen.dart';
import '../features/vendor/earnings/screens/earnings_screen.dart';
import '../features/delivery/deliveries/screens/delivery_list_screen.dart';
import '../features/delivery/navigate/screens/navigate_screen.dart';
import '../features/delivery/summary/screens/summary_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (ctx, _) => const SplashScreen()),

    // Auth
    GoRoute(path: '/auth/phone', builder: (ctx, _) => const PhoneInputScreen()),
    GoRoute(
      path: '/auth/otp',
      builder: (ctx, state) => OtpVerifyScreen(phone: state.extra as String),
    ),

    // Customer
    GoRoute(path: '/customer/home',          builder: (ctx, _) => const HomeScreen()),
    GoRoute(path: '/customer/cart',          builder: (ctx, _) => const CartScreen()),
    GoRoute(path: '/customer/checkout',      builder: (ctx, _) => const CheckoutScreen()),
    GoRoute(path: '/customer/orders',        builder: (ctx, _) => const OrderHistoryScreen()),
    GoRoute(
      path: '/customer/tracking/:orderId',
      builder: (ctx, state) => TrackingScreen(orderId: int.parse(state.pathParameters['orderId']!)),
    ),
    GoRoute(path: '/customer/subscriptions',        builder: (ctx, _) => const SubscriptionListScreen()),
    GoRoute(path: '/customer/subscriptions/create', builder: (ctx, _) => const CreateSubscriptionScreen()),
    GoRoute(path: '/customer/profile',              builder: (ctx, _) => const ProfileScreen()),

    // Vendor
    GoRoute(path: '/vendor/dashboard',     builder: (ctx, _) => const VendorDashboardScreen()),
    GoRoute(path: '/vendor/orders',        builder: (ctx, _) => const VendorOrderListScreen()),
    GoRoute(
      path: '/vendor/orders/:orderId',
      builder: (ctx, state) => VendorOrderDetailScreen(orderId: int.parse(state.pathParameters['orderId']!)),
    ),
    GoRoute(path: '/vendor/products',              builder: (ctx, _) => const ProductListScreen()),
    GoRoute(path: '/vendor/products/new',          builder: (ctx, _) => const ProductFormScreen()),
    GoRoute(
      path: '/vendor/products/:productId/edit',
      builder: (ctx, state) => ProductFormScreen(productId: int.tryParse(state.pathParameters['productId'] ?? '')),
    ),
    GoRoute(path: '/vendor/delivery-boys', builder: (ctx, _) => const DeliveryBoyListScreen()),
    GoRoute(path: '/vendor/earnings',      builder: (ctx, _) => const EarningsScreen()),

    // Delivery Boy
    GoRoute(path: '/delivery/orders',      builder: (ctx, _) => const DeliveryListScreen()),
    GoRoute(
      path: '/delivery/navigate/:orderId',
      builder: (ctx, state) => NavigateScreen(orderId: int.parse(state.pathParameters['orderId']!)),
    ),
    GoRoute(path: '/delivery/summary',     builder: (ctx, _) => const SummaryScreen()),
  ],
);
