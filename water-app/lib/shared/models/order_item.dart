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
