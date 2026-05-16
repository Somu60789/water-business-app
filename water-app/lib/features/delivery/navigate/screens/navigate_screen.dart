import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class NavigateScreen extends StatefulWidget {
  final int orderId;
  const NavigateScreen({super.key, required this.orderId});
  @override State<NavigateScreen> createState() => _NavigateScreenState();
}

class _NavigateScreenState extends State<NavigateScreen> {
  Order? _order;
  bool _loading    = true;
  bool _confirming = false;
  final _otpController = TextEditingController();

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

  Future<void> _markOutForDelivery() async {
    try {
      await ApiClient.instance.updateDeliveryStatus(widget.orderId, 'out_for_delivery');
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _confirmOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 6-digit OTP')),
      );
      return;
    }
    setState(() => _confirming = true);
    try {
      await ApiClient.instance.verifyDeliveryOtp(widget.orderId, otp);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delivery confirmed!')));
      context.go('/delivery/orders');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _confirming = false);
    }
  }

  @override
  void dispose() { _otpController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null) return const Scaffold(body: Center(child: Text('Not found')));
    final order = _order!;

    return Scaffold(
      appBar: AppBar(title: Text('Deliver Order #${widget.orderId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${order.status.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Total: ₹${order.totalAmount.toStringAsFixed(0)}'),
            Text('Slot: ${order.deliverySlot.name}'),
            const SizedBox(height: 16),
            const Text('Map will be available after Firebase setup', style: TextStyle(color: Colors.grey)),
            const Spacer(),
            if (order.status == OrderStatus.assigned) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _markOutForDelivery, child: const Text('Mark: Out for Delivery')),
              ),
            ],
            if (order.status == OrderStatus.outForDelivery) ...[
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(labelText: 'Enter OTP from customer'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: _confirming
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(onPressed: _confirmOtp, child: const Text('Confirm Delivery')),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
