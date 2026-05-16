import 'package:flutter/material.dart';

class NavigateScreen extends StatelessWidget {
  final int orderId;
  const NavigateScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('NavigateScreen')));
  }
}
