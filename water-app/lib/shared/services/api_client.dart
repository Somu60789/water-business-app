import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  late final Dio _dio;

  static const String _baseUrl = 'http://10.0.2.2:8000/api';

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
    // Laravel paginator returns { data: { data: [...], total: N, ... } }
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
    // Laravel paginator returns { data: { data: [...], total: N, ... } }
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
    return List<Map<String, dynamic>>.from((res.data as Map)['data'] as List);
  }

  Future<void> updateProfile(Map<String, dynamic> payload) async {
    await _dio.put('/auth/profile', data: payload);
  }
}
