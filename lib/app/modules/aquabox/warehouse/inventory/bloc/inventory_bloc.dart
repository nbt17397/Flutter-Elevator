import 'package:bloc/bloc.dart';

import '../../../../../data/json_annotation/inventory_db.dart';
import '../../../../../services/reporitories/inventory_repo.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';


class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepo inventoryRepo;

  InventoryBloc(this.inventoryRepo) : super(InventoryInitial()) {
    on<LoadInventories>(_onLoadInventories);
    on<AddInventory>(_onAddInventory);
    on<UpdateInventory>(_onUpdateInventory);
    on<DeleteInventory>(_onDeleteInventory);
  }

  Future<void> _onLoadInventories(LoadInventories event, Emitter<InventoryState> emit) async {
    try {
      emit(InventoryLoading());
      final inventories = await inventoryRepo.getInventories();
      emit(InventoryLoaded(inventories));
    } catch (e) {
      emit(InventoryError('Failed to load inventories: $e'));
    }
  }

  Future<void> _onAddInventory(AddInventory event, Emitter<InventoryState> emit) async {
    try {
      await inventoryRepo.createInventory(event.inventory);
      add(LoadInventories());
    } catch (e) {
      emit(InventoryError('Failed to add inventory: $e'));
    }
  }

  Future<void> _onUpdateInventory(UpdateInventory event, Emitter<InventoryState> emit) async {
    try {
      await inventoryRepo.updateInventory(event.inventory.id, event.inventory);
      add(LoadInventories());
    } catch (e) {
      emit(InventoryError('Failed to update inventory: $e'));
    }
  }

  Future<void> _onDeleteInventory(DeleteInventory event, Emitter<InventoryState> emit) async {
    try {
      await inventoryRepo.deleteInventory(event.id);
      add(LoadInventories());
    } catch (e) {
      emit(InventoryError('Failed to delete inventory: $e'));
    }
  }
}