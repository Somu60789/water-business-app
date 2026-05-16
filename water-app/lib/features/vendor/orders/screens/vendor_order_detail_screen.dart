import 'package:flutter/material.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class VendorOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const VendorOrderDetailScreen({super.key, required this.orderId});
  @override State<VendorOrderDetailScreen> createState() => _VendorOrderDetailScreenState();
}

class _VendorOrderDetailScreenState extends State<VendorOrderDetailScreen> {
  Order? _order;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getOrder(widget.orderId);
      if (!mounted) return;
      setState(() { _order = Order.fromJson(data); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status, {int? deliveryBoyId}) async {
    try {
      final payload = <String, dynamic>{'status': status};
      if (deliveryBoyId != null) payload['delivery_boy_id'] = deliveryBoyId;
      await ApiClient.instance.updateOrderStatus(widget.orderId, payload);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null) return const Scaffold(body: Center(child: Text('Not found')));
    final order = _order!;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}'),
            Text('Slot: ${order.deliverySlot.name}'),
            Text('Payment: ${order.paymentMode.name}'),
            const SizedBox(height: 16),
            const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.items.map((i) => Text('• ${i.qty}× Product #${i.productId} @ ₹${i.unitPrice}')),
            const Spacer(),
            if (order.status == OrderStatus.pending) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => _updateStatus('accepted'), child: const Text('Accept Order')),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(onPressed: () => _updateStatus('cancelled'), child: const Text('Reject')),
              ),
            ],
            if (order.status == OrderStatus.accepted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _updateStatus('assigned', deliveryBoyId: 1),
                  child: const Text('Assign Delivery Boy'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
