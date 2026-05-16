import 'package:flutter/material.dart';

class TrackingScreen extends StatelessWidget {
  final int orderId;
  const TrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('TrackingScreen')));
  }
}
