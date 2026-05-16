import 'package:water_app/shared/models/user.dart';
import 'package:water_app/shared/services/api_client.dart';
import 'package:water_app/shared/services/auth_service.dart';

class AuthRepository {
  final ApiClient _api;
  final AuthService _authService;

  AuthRepository({ApiClient? api, AuthService? authService})
      : _api         = api ?? ApiClient(),
        _authService = authService ?? AuthService();

  Future<void> sendOtp(String phone) async {
    await _api.sendOtp(phone);
  }

  Future<User> verifyOtp(String phone, String otp) async {
    final response = await _api.verifyOtp(phone, otp);
    final data     = response['data'] as Map<String, dynamic>;
    final token    = data['token'] as String;
    final userJson = data['user'] as Map<String, dynamic>;
    await _authService.saveSession(token, userJson);
    return User.fromJson(userJson);
  }

  Future<User?> checkAuth() async {
    final userJson = await _authService.getUser();
    if (userJson == null) return null;
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    await _authService.clearSession();
  }
}
