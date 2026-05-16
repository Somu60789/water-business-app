import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:water_app/features/auth/bloc/auth_bloc.dart';
import 'package:water_app/features/auth/bloc/auth_event.dart';
import 'package:water_app/features/auth/bloc/auth_state.dart';
import 'package:water_app/features/auth/repository/auth_repository.dart';
import 'package:water_app/shared/models/user.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthBloc bloc;
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    bloc = AuthBloc(repository: mockRepo);
  });

  tearDown(() => bloc.close());

  blocTest<AuthBloc, AuthState>(
    'emits [sendingOtp, otpSent] on SendOtpEvent success',
    build: () {
      when(() => mockRepo.sendOtp('9876543210')).thenAnswer((_) async => {});
      return bloc;
    },
    act: (b) => b.add(const SendOtpEvent('9876543210')),
    expect: () => [isA<AuthSendingOtp>(), isA<AuthOtpSent>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [verifying, authenticated] on VerifyOtpEvent success',
    build: () {
      const user = User(id: 1, name: 'Test', phone: '9876543210', role: UserRole.customer, isActive: true);
      when(() => mockRepo.verifyOtp('9876543210', '123456')).thenAnswer((_) async => user);
      return bloc;
    },
    act: (b) => b.add(const VerifyOtpEvent('9876543210', '123456')),
    expect: () => [isA<AuthVerifying>(), isA<AuthAuthenticated>()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [verifying, error] on VerifyOtpEvent failure',
    build: () {
      when(() => mockRepo.verifyOtp(any(), any())).thenThrow(Exception('Invalid OTP'));
      return bloc;
    },
    act: (b) => b.add(const VerifyOtpEvent('9876543210', '000000')),
    expect: () => [isA<AuthVerifying>(), isA<AuthError>()],
  );
}
