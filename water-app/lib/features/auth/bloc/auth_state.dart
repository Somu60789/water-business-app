import 'package:equatable/equatable.dart';
import 'package:water_app/shared/models/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();
}

class AuthInitial         extends AuthState { const AuthInitial();         @override List<Object> get props => []; }
class AuthSendingOtp      extends AuthState { const AuthSendingOtp();      @override List<Object> get props => []; }
class AuthOtpSent         extends AuthState { const AuthOtpSent();         @override List<Object> get props => []; }
class AuthVerifying       extends AuthState { const AuthVerifying();        @override List<Object> get props => []; }
class AuthUnauthenticated extends AuthState { const AuthUnauthenticated();  @override List<Object> get props => []; }

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override List<Object> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override List<Object> get props => [message];
}
