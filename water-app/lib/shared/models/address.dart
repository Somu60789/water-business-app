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
