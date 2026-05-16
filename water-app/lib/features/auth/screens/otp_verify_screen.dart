import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String phone;
  const OtpVerifyScreen({super.key, required this.phone});
  @override State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (ctx, state) {
            if (state is AuthAuthenticated) {
              switch (state.user.role.name) {
                case 'vendor':      ctx.go('/vendor/dashboard'); break;
                case 'deliveryBoy': ctx.go('/delivery/orders'); break;
                default:            ctx.go('/customer/home');
              }
            } else if (state is AuthError) {
              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (ctx, state) {
            return Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Code sent to +91 ${widget.phone}', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 24, letterSpacing: 8),
                    decoration: const InputDecoration(labelText: 'Enter 6-digit OTP'),
                    validator: (v) {
                      if (v == null || v.length != 6) return 'Enter the 6-digit OTP';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  if (state is AuthVerifying)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          ctx.read<AuthBloc>().add(VerifyOtpEvent(widget.phone, _controller.text));
                        }
                      },
                      child: const Text('Verify'),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
