import 'package:flutter/material.dart';

class ProductFormScreen extends StatelessWidget {
  final int? productId;
  const ProductFormScreen({super.key, this.productId});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ProductFormScreen')));
  }
}
