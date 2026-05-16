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
