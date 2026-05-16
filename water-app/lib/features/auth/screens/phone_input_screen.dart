import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});
  @override State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final _controller = TextEditingController();
  final _formKey    = GlobalKey<FormState>();

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (ctx, state) {
              if (state is AuthOtpSent) {
                ctx.push('/auth/otp', extra: _controller.text.trim());
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
                    const SizedBox(height: 60),
                    const Icon(Icons.water_drop, size: 56, color: Color(0xFF0288D1)),
                    const SizedBox(height: 24),
                    const Text('Enter your phone', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('We\'ll send a verification code', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        prefixText: '+91 ',
                        labelText: 'Phone number',
                      ),
                      validator: (v) {
                        if (v == null || v.length != 10) return 'Enter a valid 10-digit number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    if (state is AuthSendingOtp)
                      const Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            ctx.read<AuthBloc>().add(SendOtpEvent(_controller.text.trim()));
                          }
                        },
                        child: const Text('Send OTP'),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
