import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  const SendOtpEvent(this.phone);
  @override List<Object> get props => [phone];
}

class VerifyOtpEvent extends AuthEvent {
  final String phone;
  final String otp;
  const VerifyOtpEvent(this.phone, this.otp);
  @override List<Object> get props => [phone, otp];
}

class CheckAuthEvent extends AuthEvent {
  const CheckAuthEvent();
  @override List<Object> get props => [];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
  @override List<Object> get props => [];
}
