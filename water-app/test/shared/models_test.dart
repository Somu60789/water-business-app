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
