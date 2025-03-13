part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class Login extends LoginEvent {
  final String user;
  final String password;

  Login({required this.user, required this.password});
}

class Logout extends LoginEvent {}