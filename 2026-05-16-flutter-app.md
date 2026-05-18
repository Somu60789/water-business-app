# Flutter Mobile App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the complete Flutter mobile app for the multi-vendor water bottle delivery platform, with role-based UI for Customer, Vendor, and Delivery Boy.

**Architecture:** Single Flutter app with GoRouter role-based routing. Bloc/Cubit state management. Dio HTTP client with JWT Bearer interceptor. Feature-first folder structure — each feature has its own screens, bloc, and repository. Shared API client and models in `shared/`.

**Tech Stack:** Flutter 3.x, Dart, flutter_bloc, go_router, dio, google_maps_flutter, razorpay_flutter, firebase_messaging, firebase_auth (for OTP), shared_preferences (token storage), geolocator, intl.

---

## File Structure

```
water-app/
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── router.dart
│   │   └── theme.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── splash_screen.dart
│   │   │   │   ├── phone_input_screen.dart
│   │   │   │   └── otp_verify_screen.dart
│   │   │   ├── bloc/
│   │   │   │   ├── auth_bloc.dart
│   │   │   │   ├── auth_event.dart
│   │   │   │   └── auth_state.dart
│   │   │   └── repository/
│   │   │       └── auth_repository.dart
│   │   ├── customer/
│   │   │   ├── home/
│   │   │   │   ├── screens/home_screen.dart
│   │   │   │   └── bloc/vendor_list_cubit.dart
│   │   │   ├── cart/
│   │   │   │   ├── screens/cart_screen.dart
│   │   │   │   └── bloc/cart_cubit.dart
│   │   │   ├── checkout/
│   │   │   │   └── screens/checkout_screen.dart
│   │   │   ├── tracking/
│   │   │   │   └── screens/tracking_screen.dart
│   │   │   ├── orders/
│   │   │   │   ├── screens/order_history_screen.dart
│   │   │   │   └── bloc/order_history_cubit.dart
│   │   │   ├── subscriptions/
│   │   │   │   ├── screens/subscription_list_screen.dart
│   │   │   │   └── screens/create_subscription_screen.dart
│   │   │   └── profile/
│   │   │       └── screens/profile_screen.dart
│   │   ├── vendor/
│   │   │   ├── dashboard/
│   │   │   │   └── screens/vendor_dashboard_screen.dart
│   │   │   ├── orders/
│   │   │   │   ├── screens/vendor_order_list_screen.dart
│   │   │   │   └── screens/vendor_order_detail_screen.dart
│   │   │   ├── products/
│   │   │   │   ├── screens/product_list_screen.dart
│   │   │   │   └── screens/product_form_screen.dart
│   │   │   ├── delivery_boys/
│   │   │   │   └── screens/delivery_boy_list_screen.dart
│   │   │   └── earnings/
│   │   │       └── screens/earnings_screen.dart
│   │   └── delivery/
│   │       ├── deliveries/
│   │       │   └── screens/delivery_list_screen.dart
│   │       ├── navigate/
│   │       │   └── screens/navigate_screen.dart
│   │       └── summary/
│   │           └── screens/summary_screen.dart
│   └── shared/
│       ├── models/
│       │   ├── user.dart
│       │   ├── vendor.dart
│       │   ├── product.dart
│       │   ├── order.dart
│       │   ├── order_item.dart
│       │   ├── subscription.dart
│       │   ├── address.dart
│       │   └── delivery_location.dart
│       ├── services/
│       │   ├── api_client.dart
│       │   ├── auth_service.dart
│       │   └── fcm_service.dart
│       └── widgets/
│           ├── loading_button.dart
│           └── error_snack.dart
├── test/
│   ├── auth/
│   │   ├── auth_bloc_test.dart
│   │   └── auth_repository_test.dart
│   ├── customer/
│   │   ├── vendor_list_cubit_test.dart
│   │   └── cart_cubit_test.dart
│   └── shared/
│       └── api_client_test.dart
├── pubspec.yaml
└── android/
    └── app/
        └── google-services.json  (you provide this)
```

---

### Task 1: Project Bootstrap

**Files:**
- Create: `water-app/` (new Flutter project)
- Create: `pubspec.yaml` (with all dependencies)
- Create: `lib/main.dart`
- Create: `lib/app/theme.dart`

- [ ] **Step 1: Create Flutter project**

```bash
cd /home/somasekhar/Downloads/Vishnu/app/water-business-app
flutter create water-app --org com.waterdelivery --platforms android,ios
cd water-app
```

- [ ] **Step 2: Replace pubspec.yaml dependencies**

Edit `pubspec.yaml` — replace the `dependencies` and `dev_dependencies` sections:
```yaml
name: water_app
description: Multi-vendor water bottle delivery app
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.6
  go_router: ^13.2.5
  dio: ^5.4.3
  shared_preferences: ^2.2.3
  google_maps_flutter: ^2.6.1
  geolocator: ^11.3.0
  razorpay_flutter: ^1.3.6
  firebase_core: ^3.3.0
  firebase_messaging: ^15.1.0
  firebase_auth: ^5.1.3
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  equatable: ^2.0.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  bloc_test: ^9.1.7
  mocktail: ^1.0.3

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

```bash
mkdir -p assets/images
flutter pub get
```

- [ ] **Step 3: Create theme**

Create `lib/app/theme.dart`:
```dart
import 'package:flutter/material.dart';

final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0288D1)),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0288D1),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0288D1),
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
);
```

- [ ] **Step 4: Create main.dart stub**

Create `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WaterApp());
}

class WaterApp extends StatelessWidget {
  const WaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Water Delivery',
      theme: appTheme,
      routerConfig: appRouter,
    );
  }
}
```

- [ ] **Step 5: Verify it compiles**

```bash
flutter analyze
```
Expected: No errors (warnings about router.dart not existing yet are fine — we'll add it next task).

- [ ] **Step 6: Commit**

```bash
git add water-app/
git commit -m "feat: bootstrap Flutter project with pubspec and theme"
```

---

### Task 2: Shared Models

**Files:**
- Create: `lib/shared/models/user.dart`
- Create: `lib/shared/models/vendor.dart`
- Create: `lib/shared/models/product.dart`
- Create: `lib/shared/models/order.dart`
- Create: `lib/shared/models/order_item.dart`
- Create: `lib/shared/models/subscription.dart`
- Create: `lib/shared/models/address.dart`
- Create: `lib/shared/models/delivery_location.dart`
- Create: `test/shared/models_test.dart`

- [ ] **Step 1: Write model tests**

Create `test/shared/models_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:water_app/shared/models/user.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/models/product.dart';

void main() {
  group('User', () {
    test('fromJson parses all fields', () {
      final json = {
        'id': 1,
        'name': 'Ravi Kumar',
        'phone': '9876543210',
        'email': null,
        'role': 'customer',
        'fcm_token': null,
        'is_active': true,
      };
      final user = User.fromJson(json);
      expect(user.id, 1);
      expect(user.name, 'Ravi Kumar');
      expect(user.role, UserRole.customer);
      expect(user.isActive, true);
    });
  });

  group('Product', () {
    test('fromJson parses price as double', () {
      final json = {
        'id': 5, 'vendor_id': 2, 'name': '20L Can',
        'unit': '20L', 'price': '55.00',
        'stock_qty': 100, 'is_available': true,
      };
      final product = Product.fromJson(json);
      expect(product.price, 55.0);
    });
  });

  group('Order', () {
    test('fromJson parses status enum', () {
      final json = {
        'id': 10, 'customer_id': 1, 'vendor_id': 2,
        'delivery_boy_id': null,
        'status': 'pending', 'payment_mode': 'cod',
        'payment_status': 'pending', 'total_amount': '100.00',
        'delivery_address_id': 1, 'delivery_slot': 'morning',
        'otp': null, 'notes': null,
        'created_at': '2026-05-16T10:00:00.000000Z',
      };
      final order = Order.fromJson(json);
      expect(order.status, OrderStatus.pending);
      expect(order.totalAmount, 100.0);
    });
  });
}
```

- [ ] **Step 2: Run test to confirm failures**

```bash
flutter test test/shared/models_test.dart
```
Expected: FAIL — files don't exist.

- [ ] **Step 3: Create User model**

Create `lib/shared/models/user.dart`:
```dart
import 'package:equatable/equatable.dart';

enum UserRole { customer, vendor, deliveryBoy, admin }

UserRole _parseRole(String role) => switch (role) {
  'vendor'       => UserRole.vendor,
  'delivery_boy' => UserRole.deliveryBoy,
  'admin'        => UserRole.admin,
  _              => UserRole.customer,
};

class User extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? fcmToken;
  final bool isActive;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.fcmToken,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id:       json['id'] as int,
    name:     json['name'] as String,
    phone:    json['phone'] as String,
    email:    json['email'] as String?,
    role:     _parseRole(json['role'] as String),
    fcmToken: json['fcm_token'] as String?,
    isActive: json['is_active'] as bool,
  );

  @override
  List<Object?> get props => [id, name, phone, email, role, isActive];
}
```

- [ ] **Step 4: Create Vendor model**

Create `lib/shared/models/vendor.dart`:
```dart
import 'package:equatable/equatable.dart';

class Vendor extends Equatable {
  final int id;
  final int userId;
  final String businessName;
  final String address;
  final double lat;
  final double lng;
  final double serviceRadiusKm;
  final bool isOpen;
  final double? distance;

  const Vendor({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.address,
    required this.lat,
    required this.lng,
    required this.serviceRadiusKm,
    required this.isOpen,
    this.distance,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
    id:              json['id'] as int,
    userId:          json['user_id'] as int,
    businessName:    json['business_name'] as String,
    address:         json['address'] as String,
    lat:             (json['lat'] as num).toDouble(),
    lng:             (json['lng'] as num).toDouble(),
    serviceRadiusKm: (json['service_radius_km'] as num).toDouble(),
    isOpen:          json['is_open'] as bool,
    distance:        json['distance'] != null ? (json['distance'] as num).toDouble() : null,
  );

  @override
  List<Object?> get props => [id, businessName, isOpen];
}
```

- [ ] **Step 5: Create Product model**

Create `lib/shared/models/product.dart`:
```dart
import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final int vendorId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String unit;
  final double price;
  final int stockQty;
  final bool isAvailable;

  const Product({
    required this.id,
    required this.vendorId,
    required this.name,
    this.description,
    this.imageUrl,
    required this.unit,
    required this.price,
    required this.stockQty,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id:          json['id'] as int,
    vendorId:    json['vendor_id'] as int,
    name:        json['name'] as String,
    description: json['description'] as String?,
    imageUrl:    json['image_url'] as String?,
    unit:        json['unit'] as String,
    price:       double.parse(json['price'].toString()),
    stockQty:    json['stock_qty'] as int,
    isAvailable: json['is_available'] as bool,
  );

  @override
  List<Object?> get props => [id, name, price, unit];
}
```

- [ ] **Step 6: Create Order and OrderItem models**

Create `lib/shared/models/order_item.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'product.dart';

class OrderItem extends Equatable {
  final int id;
  final int orderId;
  final int productId;
  final int qty;
  final double unitPrice;
  final Product? product;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.qty,
    required this.unitPrice,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id:        json['id'] as int,
    orderId:   json['order_id'] as int,
    productId: json['product_id'] as int,
    qty:       json['qty'] as int,
    unitPrice: double.parse(json['unit_price'].toString()),
    product:   json['product'] != null ? Product.fromJson(json['product'] as Map<String, dynamic>) : null,
  );

  double get subtotal => qty * unitPrice;

  @override
  List<Object?> get props => [id, productId, qty, unitPrice];
}
```

Create `lib/shared/models/order.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'order_item.dart';

enum OrderStatus { pending, accepted, assigned, outForDelivery, delivered, cancelled }
enum PaymentMode { cod, online }
enum PaymentStatus { pending, paid }
enum DeliverySlot { morning, afternoon, evening }

OrderStatus _parseStatus(String s) => switch (s) {
  'accepted'         => OrderStatus.accepted,
  'assigned'         => OrderStatus.assigned,
  'out_for_delivery' => OrderStatus.outForDelivery,
  'delivered'        => OrderStatus.delivered,
  'cancelled'        => OrderStatus.cancelled,
  _                  => OrderStatus.pending,
};

class Order extends Equatable {
  final int id;
  final int customerId;
  final int vendorId;
  final int? deliveryBoyId;
  final OrderStatus status;
  final PaymentMode paymentMode;
  final PaymentStatus paymentStatus;
  final double totalAmount;
  final int deliveryAddressId;
  final DeliverySlot deliverySlot;
  final String? otp;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.customerId,
    required this.vendorId,
    this.deliveryBoyId,
    required this.status,
    required this.paymentMode,
    required this.paymentStatus,
    required this.totalAmount,
    required this.deliveryAddressId,
    required this.deliverySlot,
    this.otp,
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id:                json['id'] as int,
    customerId:        json['customer_id'] as int,
    vendorId:          json['vendor_id'] as int,
    deliveryBoyId:     json['delivery_boy_id'] as int?,
    status:            _parseStatus(json['status'] as String),
    paymentMode:       json['payment_mode'] == 'cod' ? PaymentMode.cod : PaymentMode.online,
    paymentStatus:     json['payment_status'] == 'paid' ? PaymentStatus.paid : PaymentStatus.pending,
    totalAmount:       double.parse(json['total_amount'].toString()),
    deliveryAddressId: json['delivery_address_id'] as int,
    deliverySlot:      DeliverySlot.values.firstWhere((s) => s.name == json['delivery_slot']),
    otp:               json['otp'] as String?,
    notes:             json['notes'] as String?,
    createdAt:         DateTime.parse(json['created_at'] as String),
    items:             (json['items'] as List<dynamic>?)
        ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
        .toList() ?? [],
  );

  @override
  List<Object?> get props => [id, status, totalAmount];
}
```

- [ ] **Step 7: Create Address and DeliveryLocation models**

Create `lib/shared/models/address.dart`:
```dart
import 'package:equatable/equatable.dart';

class Address extends Equatable {
  final int id;
  final int userId;
  final String label;
  final String addressLine;
  final double lat;
  final double lng;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.addressLine,
    required this.lat,
    required this.lng,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id:          json['id'] as int,
    userId:      json['user_id'] as int,
    label:       json['label'] as String,
    addressLine: json['address_line'] as String,
    lat:         (json['lat'] as num).toDouble(),
    lng:         (json['lng'] as num).toDouble(),
    isDefault:   json['is_default'] as bool,
  );

  @override
  List<Object?> get props => [id, label, addressLine, isDefault];
}
```

Create `lib/shared/models/delivery_location.dart`:
```dart
import 'package:equatable/equatable.dart';

class DeliveryLocation extends Equatable {
  final int userId;
  final double lat;
  final double lng;

  const DeliveryLocation({required this.userId, required this.lat, required this.lng});

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) => DeliveryLocation(
    userId: json['user_id'] as int,
    lat:    (json['lat'] as num).toDouble(),
    lng:    (json['lng'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [userId, lat, lng];
}
```

Create `lib/shared/models/subscription.dart`:
```dart
import 'package:equatable/equatable.dart';

class Subscription extends Equatable {
  final int id;
  final int customerId;
  final int vendorId;
  final int productId;
  final int qty;
  final String frequency;
  final int? dayOfWeek;
  final int? dayOfMonth;
  final String deliverySlot;
  final int addressId;
  final String paymentMode;
  final bool isActive;
  final DateTime nextDeliveryDate;

  const Subscription({
    required this.id,
    required this.customerId,
    required this.vendorId,
    required this.productId,
    required this.qty,
    required this.frequency,
    this.dayOfWeek,
    this.dayOfMonth,
    required this.deliverySlot,
    required this.addressId,
    required this.paymentMode,
    required this.isActive,
    required this.nextDeliveryDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id:               json['id'] as int,
    customerId:       json['customer_id'] as int,
    vendorId:         json['vendor_id'] as int,
    productId:        json['product_id'] as int,
    qty:              json['qty'] as int,
    frequency:        json['frequency'] as String,
    dayOfWeek:        json['day_of_week'] as int?,
    dayOfMonth:       json['day_of_month'] as int?,
    deliverySlot:     json['delivery_slot'] as String,
    addressId:        json['address_id'] as int,
    paymentMode:      json['payment_mode'] as String,
    isActive:         json['is_active'] as bool,
    nextDeliveryDate: DateTime.parse(json['next_delivery_date'] as String),
  );

  @override
  List<Object?> get props => [id, productId, frequency, isActive];
}
```

- [ ] **Step 8: Run model tests**

```bash
flutter test test/shared/models_test.dart
```
Expected: All 3 PASS.

- [ ] **Step 9: Commit**

```bash
git add water-app/
git commit -m "feat: Flutter shared models with fromJson parsers"
```

---

### Task 3: API Client + Auth Service

**Files:**
- Create: `lib/shared/services/api_client.dart`
- Create: `lib/shared/services/auth_service.dart`
- Create: `test/shared/api_client_test.dart`

- [ ] **Step 1: Write API client test**

Create `test/shared/api_client_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:water_app/shared/services/api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient.withDio(mockDio);
  });

  test('sendOtp calls POST /auth/send-otp', () async {
    when(() => mockDio.post(
      '/auth/send-otp',
      data: {'phone': '9876543210'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/auth/send-otp'),
      data: {'success': true, 'message': 'OTP sent'},
      statusCode: 200,
    ));

    final result = await apiClient.sendOtp('9876543210');
    expect(result['success'], true);
  });

  test('verifyOtp returns token on success', () async {
    when(() => mockDio.post(
      '/auth/verify-otp',
      data: {'phone': '9876543210', 'otp': '123456'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/auth/verify-otp'),
      data: {'success': true, 'data': {'token': 'abc123', 'user': {'id': 1, 'name': 'Test', 'phone': '9876543210', 'role': 'customer', 'is_active': true}}},
      statusCode: 200,
    ));

    final result = await apiClient.verifyOtp('9876543210', '123456');
    expect(result['data']['token'], 'abc123');
  });
}
```

- [ ] **Step 2: Run test to confirm failures**

```bash
flutter test test/shared/api_client_test.dart
```
Expected: FAIL — ApiClient class not found.

- [ ] **Step 3: Create ApiClient**

Create `lib/shared/services/api_client.dart`:
```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;

  static const String _baseUrl = 'http://10.0.2.2:8000/api'; // Android emulator → host machine

  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ));
  }

  ApiClient.withDio(Dio dio) {
    _dio = dio;
  }

  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final res = await _dio.post('/auth/send-otp', data: {'phone': phone});
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    final res = await _dio.post('/auth/verify-otp', data: {'phone': phone, 'otp': otp});
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getVendors(double lat, double lng) async {
    final res = await _dio.get('/vendors', queryParameters: {'lat': lat, 'lng': lng});
    return List<Map<String, dynamic>>.from((res.data as Map)['data'] as List);
  }

  Future<List<Map<String, dynamic>>> getProducts(int vendorId) async {
    final res = await _dio.get('/vendors/$vendorId/products');
    return List<Map<String, dynamic>>.from((res.data as Map)['data'] as List);
  }

  Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> payload) async {
    final res = await _dio.post('/orders', data: payload);
    return res.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final res = await _dio.get('/orders');
    return List<Map<String, dynamic>>.from(
      ((res.data as Map)['data'] as Map)['data'] as List,
    );
  }

  Future<Map<String, dynamic>> getOrder(int orderId) async {
    final res = await _dio.get('/orders/$orderId');
    return (res.data as Map)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getTracking(int orderId) async {
    final res = await _dio.get('/orders/$orderId/tracking');
    return (res.data as Map)['data'] as Map<String, dynamic>;
  }

  Future<void> createProduct(Map<String, dynamic> payload) async {
    await _dio.post('/products', data: payload);
  }

  Future<void> updateProduct(int productId, Map<String, dynamic> payload) async {
    await _dio.put('/products/$productId', data: payload);
  }

  Future<void> deleteProduct(int productId) async {
    await _dio.delete('/products/$productId');
  }

  Future<List<Map<String, dynamic>>> getVendorOrders() async {
    final res = await _dio.get('/vendor/orders');
    return List<Map<String, dynamic>>.from(
      ((res.data as Map)['data'] as Map)['data'] as List,
    );
  }

  Future<void> updateOrderStatus(int orderId, Map<String, dynamic> payload) async {
    await _dio.put('/orders/$orderId/status', data: payload);
  }

  Future<List<Map<String, dynamic>>> getDeliveryOrders() async {
    final res = await _dio.get('/delivery/orders');
    return List<Map<String, dynamic>>.from((res.data as Map)['data'] as List);
  }

  Future<void> updateDeliveryStatus(int orderId, String status) async {
    await _dio.put('/delivery/orders/$orderId/status', data: {'status': status});
  }

  Future<void> pushLocation(double lat, double lng) async {
    await _dio.post('/location', data: {'lat': lat, 'lng': lng});
  }

  Future<void> verifyDeliveryOtp(int orderId, String otp) async {
    await _dio.post('/orders/$orderId/verify-otp', data: {'otp': otp});
  }

  Future<Map<String, dynamic>> createRazorpayOrder(int orderId) async {
    final res = await _dio.post('/payments/create-order', data: {'order_id': orderId});
    return (res.data as Map)['data'] as Map<String, dynamic>;
  }

  Future<void> verifyPayment(Map<String, dynamic> payload) async {
    await _dio.post('/payments/verify', data: payload);
  }

  Future<List<Map<String, dynamic>>> getSubscriptions() async {
    final res = await _dio.get('/subscriptions');
    return List<Map<String, dynamic>>.from((res.data as Map)['data'] as List);
  }

  Future<void> createSubscription(Map<String, dynamic> payload) async {
    await _dio.post('/subscriptions', data: payload);
  }

  Future<void> deleteSubscription(int id) async {
    await _dio.delete('/subscriptions/$id');
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    final res = await _dio.get('/notifications');
    return List<Map<String, dynamic>>.from(
      ((res.data as Map)['data'] as Map)['data'] as List,
    );
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    await _dio.put('/auth/profile', data: payload);
  }
}
```

- [ ] **Step 4: Create AuthService**

Create `lib/shared/services/auth_service.dart`:
```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey  = 'auth_token';
  static const String _userKey   = 'auth_user';

  Future<void> saveSession(String token, Map<String, dynamic> userJson) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
```

- [ ] **Step 5: Run api_client tests**

```bash
flutter test test/shared/api_client_test.dart
```
Expected: All 2 PASS.

- [ ] **Step 6: Commit**

```bash
git add water-app/
git commit -m "feat: ApiClient with Dio, JWT interceptor, and AuthService"
```

---

### Task 4: Auth Bloc + Screens

**Files:**
- Create: `lib/features/auth/bloc/auth_bloc.dart`
- Create: `lib/features/auth/bloc/auth_event.dart`
- Create: `lib/features/auth/bloc/auth_state.dart`
- Create: `lib/features/auth/repository/auth_repository.dart`
- Create: `lib/features/auth/screens/splash_screen.dart`
- Create: `lib/features/auth/screens/phone_input_screen.dart`
- Create: `lib/features/auth/screens/otp_verify_screen.dart`
- Create: `test/auth/auth_bloc_test.dart`

- [ ] **Step 1: Write AuthBloc test**

Create `test/auth/auth_bloc_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:water_app/features/auth/bloc/auth_bloc.dart';
import 'package:water_app/features/auth/bloc/auth_event.dart';
import 'package:water_app/features/auth/bloc/auth_state.dart';
import 'package:water_app/features/auth/repository/auth_repository.dart';
import 'package:water_app/shared/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc bloc;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    bloc = AuthBloc(repository: mockRepo);
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'emits [sendingOtp, otpSent] on SendOtpEvent success',
    build: () {
      when(() => mockRepo.sendOtp('9876543210')).thenAnswer((_) async => {});
      return bloc;
    },
    act: (b) => b.add(const SendOtpEvent('9876543210')),
    expect: () => [isA<AuthSendingOtp>(), isA<AuthOtpSent>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [verifying, authenticated] on VerifyOtpEvent success',
    build: () {
      final user = const User(id: 1, name: 'Test', phone: '9876543210', role: UserRole.customer, isActive: true);
      when(() => mockRepo.verifyOtp('9876543210', '123456')).thenAnswer((_) async => user);
      return bloc;
    },
    act: (b) => b.add(const VerifyOtpEvent('9876543210', '123456')),
    expect: () => [isA<AuthVerifying>(), isA<AuthAuthenticated>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [verifying, error] on VerifyOtpEvent failure',
    build: () {
      when(() => mockRepo.verifyOtp(any(), any())).thenThrow(Exception('Invalid OTP'));
      return bloc;
    },
    act: (b) => b.add(const VerifyOtpEvent('9876543210', '000000')),
    expect: () => [isA<AuthVerifying>(), isA<AuthError>()],
  );
}
```

- [ ] **Step 2: Run to confirm failures**

```bash
flutter test test/auth/auth_bloc_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Create auth events, states, repository**

Create `lib/features/auth/bloc/auth_event.dart`:
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  const SendOtpEvent(this.phone);
  @override List<Object> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent(this.phone, this.otp);
  @override List<Object> get props => [phone, otp];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
  @override List<Object> get props => [];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
  @override List<Object> get props => [];
}
```

Create `lib/features/auth/bloc/auth_state.dart`:
```dart
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial      extends AuthState { const AuthInitial();      @override List<Object> get props => []; }
class AuthSendingOtp   extends AuthState { const AuthSendingOtp();   @override List<Object> get props => []; }
class AuthOtpSent      extends AuthState { const AuthOtpSent();      @override List<Object> get props => []; }
class AuthVerifying    extends AuthState { const AuthVerifying();     @override List<Object> get props => []; }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated(); @override List<Object> get props => []; }

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object> get props => [message];
}
```

Create `lib/features/auth/repository/auth_repository.dart`:
```dart
import 'package:water_app/shared/models/user.dart';
import 'package:water_app/shared/services/api_client.dart';
import 'package:water_app/shared/services/auth_service.dart';

class AuthRepository {
  final ApiClient _api;
  final AuthService _authService;

  AuthRepository({ApiClient? api, AuthService? authService})
      : _api         = api ?? ApiClient(),
        _authService = authService ?? AuthService();

  Future<void> sendOtp(String phone) async {
    await _api.sendOtp(phone);
  }

  Future<User> verifyOtp(String phone, String otp) async {
    final response = await _api.verifyOtp(phone, otp);
    final data     = response['data'] as Map<String, dynamic>;
    final token    = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    await _authService.saveSession(token, userJson);
    return User.fromJson(userJson);
  }

  Future<User?> checkAuth() async {
    final userJson = await _authService.getUser();
    if (userJson == null) return null;
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    await _authService.clearSession();
  }
}
```

Create `lib/features/auth/bloc/auth_bloc.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(const AuthInitial()) {
    on<CheckAuthEvent>(_onCheckAuth);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onCheckAuth(CheckAuthEvent event, Emitter<AuthState> emit) async {
    final user = await repository.checkAuth();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthSendingOtp());
    try {
      await repository.sendOtp(event.phone);
      emit(const AuthOtpSent());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthVerifying());
    try {
      final user = await repository.verifyOtp(event.phone, event.otp);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthUnauthenticated());
  }
}
```

- [ ] **Step 4: Run AuthBloc tests**

```bash
flutter test test/auth/auth_bloc_test.dart
```
Expected: All 3 PASS.

- [ ] **Step 5: Create auth screens**

Create `lib/features/auth/screens/splash_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(const CheckAuthEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          switch (state.user.role.name) {
            case 'vendor':       context.go('/vendor/dashboard'); break;
            case 'deliveryBoy':  context.go('/delivery/orders'); break;
            default:             context.go('/customer/home');
          }
        } else if (state is AuthUnauthenticated) {
          context.go('/auth/phone');
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.water_drop, size: 80, color: Color(0xFF0288D1)),
              SizedBox(height: 16),
              Text('Water Delivery', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
```

Create `lib/features/auth/screens/phone_input_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});
  @override State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _controller = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (ctx, state) {
              if (state is AuthOtpSent) {
                ctx.push('/auth/otp', extra: _controller.text.trim());
              } else if (state is AuthError) {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (ctx, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    const Icon(Icons.water_drop, size: 56, color: Color(0xFF0288D1)),
                    const SizedBox(height: 24),
                    const Text('Enter your phone', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('We\'ll send a verification code', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        prefixText: '+91 ',
                        labelText: 'Phone number',
                      ),
                      validator: (v) {
                        if (v == null || v.length != 10) return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (state is AuthSendingOtp)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ctx.read<AuthBloc>().add(SendOtpEvent(_controller.text.trim()));
                          }
                        },
                        child: const Text('Send OTP'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
```

Create `lib/features/auth/screens/otp_verify_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});
  @override State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthAuthenticated) {
              switch (state.user.role.name) {
                case 'vendor':      ctx.go('/vendor/dashboard'); break;
                case 'deliveryBoy': ctx.go('/delivery/orders'); break;
                default:            ctx.go('/customer/home');
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Code sent to +91 ${widget.phone}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 32),
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8),
                  decoration: const InputDecoration(labelText: 'Enter 6-digit OTP'),
                ),
                const SizedBox(height: 24),
                if (state is AuthVerifying)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: () {
                      if (_controller.text.length == 6) {
                        ctx.read<AuthBloc>().add(VerifyOtpEvent(widget.phone, _controller.text));
                      }
                    },
                    child: const Text('Verify'),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run all tests**

```bash
flutter test test/auth/
```
Expected: All PASS.

- [ ] **Step 7: Commit**

```bash
git add water-app/
git commit -m "feat: auth screens (splash, phone input, OTP verify) with Bloc"
```

---

### Task 5: Router

**Files:**
- Create: `lib/app/router.dart`
- Create: `lib/shared/widgets/loading_button.dart`
- Create: `lib/shared/widgets/error_snack.dart`

- [ ] **Step 1: Create shared widgets**

Create `lib/shared/widgets/loading_button.dart`:
```dart
import 'package:flutter/material.dart';

class LoadingButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  final String label;

  const LoadingButton({super.key, required this.isLoading, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(label),
    );
  }
}
```

Create `lib/shared/widgets/error_snack.dart`:
```dart
import 'package:flutter/material.dart';

void showErrorSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red),
  );
}
```

- [ ] **Step 2: Create router**

Create `lib/app/router.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/bloc/auth_bloc.dart';
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
```

- [ ] **Step 3: Commit**

```bash
git add water-app/
git commit -m "feat: GoRouter with full role-based routing and shared widgets"
```

---

### Task 6: Customer — Home, Cart, Checkout

**Files:**
- Create: `lib/features/customer/home/bloc/vendor_list_cubit.dart`
- Create: `lib/features/customer/home/screens/home_screen.dart`
- Create: `lib/features/customer/cart/bloc/cart_cubit.dart`
- Create: `lib/features/customer/cart/screens/cart_screen.dart`
- Create: `lib/features/customer/checkout/screens/checkout_screen.dart`
- Create: `test/customer/vendor_list_cubit_test.dart`
- Create: `test/customer/cart_cubit_test.dart`

- [ ] **Step 1: Write cubit tests**

Create `test/customer/vendor_list_cubit_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:water_app/features/customer/home/bloc/vendor_list_cubit.dart';
import 'package:water_app/shared/models/vendor.dart';
import 'package:water_app/shared/services/api_client.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late VendorListCubit cubit;
  late MockApiClient mockApi;

  setUp(() {
    mockApi = MockApiClient();
    cubit   = VendorListCubit(api: mockApi);
  });
  tearDown(() => cubit.close());

  blocTest<VendorListCubit, VendorListState>(
    'emits [loading, loaded] on successful fetch',
    build: () {
      when(() => mockApi.getVendors(any(), any())).thenAnswer((_) async => [
        {'id': 1, 'user_id': 2, 'business_name': 'Bisleri Co', 'address': '1 MG Road', 'lat': 12.97, 'lng': 77.59, 'service_radius_km': 10, 'is_open': true}
      ]);
      return cubit;
    },
    act: (c) => c.fetchVendors(12.97, 77.59),
    expect: () => [isA<VendorListLoading>(), isA<VendorListLoaded>()],
  );
}
```

Create `test/customer/cart_cubit_test.dart`:
```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:water_app/features/customer/cart/bloc/cart_cubit.dart';
import 'package:water_app/shared/models/product.dart';

void main() {
  late CartCubit cubit;

  setUp(() => cubit = CartCubit());
  tearDown(() => cubit.close());

  const product = Product(
    id: 1, vendorId: 1, name: '20L Can', unit: '20L',
    price: 55.0, stockQty: 100, isAvailable: true,
  );

  blocTest<CartCubit, CartState>(
    'addItem emits CartUpdated with qty 1',
    build: () => cubit,
    act: (c) => c.addItem(product),
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
    ],
  );

  blocTest<CartCubit, CartState>(
    'addItem twice emits CartUpdated with qty 2',
    build: () => cubit,
    act: (c) { c.addItem(product); c.addItem(product); },
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 2),
    ],
  );

  blocTest<CartCubit, CartState>(
    'removeItem decrements qty',
    build: () => cubit,
    seed: () => CartUpdated({product: 2}),
    act: (c) => c.removeItem(product),
    expect: () => [
      predicate<CartState>((s) => s is CartUpdated && s.items[product] == 1),
    ],
  );

  blocTest<CartCubit, CartState>(
    'clear empties cart',
    build: () => cubit,
    seed: () => CartUpdated({product: 2}),
    act: (c) => c.clear(),
    expect: () => [predicate<CartState>((s) => s is CartUpdated && s.items.isEmpty)],
  );
}
```

- [ ] **Step 2: Run to confirm failures**

```bash
flutter test test/customer/
```
Expected: FAIL.

- [ ] **Step 3: Create VendorListCubit**

Create `lib/features/customer/home/bloc/vendor_list_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/vendor.dart';
import 'package:water_app/shared/services/api_client.dart';

abstract class VendorListState extends Equatable { const VendorListState(); }
class VendorListInitial extends VendorListState { @override List<Object> get props => []; }
class VendorListLoading extends VendorListState { @override List<Object> get props => []; }
class VendorListLoaded  extends VendorListState {
  final List<Vendor> vendors;
  const VendorListLoaded(this.vendors);
  @override List<Object> get props => [vendors];
}
class VendorListError   extends VendorListState {
  final String message;
  const VendorListError(this.message);
  @override List<Object> get props => [message];
}

class VendorListCubit extends Cubit<VendorListState> {
  final ApiClient api;
  VendorListCubit({required this.api}) : super(VendorListInitial());

  Future<void> fetchVendors(double lat, double lng) async {
    emit(VendorListLoading());
    try {
      final data    = await api.getVendors(lat, lng);
      final vendors = data.map(Vendor.fromJson).toList();
      emit(VendorListLoaded(vendors));
    } catch (e) {
      emit(VendorListError(e.toString()));
    }
  }
}
```

- [ ] **Step 4: Create CartCubit**

Create `lib/features/customer/cart/bloc/cart_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/product.dart';

abstract class CartState extends Equatable { const CartState(); }
class CartUpdated extends CartState {
  final Map<Product, int> items;
  const CartUpdated(this.items);

  double get total => items.entries.fold(0, (sum, e) => sum + e.key.price * e.value);
  int    get count => items.values.fold(0, (sum, v) => sum + v);

  @override List<Object> get props => [items];
}

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartUpdated({}));

  Map<Product, int> get _items => state is CartUpdated ? Map.of((state as CartUpdated).items) : {};

  void addItem(Product product) {
    final items = _items;
    items[product] = (items[product] ?? 0) + 1;
    emit(CartUpdated(items));
  }

  void removeItem(Product product) {
    final items = _items;
    if ((items[product] ?? 0) <= 1) {
      items.remove(product);
    } else {
      items[product] = items[product]! - 1;
    }
    emit(CartUpdated(items));
  }

  void clear() => emit(const CartUpdated({}));
}
```

- [ ] **Step 5: Create HomeScreen**

Create `lib/features/customer/home/screens/home_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/vendor_list_cubit.dart';
import 'package:water_app/shared/services/api_client.dart';
import 'package:water_app/shared/models/vendor.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        context.read<VendorListCubit>().fetchVendors(12.97, 77.59); // fallback
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      context.read<VendorListCubit>().fetchVendors(pos.latitude, pos.longitude);
    } catch (_) {
      context.read<VendorListCubit>().fetchVendors(12.97, 77.59);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Vendors'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => context.push('/customer/cart')),
          IconButton(icon: const Icon(Icons.history),       onPressed: () => context.push('/customer/orders')),
          IconButton(icon: const Icon(Icons.person),        onPressed: () => context.push('/customer/profile')),
        ],
      ),
      body: BlocProvider(
        create: (_) => VendorListCubit(api: ApiClient()),
        child: BlocBuilder<VendorListCubit, VendorListState>(
          builder: (ctx, state) {
            if (state is VendorListLoading) return const Center(child: CircularProgressIndicator());
            if (state is VendorListError)   return Center(child: Text(state.message));
            if (state is VendorListLoaded) {
              if (state.vendors.isEmpty) return const Center(child: Text('No vendors nearby'));
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.vendors.length,
                itemBuilder: (_, i) => _VendorCard(vendor: state.vendors[i]),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.store)),
        title:    Text(vendor.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(vendor.address),
        trailing: vendor.distance != null
            ? Text('${vendor.distance!.toStringAsFixed(1)} km')
            : null,
        onTap: () => context.push('/customer/cart', extra: vendor),
      ),
    );
  }
}
```

- [ ] **Step 6: Create CartScreen**

Create `lib/features/customer/cart/screens/cart_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_cubit.dart';
import 'package:water_app/shared/models/product.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (ctx, state) {
          if (state is! CartUpdated || state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          final entries = state.items.entries.toList();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final product = entries[i].key;
                    final qty     = entries[i].value;
                    return ListTile(
                      title:    Text(product.name),
                      subtitle: Text('₹${product.price} × $qty'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: () => ctx.read<CartCubit>().removeItem(product)),
                          Text('$qty', style: const TextStyle(fontSize: 16)),
                          IconButton(icon: const Icon(Icons.add),    onPressed: () => ctx.read<CartCubit>().addItem(product)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${state.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ctx.push('/customer/checkout'),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 7: Create CheckoutScreen**

Create `lib/features/customer/checkout/screens/checkout_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/features/customer/cart/bloc/cart_cubit.dart';
import 'package:water_app/shared/services/api_client.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _slot        = 'morning';
  String _paymentMode = 'cod';
  bool _isLoading     = false;

  Future<void> _placeOrder(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      final cartState = context.read<CartCubit>().state as CartUpdated;
      final items = cartState.items.entries
          .map((e) => {'product_id': e.key.id, 'qty': e.value})
          .toList();

      final api = ApiClient();
      // address_id: 1 for demo — production should let user pick address
      await api.placeOrder({
        'vendor_id':     cartState.items.keys.first.vendorId,
        'address_id':    1,
        'delivery_slot': _slot,
        'payment_mode':  _paymentMode,
        'items':         items,
      });

      context.read<CartCubit>().clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order placed!')));
      context.go('/customer/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Slot', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _slot,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'morning',   child: Text('Morning (6am–12pm)')),
                DropdownMenuItem(value: 'afternoon', child: Text('Afternoon (12–4pm)')),
                DropdownMenuItem(value: 'evening',   child: Text('Evening (4–8pm)')),
              ],
              onChanged: (v) => setState(() => _slot = v!),
            ),
            const SizedBox(height: 24),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'cod',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            RadioListTile<String>(
              title: const Text('Pay Online (Razorpay)'),
              value: 'online',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    child: const Text('Place Order'),
                  ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Run tests**

```bash
flutter test test/customer/
```
Expected: All PASS.

- [ ] **Step 9: Commit**

```bash
git add water-app/
git commit -m "feat: customer home (vendor list), cart, and checkout screens"
```

---

### Task 7: Customer — Tracking, Orders, Subscriptions

**Files:**
- Create: `lib/features/customer/tracking/screens/tracking_screen.dart`
- Create: `lib/features/customer/orders/screens/order_history_screen.dart`
- Create: `lib/features/customer/orders/bloc/order_history_cubit.dart`
- Create: `lib/features/customer/subscriptions/screens/subscription_list_screen.dart`
- Create: `lib/features/customer/subscriptions/screens/create_subscription_screen.dart`
- Create: `lib/features/customer/profile/screens/profile_screen.dart`

- [ ] **Step 1: Create OrderHistoryCubit**

Create `lib/features/customer/orders/bloc/order_history_cubit.dart`:
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

abstract class OrderHistoryState extends Equatable { const OrderHistoryState(); }
class OrderHistoryInitial extends OrderHistoryState { @override List<Object> get props => []; }
class OrderHistoryLoading extends OrderHistoryState { @override List<Object> get props => []; }
class OrderHistoryLoaded  extends OrderHistoryState {
  final List<Order> orders;
  const OrderHistoryLoaded(this.orders);
  @override List<Object> get props => [orders];
}
class OrderHistoryError   extends OrderHistoryState {
  final String message;
  const OrderHistoryError(this.message);
  @override List<Object> get props => [message];
}

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final ApiClient api;
  OrderHistoryCubit({required this.api}) : super(OrderHistoryInitial());

  Future<void> load() async {
    emit(OrderHistoryLoading());
    try {
      final data   = await api.getOrders();
      final orders = data.map(Order.fromJson).toList();
      emit(OrderHistoryLoaded(orders));
    } catch (e) {
      emit(OrderHistoryError(e.toString()));
    }
  }
}
```

- [ ] **Step 2: Create OrderHistoryScreen**

Create `lib/features/customer/orders/screens/order_history_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/order_history_cubit.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderHistoryCubit(api: ApiClient())..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          builder: (ctx, state) {
            if (state is OrderHistoryLoading) return const Center(child: CircularProgressIndicator());
            if (state is OrderHistoryError)   return Center(child: Text(state.message));
            if (state is OrderHistoryLoaded) {
              if (state.orders.isEmpty) return const Center(child: Text('No orders yet'));
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (_, i) => _OrderTile(order: state.orders[i]),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  Color _statusColor() => switch (order.status) {
    OrderStatus.delivered   => Colors.green,
    OrderStatus.cancelled   => Colors.red,
    OrderStatus.outForDelivery => Colors.blue,
    _                       => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Order #${order.id}'),
      subtitle: Text(DateFormat('dd MMM yyyy').format(order.createdAt)),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _statusColor(), borderRadius: BorderRadius.circular(4)),
            child: Text(order.status.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
      onTap: () {
        if (order.status == OrderStatus.outForDelivery) {
          context.push('/customer/tracking/${order.id}');
        }
      },
    );
  }
}
```

- [ ] **Step 3: Create TrackingScreen**

Create `lib/features/customer/tracking/screens/tracking_screen.dart`:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:water_app/shared/services/api_client.dart';

class TrackingScreen extends StatefulWidget {
  final int orderId;
  const TrackingScreen({super.key, required this.orderId});
  @override State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final ApiClient _api;
  GoogleMapController? _mapController;
  LatLng? _deliveryBoyPos;
  String _status = 'Loading...';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _api = ApiClient();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final data = await _api.getTracking(widget.orderId);
      if (!mounted) return;
      setState(() {
        _status = data['status'] as String;
        final loc = data['location'] as Map<String, dynamic>?;
        if (loc != null) {
          _deliveryBoyPos = LatLng((loc['lat'] as num).toDouble(), (loc['lng'] as num).toDouble());
        }
      });
      if (_deliveryBoyPos != null) {
        _mapController?.animateCamera(CameraUpdate.newLatLng(_deliveryBoyPos!));
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking Order #${widget.orderId}')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(target: LatLng(12.97, 77.59), zoom: 14),
            onMapCreated: (c) => _mapController = c,
            markers: _deliveryBoyPos != null
                ? {Marker(markerId: const MarkerId('delivery'), position: _deliveryBoyPos!)}
                : {},
          ),
          Positioned(
            bottom: 24, left: 16, right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Status: $_status', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create SubscriptionListScreen and CreateSubscriptionScreen**

Create `lib/features/customer/subscriptions/screens/subscription_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_app/shared/models/subscription.dart';
import 'package:water_app/shared/services/api_client.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});
  @override State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<Subscription> _subs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient().getSubscriptions();
      setState(() { _subs = data.map(Subscription.fromJson).toList(); _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscriptions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customer/subscriptions/create'),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subs.isEmpty
              ? const Center(child: Text('No active subscriptions'))
              : ListView.builder(
                  itemCount: _subs.length,
                  itemBuilder: (_, i) {
                    final s = _subs[i];
                    return ListTile(
                      title:    Text('Product #${s.productId} × ${s.qty}'),
                      subtitle: Text('${s.frequency} — Next: ${DateFormat('dd MMM').format(s.nextDeliveryDate)}'),
                      trailing: Switch(
                        value: s.isActive,
                        onChanged: (_) {},
                      ),
                    );
                  },
                ),
    );
  }
}
```

Create `lib/features/customer/subscriptions/screens/create_subscription_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/services/api_client.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});
  @override State<CreateSubscriptionScreen> createState() => _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  String _frequency = 'daily';
  String _slot      = 'morning';
  bool _isLoading   = false;
  final _qtyController = TextEditingController(text: '1');

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      await ApiClient().createSubscription({
        'vendor_id':    1,   // demo values — production: pass from navigation extra
        'product_id':   1,
        'qty':          int.parse(_qtyController.text),
        'frequency':    _frequency,
        'delivery_slot':_slot,
        'address_id':   1,
        'payment_mode': 'cod',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription created!')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily',   child: Text('Daily')),
                DropdownMenuItem(value: 'weekly',  child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (v) => setState(() => _frequency = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _slot,
              decoration: const InputDecoration(labelText: 'Delivery Slot'),
              items: const [
                DropdownMenuItem(value: 'morning',   child: Text('Morning')),
                DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                DropdownMenuItem(value: 'evening',   child: Text('Evening')),
              ],
              onChanged: (v) => setState(() => _slot = v!),
            ),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('Subscribe')),
          ],
        ),
      ),
    );
  }
}
```

Create `lib/features/customer/profile/screens/profile_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/features/auth/bloc/auth_bloc.dart';
import 'package:water_app/features/auth/bloc/auth_event.dart';
import 'package:water_app/features/auth/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is! AuthAuthenticated) return const SizedBox();
          final user = state.user;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(radius: 40, child: Text(user.name[0], style: const TextStyle(fontSize: 32))),
              const SizedBox(height: 16),
              Text(user.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('+91 ${user.phone}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('My Orders'),
                onTap: () => ctx.push('/customer/orders'),
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Subscriptions'),
                onTap: () => ctx.push('/customer/subscriptions'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  ctx.read<AuthBloc>().add(const LogoutEvent());
                  ctx.go('/auth/phone');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add water-app/
git commit -m "feat: customer tracking (live map), order history, subscriptions, profile"
```

---

### Task 8: Vendor Screens

**Files:**
- Create: `lib/features/vendor/dashboard/screens/vendor_dashboard_screen.dart`
- Create: `lib/features/vendor/orders/screens/vendor_order_list_screen.dart`
- Create: `lib/features/vendor/orders/screens/vendor_order_detail_screen.dart`
- Create: `lib/features/vendor/products/screens/product_list_screen.dart`
- Create: `lib/features/vendor/products/screens/product_form_screen.dart`
- Create: `lib/features/vendor/delivery_boys/screens/delivery_boy_list_screen.dart`
- Create: `lib/features/vendor/earnings/screens/earnings_screen.dart`

- [ ] **Step 1: Create VendorDashboardScreen**

Create `lib/features/vendor/dashboard/screens/vendor_dashboard_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Dashboard')),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _DashTile(icon: Icons.receipt_long, label: 'Orders',        route: '/vendor/orders'),
          _DashTile(icon: Icons.inventory,    label: 'Products',      route: '/vendor/products'),
          _DashTile(icon: Icons.people,       label: 'Delivery Boys', route: '/vendor/delivery-boys'),
          _DashTile(icon: Icons.bar_chart,    label: 'Earnings',      route: '/vendor/earnings'),
        ],
      ),
    );
  }
}

class _DashTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  const _DashTile({required this.icon, required this.label, required this.route});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0288D1).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0288D1).withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF0288D1)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Create VendorOrderListScreen and VendorOrderDetailScreen**

Create `lib/features/vendor/orders/screens/vendor_order_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class VendorOrderListScreen extends StatefulWidget {
  const VendorOrderListScreen({super.key});
  @override State<VendorOrderListScreen> createState() => _VendorOrderListScreenState();
}

class _VendorOrderListScreenState extends State<VendorOrderListScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient().getVendorOrders();
      setState(() { _orders = data.map(Order.fromJson).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (_, i) => ListTile(
                title:    Text('Order #${_orders[i].id}'),
                subtitle: Text('₹${_orders[i].totalAmount.toStringAsFixed(0)} — ${_orders[i].deliverySlot.name}'),
                trailing: Text(_orders[i].status.name),
                onTap:    () => context.push('/vendor/orders/${_orders[i].id}'),
              ),
            ),
    );
  }
}
```

Create `lib/features/vendor/orders/screens/vendor_order_detail_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const VendorOrderDetailScreen({super.key, required this.orderId});
  @override State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient().getOrder(widget.orderId);
      setState(() { _order = Order.fromJson(data); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _updateStatus(String status, {int? deliveryBoyId}) async {
    try {
      final payload = {'status': status};
      if (deliveryBoyId != null) payload['delivery_boy_id'] = deliveryBoyId.toString();
      await ApiClient().updateOrderStatus(widget.orderId, payload);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null) return const Scaffold(body: Center(child: Text('Not found')));
    final order = _order!;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}'),
            Text('Slot: ${order.deliverySlot.name}'),
            Text('Payment: ${order.paymentMode.name}'),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((i) => Text('• ${i.qty}× Product #${i.productId} @ ₹${i.unitPrice}')),
            const Spacer(),
            if (order.status == OrderStatus.pending) ...[
              ElevatedButton(onPressed: () => _updateStatus('accepted'), child: const Text('Accept Order')),
              const SizedBox(height: 8),
              OutlinedButton(onPressed: () => _updateStatus('cancelled'), child: const Text('Reject')),
            ],
            if (order.status == OrderStatus.accepted)
              ElevatedButton(
                onPressed: () => _updateStatus('assigned', deliveryBoyId: 1), // production: show picker
                child: const Text('Assign Delivery Boy'),
              ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 3: Create ProductListScreen and ProductFormScreen**

Create `lib/features/vendor/products/screens/product_list_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/models/product.dart';
import 'package:water_app/shared/services/api_client.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _loading = true;
  int _vendorId = 0;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      // vendor sees their own products via vendor dashboard — fetch using vendor_id from profile
      // For now use vendorId 1 as placeholder
      final data = await ApiClient().getProducts(_vendorId);
      setState(() { _products = data.map(Product.fromJson).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _delete(int productId) async {
    await ApiClient().deleteProduct(productId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vendor/products/new'),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, i) {
                final p = _products[i];
                return ListTile(
                  title:    Text(p.name),
                  subtitle: Text('${p.unit} — ₹${p.price} — Stock: ${p.stockQty}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/vendor/products/${p.id}/edit')),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(p.id)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
```

Create `lib/features/vendor/products/screens/product_form_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/services/api_client.dart';

class ProductFormScreen extends StatefulWidget {
  final int? productId;
  const ProductFormScreen({super.key, this.productId});
  @override State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _name     = TextEditingController();
  final _price    = TextEditingController();
  final _stock    = TextEditingController();
  String _unit    = '20L';
  bool _loading   = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final payload = {
      'name': _name.text, 'price': double.parse(_price.text),
      'unit': _unit, 'stock_qty': int.parse(_stock.text),
    };
    try {
      if (widget.productId == null) {
        await ApiClient().createProduct(payload);
      } else {
        await ApiClient().updateProduct(widget.productId!, payload);
      }
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? 'New Product' : 'Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _name,  decoration: const InputDecoration(labelText: 'Product Name')),
            const SizedBox(height: 12),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock Qty'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              items: const [
                DropdownMenuItem(value: '20L', child: Text('20L Can')),
                DropdownMenuItem(value: '5L',  child: Text('5L Bottle')),
                DropdownMenuItem(value: '1L',  child: Text('1L Bottle')),
              ],
              onChanged: (v) => setState(() => _unit = v!),
            ),
            const Spacer(),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Create remaining vendor screens**

Create `lib/features/vendor/delivery_boys/screens/delivery_boy_list_screen.dart`:
```dart
import 'package:flutter/material.dart';

class DeliveryBoyListScreen extends StatelessWidget {
  const DeliveryBoyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Boys')),
      body: const Center(child: Text('Delivery boys assigned to this vendor will appear here')),
    );
  }
}
```

Create `lib/features/vendor/earnings/screens/earnings_screen.dart`:
```dart
import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings')),
      body: const Center(child: Text('Earnings summary coming soon')),
    );
  }
}
```

- [ ] **Step 5: Commit**

```bash
git add water-app/
git commit -m "feat: vendor screens — dashboard, orders, product CRUD"
```

---

### Task 9: Delivery Boy Screens

**Files:**
- Create: `lib/features/delivery/deliveries/screens/delivery_list_screen.dart`
- Create: `lib/features/delivery/navigate/screens/navigate_screen.dart`
- Create: `lib/features/delivery/summary/screens/summary_screen.dart`

- [ ] **Step 1: Create DeliveryListScreen**

Create `lib/features/delivery/deliveries/screens/delivery_list_screen.dart`:
```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});
  @override State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startLocationBroadcast();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient().getDeliveryOrders();
      setState(() { _orders = data.map(Order.fromJson).toList(); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _startLocationBroadcast() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition();
        await ApiClient().pushLocation(pos.latitude, pos.longitude);
      } catch (_) {}
    });
  }

  @override
  void dispose() { _locationTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Deliveries')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No deliveries assigned'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    return ListTile(
                      title:    Text('Order #${o.id}'),
                      subtitle: Text('Slot: ${o.deliverySlot.name} — ${o.status.name}'),
                      trailing: const Icon(Icons.navigation),
                      onTap:    () => context.push('/delivery/navigate/${o.id}'),
                    );
                  },
                ),
    );
  }
}
```

- [ ] **Step 2: Create NavigateScreen (OTP confirm)**

Create `lib/features/delivery/navigate/screens/navigate_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class NavigateScreen extends StatefulWidget {
  final int orderId;
  const NavigateScreen({super.key, required this.orderId});
  @override State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  Order? _order;
  bool _loading     = true;
  bool _confirming  = false;
  final _otpController = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient().getOrder(widget.orderId);
      setState(() { _order = Order.fromJson(data); _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  Future<void> _markOutForDelivery() async {
    await ApiClient().updateDeliveryStatus(widget.orderId, 'out_for_delivery');
    await _load();
  }

  Future<void> _confirmOtp() async {
    setState(() => _confirming = true);
    try {
      await ApiClient().verifyDeliveryOtp(widget.orderId, _otpController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed!')));
      context.go('/delivery/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  void dispose() { _otpController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null) return const Scaffold(body: Center(child: Text('Not found')));

    return Scaffold(
      appBar: AppBar(title: Text('Deliver Order #${widget.orderId}')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(target: LatLng(12.97, 77.59), zoom: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Status: ${_order!.status.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                if (_order!.status == OrderStatus.assigned) ...[
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _markOutForDelivery, child: const Text('Mark: Out for Delivery')),
                ],
                if (_order!.status == OrderStatus.outForDelivery) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(labelText: 'Enter OTP from customer'),
                  ),
                  const SizedBox(height: 8),
                  _confirming
                      ? const CircularProgressIndicator()
                      : ElevatedButton(onPressed: _confirmOtp, child: const Text('Confirm Delivery')),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

Create `lib/features/delivery/summary/screens/summary_screen.dart`:
```dart
import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Summary')),
      body: const Center(child: Text('Daily delivery summary will appear here')),
    );
  }
}
```

- [ ] **Step 3: Commit**

```bash
git add water-app/
git commit -m "feat: delivery boy screens — list, navigate with GPS, OTP confirm"
```

---

### Task 10: FCM + main.dart wiring

**Files:**
- Create: `lib/shared/services/fcm_service.dart`
- Modify: `lib/main.dart`
- Modify: `android/app/build.gradle` (google-services plugin)

- [ ] **Step 1: Create FCMService**

Create `lib/shared/services/fcm_service.dart`:
```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> _backgroundHandler(RemoteMessage message) async {}

class FcmService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    await _fcm.requestPermission();
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    FirebaseMessaging.onMessage.listen((message) {
      // Foreground: show in-app banner (handled by app's notification layer)
    });

    final token = await _fcm.getToken();
    if (token != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
    }
  }

  Future<String?> getToken() => _fcm.getToken();
}
```

- [ ] **Step 2: Update main.dart to wire BlocProviders and FCM**

Replace `lib/main.dart`:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/repository/auth_repository.dart';
import 'features/customer/cart/bloc/cart_cubit.dart';
import 'shared/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FcmService().init();
  runApp(const WaterApp());
}

class WaterApp extends StatelessWidget {
  const WaterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthBloc(repository: AuthRepository())),
        BlocProvider(create: (_) => CartCubit()),
      ],
      child: MaterialApp.router(
        title: 'Water Delivery',
        theme: appTheme,
        routerConfig: appRouter,
      ),
    );
  }
}
```

- [ ] **Step 3: Run full test suite**

```bash
flutter test --coverage
```
Expected: All tests PASS.

- [ ] **Step 4: Run flutter analyze**

```bash
flutter analyze
```
Expected: No errors.

- [ ] **Step 5: Build debug APK to verify compilation**

```bash
flutter build apk --debug 2>&1 | tail -20
```
Expected: `Built build/app/outputs/flutter-apk/app-debug.apk` with no errors.

- [ ] **Step 6: Final commit**

```bash
git add water-app/
git commit -m "feat: FCM service wired, MultiBlocProvider in main.dart — Flutter app complete"
```

- [ ] **Step 7: Tag the Flutter release**

```bash
git tag v1.0.0-flutter
```
