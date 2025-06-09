part of 'control_bloc.dart';

abstract class ControlEvent {}

class FetchRegisters extends ControlEvent {
  final int groupId;
  FetchRegisters(this.groupId);
}
