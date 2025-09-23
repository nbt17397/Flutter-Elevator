import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/json_annotation/unit_db.dart';
import '../../../../../services/reporitories/unit_repo.dart';

part 'unit_event.dart';
part 'unit_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final UnitRepo unitRepo;

  UnitBloc(this.unitRepo) : super(UnitInitial()) {
    on<LoadUnits>(_onLoadUnits);
    on<AddUnit>(_onAddUnit);
    on<UpdateUnit>(_onUpdateUnit);
    on<DeleteUnit>(_onDeleteUnit);
  }

  Future<void> _onLoadUnits(LoadUnits event, Emitter<UnitState> emit) async {
    try {
      emit(UnitLoading());
      final units = await unitRepo.getUnits();
      emit(UnitLoaded(units));
    } catch (e) {
      emit(UnitError('Không thể tải dữ liệu đơn vị: $e'));
    }
  }

  Future<void> _onAddUnit(AddUnit event, Emitter<UnitState> emit) async {
    try {
      emit(UnitLoading());
      await unitRepo.createUnit(event.unit);
      add(LoadUnits()); // Tải lại danh sách sau khi thêm thành công
    } catch (e) {
      emit(UnitError('Không thể thêm đơn vị: $e'));
    }
  }

  Future<void> _onUpdateUnit(UpdateUnit event, Emitter<UnitState> emit) async {
    try {
      emit(UnitLoading());
      await unitRepo.updateUnit(event.id, event.unit);
      add(LoadUnits()); // Tải lại danh sách
    } catch (e) {
      emit(UnitError('Không thể cập nhật đơn vị: $e'));
    }
  }

  Future<void> _onDeleteUnit(DeleteUnit event, Emitter<UnitState> emit) async {
    try {
      emit(UnitLoading());
      await unitRepo.deleteUnit(event.id);
      add(LoadUnits()); // Tải lại danh sách
    } catch (e) {
      emit(UnitError('Không thể xóa đơn vị: $e'));
    }
  }
}