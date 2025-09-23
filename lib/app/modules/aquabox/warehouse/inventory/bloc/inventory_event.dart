part of 'inventory_bloc.dart';


abstract class InventoryEvent {}

class LoadInventories extends InventoryEvent {}

class AddInventory extends InventoryEvent {
  final InventoryDB inventory;
  AddInventory(this.inventory);
}

class UpdateInventory extends InventoryEvent {
  final InventoryDB inventory;
  UpdateInventory(this.inventory);
}

class DeleteInventory extends InventoryEvent {
  final int id;
  DeleteInventory(this.id);
}
