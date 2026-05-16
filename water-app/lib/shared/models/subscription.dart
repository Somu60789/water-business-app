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
