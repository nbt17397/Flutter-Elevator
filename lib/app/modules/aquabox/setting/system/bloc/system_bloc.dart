import 'package:bloc/bloc.dart';

import '../../../../../data/json_annotation/system_db.dart';
import '../../../../../services/reporitories/system_repo.dart';

part 'system_event.dart';
part 'system_state.dart';



class SystemBloc extends Bloc<SystemEvent, SystemState> {
  final SystemRepo systemRepo;

  SystemBloc(this.systemRepo) : super(SystemInitial()) {
    on<LoadSystems>(_onLoadSystems);
    on<AddSystem>(_onAddSystem);
    on<UpdateSystem>(_onUpdateSystem);
    on<DeleteSystem>(_onDeleteSystem);
  }

  Future<void> _onLoadSystems(LoadSystems event, Emitter<SystemState> emit) async {
    try {
      emit(SystemLoading());
      final systems = await systemRepo.getSystems();
      emit(SystemLoaded(systems));
    } catch (e) {
      emit(SystemError('Failed to load systems: $e'));
    }
  }

  Future<void> _onAddSystem(AddSystem event, Emitter<SystemState> emit) async {
    try {
      emit(SystemLoading());
      await systemRepo.createSystem(event.system);
      add(LoadSystems());
    } catch (e) {
      emit(SystemError('Failed to add system: $e'));
    }
  }

  Future<void> _onUpdateSystem(UpdateSystem event, Emitter<SystemState> emit) async {
    try {
      emit(SystemLoading());
      await systemRepo.updateSystem(event.id, event.system);
      add(LoadSystems());
    } catch (e) {
      emit(SystemError('Failed to update system: $e'));
    }
  }

  Future<void> _onDeleteSystem(DeleteSystem event, Emitter<SystemState> emit) async {
    try {
      emit(SystemLoading());
      await systemRepo.deleteSystem(event.id);
      add(LoadSystems());
    } catch (e) {
      emit(SystemError('Failed to delete system: $e'));
    }
  }
}