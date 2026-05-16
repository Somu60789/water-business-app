import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/cart_cubit.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (ctx, state) {
          if (state is! CartUpdated || state.items.isEmpty) {
            return const Center(child: Text('Your cart is empty'));
          }
          final entries = state.items.entries.toList();
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: entries.length,
                  itemBuilder: (_, i) {
                    final product = entries[i].key;
                    final qty     = entries[i].value;
                    return ListTile(
                      title:    Text(product.name),
                      subtitle: Text('₹${product.price} × $qty'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: const Icon(Icons.remove), onPressed: () => ctx.read<CartCubit>().removeItem(product)),
                          Text('$qty', style: const TextStyle(fontSize: 16)),
                          IconButton(icon: const Icon(Icons.add),    onPressed: () => ctx.read<CartCubit>().addItem(product)),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('₹${state.total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ctx.push('/customer/checkout'),
                      child: const Text('Proceed to Checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
