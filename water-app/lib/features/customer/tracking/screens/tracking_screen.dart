import 'dart:async';
import 'package:flutter/material.dart';
import 'package:water_app/shared/services/api_client.dart';

class TrackingScreen extends StatefulWidget {
  final int orderId;
  const TrackingScreen({super.key, required this.orderId});
  @override State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _status = 'Loading...';
  double? _lat;
  double? _lng;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final data = await ApiClient.instance.getTracking(widget.orderId);
      if (!mounted) return;
      setState(() {
        _status = data['status'] as String? ?? 'unknown';
        final loc = data['location'] as Map<String, dynamic>?;
        if (loc != null) {
          _lat = (loc['lat'] as num?)?.toDouble();
          _lng = (loc['lng'] as num?)?.toDouble();
        }
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tracking Order #${widget.orderId}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_shipping, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text('Status: $_status', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              if (_lat != null && _lng != null) ...[
                const SizedBox(height: 16),
                Text('Location: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}', style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 32),
              const Text('Map will be available after setup', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
