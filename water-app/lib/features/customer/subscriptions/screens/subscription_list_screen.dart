import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:water_app/shared/models/subscription.dart';
import 'package:water_app/shared/services/api_client.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});
  @override State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  List<Subscription> _subs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.getSubscriptions();
      if (!mounted) return;
      setState(() { _subs = data.map(Subscription.fromJson).toList(); _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Subscriptions')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/customer/subscriptions/create'),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _subs.isEmpty
              ? const Center(child: Text('No active subscriptions'))
              : ListView.builder(
                  itemCount: _subs.length,
                  itemBuilder: (_, i) {
                    final s = _subs[i];
                    return ListTile(
                      title:    Text('Product #${s.productId} × ${s.qty}'),
                      subtitle: Text('${s.frequency} — Next: ${DateFormat('dd MMM').format(s.nextDeliveryDate)}'),
                      trailing: Switch(
                        value: s.isActive,
                        onChanged: (_) {},
                      ),
                    );
                  },
                ),
    );
  }
}
