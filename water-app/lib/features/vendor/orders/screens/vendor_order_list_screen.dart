import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class VendorOrderListScreen extends StatefulWidget {
  const VendorOrderListScreen({super.key});
  @override State<VendorOrderListScreen> createState() => _VendorOrderListScreenState();
}

class _VendorOrderListScreenState extends State<VendorOrderListScreen> {
  List<Order> _orders = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getVendorOrders();
      if (!mounted) return;
      setState(() { _orders = data.map(Order.fromJson).toList(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Orders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _orders.length,
              itemBuilder: (_, i) => ListTile(
                title:    Text('Order #${_orders[i].id}'),
                subtitle: Text('₹${_orders[i].totalAmount.toStringAsFixed(0)} — ${_orders[i].deliverySlot.name}'),
                trailing: Text(_orders[i].status.name),
                onTap:    () => context.push('/vendor/orders/${_orders[i].id}'),
              ),
            ),
    );
  }
}
