part of 'pond_bloc.dart';

abstract class PondEvent {}

class LoadPonds extends PondEvent {
  final int systemId;
  LoadPonds(this.systemId);
}

class AddPond extends PondEvent {
  final int systemId;
  final PondDB pond;
  AddPond(this.systemId, this.pond);
}

class UpdatePond extends PondEvent {
  final int systemId;
  final int pondId;
  final PondDB pond;
  UpdatePond(this.systemId, this.pondId, this.pond);
}

class DeletePond extends PondEvent {
  final int systemId;
  final int pondId;
  DeletePond(this.systemId, this.pondId);
}