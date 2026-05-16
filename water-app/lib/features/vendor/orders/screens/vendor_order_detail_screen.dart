import 'package:flutter/material.dart';

class VendorOrderDetailScreen extends StatelessWidget {
  final int orderId;
  const VendorOrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('VendorOrderDetailScreen')));
  }
}
