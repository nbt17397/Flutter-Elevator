part of 'control_bloc.dart';

abstract class ControlState {}

class ControlInitial extends ControlState {}

class GetRegisterLoading extends ControlState {}

class GetRegisterEmpty extends ControlState {}

class GetRegisterLoaded extends ControlState {
  final List<RegisterDB> registers;
  GetRegisterLoaded(this.registers);
}

class GetRegisterError extends ControlState {
  final String message;
  GetRegisterError(this.message);
}


