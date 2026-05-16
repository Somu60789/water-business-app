import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:water_app/features/auth/bloc/auth_bloc.dart';
import 'package:water_app/features/auth/bloc/auth_event.dart';
import 'package:water_app/features/auth/bloc/auth_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (ctx, state) {
          if (state is! AuthAuthenticated) return const SizedBox();
          final user = state.user;
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              CircleAvatar(radius: 40, child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 32))),
              const SizedBox(height: 16),
              Text(user.name, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('+91 ${user.phone}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('My Orders'),
                onTap: () => ctx.push('/customer/orders'),
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Subscriptions'),
                onTap: () => ctx.push('/customer/subscriptions'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  ctx.read<AuthBloc>().add(const LogoutEvent());
                  ctx.go('/auth/phone');
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
