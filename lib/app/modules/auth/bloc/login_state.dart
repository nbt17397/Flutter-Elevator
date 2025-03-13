part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String accessToken;

  LoginSuccess({required this.accessToken});
}

class LoginError extends LoginState {
  final String error;

  LoginError({required this.error});
}

class LogoutLoading extends LoginState {}

class LogoutSuccess extends LoginState {}

class LogoutFailure extends LoginState {
  final String message;

  LogoutFailure({required this.message});
}