
part of 'unit_bloc.dart';

abstract class UnitEvent {}

class LoadUnits extends UnitEvent {}

class AddUnit extends UnitEvent {
  final UnitDB unit;
  AddUnit(this.unit);
}

class UpdateUnit extends UnitEvent {
  final int id;
  final UnitDB unit;
  UpdateUnit(this.id, this.unit);
}

class DeleteUnit extends UnitEvent {
  final int id;
  DeleteUnit(this.id);
}