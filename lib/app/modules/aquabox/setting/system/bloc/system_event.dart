part of 'system_bloc.dart';

abstract class SystemEvent {}

class LoadSystems extends SystemEvent {}

class AddSystem extends SystemEvent {
  final SystemDB system;
  AddSystem(this.system);
}

class UpdateSystem extends SystemEvent {
  final int id;
  final SystemDB system;
  UpdateSystem(this.id, this.system);
}

class DeleteSystem extends SystemEvent {
  final int id;
  DeleteSystem(this.id);
}
