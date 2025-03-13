part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {}

class AuthenticationUninitialized extends AuthenticationState {}

class AuthenticationAuthenticated extends AuthenticationState {
  final String accessToken;


  AuthenticationAuthenticated(
      {required this.accessToken});
}

class AuthenticationUnauthenticated extends AuthenticationState {
  final int type;

  AuthenticationUnauthenticated({this.type = 0});
}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationFailure extends AuthenticationState {
  final String message;

  AuthenticationFailure({required this.message});
}