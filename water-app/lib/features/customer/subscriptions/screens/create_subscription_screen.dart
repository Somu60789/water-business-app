import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/shared/services/api_client.dart';

class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});
  @override State<CreateSubscriptionScreen> createState() => _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  String _frequency = 'daily';
  String _slot      = 'morning';
  bool _isLoading   = false;
  final _qtyController = TextEditingController(text: '1');

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final qty = int.tryParse(_qtyController.text.trim());
    if (qty == null || qty < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity (minimum 1)')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.createSubscription({
        'vendor_id':     1,
        'product_id':    1,
        'qty':           qty,
        'frequency':     _frequency,
        'delivery_slot': _slot,
        'address_id':    1,
        'payment_mode':  'cod',
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subscription created!')));
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Subscription')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _qtyController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity')),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _frequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: const [
                DropdownMenuItem(value: 'daily',   child: Text('Daily')),
                DropdownMenuItem(value: 'weekly',  child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (v) { if (v != null) setState(() => _frequency = v); },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _slot,
              decoration: const InputDecoration(labelText: 'Delivery Slot'),
              items: const [
                DropdownMenuItem(value: 'morning',   child: Text('Morning')),
                DropdownMenuItem(value: 'afternoon', child: Text('Afternoon')),
                DropdownMenuItem(value: 'evening',   child: Text('Evening')),
              ],
              onChanged: (v) { if (v != null) setState(() => _slot = v); },
            ),
            const Spacer(),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: _submit, child: const Text('Subscribe')),
                  ),
          ],
        ),
      ),
    );
  }
}
