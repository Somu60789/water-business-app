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
