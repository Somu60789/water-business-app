import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/order_history_cubit.dart';
import 'package:water_app/shared/models/order.dart';
import 'package:water_app/shared/services/api_client.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OrderHistoryCubit(api: ApiClient.instance)..load(),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          builder: (ctx, state) {
            if (state is OrderHistoryLoading) return const Center(child: CircularProgressIndicator());
            if (state is OrderHistoryError)   return Center(child: Text(state.message));
            if (state is OrderHistoryLoaded) {
              if (state.orders.isEmpty) return const Center(child: Text('No orders yet'));
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (_, i) => _OrderTile(order: state.orders[i]),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  Color _statusColor() => switch (order.status) {
    OrderStatus.delivered      => Colors.green,
    OrderStatus.cancelled      => Colors.red,
    OrderStatus.outForDelivery => Colors.blue,
    _                          => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Order #${order.id}'),
      subtitle: Text(DateFormat('dd MMM yyyy').format(order.createdAt)),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('₹${order.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _statusColor(), borderRadius: BorderRadius.circular(4)),
            child: Text(order.status.name, style: const TextStyle(color: Colors.white, fontSize: 11)),
          ),
        ],
      ),
      onTap: () {
        if (order.status == OrderStatus.outForDelivery) {
          context.push('/customer/tracking/${order.id}');
        }
      },
    );
  }
}
