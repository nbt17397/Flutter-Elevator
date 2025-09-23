part of 'pond_bloc.dart';

abstract class PondState {}

class PondInitial extends PondState {}

class PondLoading extends PondState {}

class PondLoaded extends PondState {
  final List<PondDB> ponds;
  PondLoaded(this.ponds);
}

class PondError extends PondState {
  final String message;
  PondError(this.message);
}