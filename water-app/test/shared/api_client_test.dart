import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:water_app/shared/services/api_client.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient.withDio(mockDio);
  });

  test('sendOtp calls POST /auth/send-otp', () async {
    when(() => mockDio.post(
      '/auth/send-otp',
      data: {'phone': '9876543210'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/auth/send-otp'),
      data: {'success': true, 'message': 'OTP sent'},
      statusCode: 200,
    ));

    final result = await apiClient.sendOtp('9876543210');
    expect(result['success'], true);
  });

  test('verifyOtp returns token on success', () async {
    when(() => mockDio.post(
      '/auth/verify-otp',
      data: {'phone': '9876543210', 'otp': '123456'},
    )).thenAnswer((_) async => Response(
      requestOptions: RequestOptions(path: '/auth/verify-otp'),
      data: {'success': true, 'data': {'token': 'abc123', 'user': {'id': 1, 'name': 'Test', 'phone': '9876543210', 'role': 'customer', 'is_active': true}}},
      statusCode: 200,
    ));

    final result = await apiClient.verifyOtp('9876543210', '123456');
    expect(result['data']['token'], 'abc123');
  });
}
