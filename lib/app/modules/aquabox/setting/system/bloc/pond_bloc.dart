import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../../../data/json_annotation/pond_db.dart';
import '../../../../../services/reporitories/pond_repo.dart';

part 'pond_event.dart';
part 'pond_state.dart';

class PondBloc extends Bloc<PondEvent, PondState> {
  final PondRepo pondRepo;

  PondBloc(this.pondRepo) : super(PondInitial()) {
    on<LoadPonds>(_onLoadPonds);
    on<AddPond>(_onAddPond);
    on<UpdatePond>(_onUpdatePond);
    on<DeletePond>(_onDeletePond);
  }

  Future<void> _onLoadPonds(LoadPonds event, Emitter<PondState> emit) async {
    try {
      emit(PondLoading());
      final ponds = await pondRepo.getPondsBySystemId(event.systemId);
      emit(PondLoaded(ponds));
    } catch (e) {
      emit(PondError('Failed to load ponds: $e'));
    }
  }

  Future<void> _onAddPond(AddPond event, Emitter<PondState> emit) async {
    try {
      emit(PondLoading());
      await pondRepo.createPond(event.pond);
      add(LoadPonds(event.systemId));
    } catch (e) {
      emit(PondError('Failed to add pond: $e'));
    }
  }

  Future<void> _onUpdatePond(UpdatePond event, Emitter<PondState> emit) async {
    try {
      emit(PondLoading());
      await pondRepo.updatePond(event.pondId, event.pond);
      add(LoadPonds(event.systemId));
    } catch (e) {
      emit(PondError('Failed to update pond: $e'));
    }
  }

  Future<void> _onDeletePond(DeletePond event, Emitter<PondState> emit) async {
    try {
      emit(PondLoading());
      await pondRepo.deletePond(event.pondId);
      add(LoadPonds(event.systemId));
    } catch (e) {
      emit(PondError('Failed to delete pond: $e'));
    }
  }
}
