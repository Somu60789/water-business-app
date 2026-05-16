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
