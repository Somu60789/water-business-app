import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/services/api_client.dart';

class ProductFormScreen extends StatefulWidget {
  final int? productId;
  const ProductFormScreen({super.key, this.productId});
  @override State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _name  = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController();
  String _unit = '20L';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final price = double.tryParse(_price.text.trim());
    final stock = int.tryParse(_stock.text.trim());
    if (_name.text.trim().isEmpty || price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields with valid values')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final payload = {
        'name': _name.text.trim(),
        'price': price,
        'unit': _unit,
        'stock_qty': stock,
      };
      if (widget.productId == null) {
        await ApiClient.instance.createProduct(payload);
      } else {
        await ApiClient.instance.updateProduct(widget.productId!, payload);
      }
      if (!mounted) return;
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? 'New Product' : 'Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _name,  decoration: const InputDecoration(labelText: 'Product Name')),
            const SizedBox(height: 12),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Price (₹)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: _stock, decoration: const InputDecoration(labelText: 'Stock Qty'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _unit,
              decoration: const InputDecoration(labelText: 'Unit'),
              items: const [
                DropdownMenuItem(value: '20L', child: Text('20L Can')),
                DropdownMenuItem(value: '5L',  child: Text('5L Bottle')),
                DropdownMenuItem(value: '1L',  child: Text('1L Bottle')),
              ],
              onChanged: (v) { if (v != null) setState(() => _unit = v); },
            ),
            const Spacer(),
            _loading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _submit, child: const Text('Save')),
                  ),
          ],
        ),
      ),
    );
  }
}
