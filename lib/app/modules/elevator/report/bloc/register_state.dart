part of 'register_bloc.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}


class RegisterLoading extends RegisterState {}

class RegisterLoaded extends RegisterState {
  final RegisterResponse data;
  RegisterLoaded(this.data);
}

class RegisterError extends RegisterState {
  final String message;
  RegisterError(this.message);
}