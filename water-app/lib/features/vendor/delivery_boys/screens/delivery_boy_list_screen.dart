import 'package:flutter/material.dart';

class DeliveryBoyListScreen extends StatelessWidget {
  const DeliveryBoyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Boys')),
      body: const Center(child: Text('Delivery boys assigned to this vendor will appear here')),
    );
  }
}
