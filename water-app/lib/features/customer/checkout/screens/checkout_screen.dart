import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/features/customer/cart/bloc/cart_cubit.dart';
import 'package:water_app/shared/services/api_client.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _slot        = 'morning';
  String _paymentMode = 'cod';
  bool _isLoading     = false;

  Future<void> _placeOrder(BuildContext context) async {
    setState(() => _isLoading = true);
    final cartCubit      = context.read<CartCubit>();
    final messenger      = ScaffoldMessenger.of(context);
    final router         = GoRouter.of(context);
    try {
      final cartState = cartCubit.state as CartUpdated;
      final items = cartState.items.entries
          .map((e) => {'product_id': e.key.id, 'qty': e.value})
          .toList();

      final api = ApiClient();
      await api.placeOrder({
        'vendor_id':     cartState.items.keys.first.vendorId,
        'address_id':    1,
        'delivery_slot': _slot,
        'payment_mode':  _paymentMode,
        'items':         items,
      });

      cartCubit.clear();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Order placed!')));
      router.go('/customer/orders');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Delivery Slot', style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _slot,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'morning',   child: Text('Morning (6am–12pm)')),
                DropdownMenuItem(value: 'afternoon', child: Text('Afternoon (12–4pm)')),
                DropdownMenuItem(value: 'evening',   child: Text('Evening (4–8pm)')),
              ],
              onChanged: (v) => setState(() => _slot = v!),
            ),
            const SizedBox(height: 24),
            const Text('Payment', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile<String>(
              title: const Text('Cash on Delivery'),
              value: 'cod',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            RadioListTile<String>(
              title: const Text('Pay Online (Razorpay)'),
              value: 'online',
              groupValue: _paymentMode,
              onChanged: (v) => setState(() => _paymentMode = v!),
            ),
            const Spacer(),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _placeOrder(context),
                      child: const Text('Place Order'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
