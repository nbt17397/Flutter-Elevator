part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class AppStarted extends AuthenticationEvent {}

class LoggedOut extends AuthenticationEvent {}

class LoggedIn extends AuthenticationEvent {
  final String accessToken;

  LoggedIn({required this.accessToken});
}

class ShutDown extends AuthenticationEvent {}
