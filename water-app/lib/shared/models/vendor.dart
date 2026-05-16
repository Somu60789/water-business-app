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
