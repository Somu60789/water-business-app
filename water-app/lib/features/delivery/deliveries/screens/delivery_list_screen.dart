import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});
  @override State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startLocationBroadcast();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getDeliveryOrders();
      if (!mounted) return;
      setState(() { _orders = data.map(Order.fromJson).toList(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startLocationBroadcast() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        final pos = await Geolocator.getCurrentPosition();
        await ApiClient.instance.pushLocation(pos.latitude, pos.longitude);
      } catch (_) {}
    });
  }

  @override
  void dispose() { _locationTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Deliveries')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No deliveries assigned'))
              : ListView.builder(
                  itemCount: _orders.length,
                  itemBuilder: (_, i) {
                    final o = _orders[i];
                    return ListTile(
                      title:    Text('Order #${o.id}'),
                      subtitle: Text('Slot: ${o.deliverySlot.name} — ${o.status.name}'),
                      trailing: const Icon(Icons.navigation),
                      onTap:    () => context.push('/delivery/navigate/${o.id}'),
                    );
                  },
                ),
    );
  }
}
