import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/vendor_list_cubit.dart';
import 'package:water_app/shared/services/api_client.dart';
import 'package:water_app/shared/models/vendor.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorListCubit(api: ApiClient.instance),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) context.read<VendorListCubit>().fetchVendors(12.97, 77.59);
        return;
      }
      final pos = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      context.read<VendorListCubit>().fetchVendors(pos.latitude, pos.longitude);
    } catch (_) {
      if (mounted) context.read<VendorListCubit>().fetchVendors(12.97, 77.59);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Vendors'),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_cart), onPressed: () => context.push('/customer/cart')),
          IconButton(icon: const Icon(Icons.history),       onPressed: () => context.push('/customer/orders')),
          IconButton(icon: const Icon(Icons.person),        onPressed: () => context.push('/customer/profile')),
        ],
      ),
      body: BlocBuilder<VendorListCubit, VendorListState>(
        builder: (ctx, state) {
          if (state is VendorListLoading) return const Center(child: CircularProgressIndicator());
          if (state is VendorListError)   return Center(child: Text(state.message));
          if (state is VendorListLoaded) {
            if (state.vendors.isEmpty) return const Center(child: Text('No vendors nearby'));
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.vendors.length,
              itemBuilder: (_, i) => _VendorCard(vendor: state.vendors[i]),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  final Vendor vendor;
  const _VendorCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.store)),
        title:    Text(vendor.businessName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(vendor.address),
        trailing: vendor.distance != null
            ? Text('${vendor.distance!.toStringAsFixed(1)} km')
            : null,
        onTap: () => context.push('/customer/cart', extra: vendor),
      ),
    );
  }
}
