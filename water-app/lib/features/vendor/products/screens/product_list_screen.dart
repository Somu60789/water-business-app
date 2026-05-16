import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/models/product.dart';
import 'package:water_app/shared/services/api_client.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<Product> _products = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getProducts(0);
      if (!mounted) return;
      setState(() { _products = data.map(Product.fromJson).toList(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _delete(int productId) async {
    try {
      await ApiClient.instance.deleteProduct(productId);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/vendor/products/new'),
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, i) {
                final p = _products[i];
                return ListTile(
                  title:    Text(p.name),
                  subtitle: Text('${p.unit} — ₹${p.price} — Stock: ${p.stockQty}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => context.push('/vendor/products/${p.id}/edit')),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(p.id)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
