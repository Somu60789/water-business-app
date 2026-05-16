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
