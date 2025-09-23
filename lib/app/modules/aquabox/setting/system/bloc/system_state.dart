part of 'system_bloc.dart';


abstract class SystemState {}

class SystemInitial extends SystemState {}

class SystemLoading extends SystemState {}

class SystemLoaded extends SystemState {
  final List<SystemDB> systems;
  SystemLoaded(this.systems);
}

class SystemError extends SystemState {
  final String message;
  SystemError(this.message);
}