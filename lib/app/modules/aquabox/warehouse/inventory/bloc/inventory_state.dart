part of 'inventory_bloc.dart';


abstract class InventoryState {}

class InventoryInitial extends InventoryState {}

class InventoryLoading extends InventoryState {}

class InventoryLoaded extends InventoryState {
  final List<InventoryDB> inventories;
  InventoryLoaded(this.inventories);
}

class InventoryError extends InventoryState {
  final String message;
  InventoryError(this.message);
}
