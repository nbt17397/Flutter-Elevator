import 'package:bloc/bloc.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/services/reporitories/board_repo.dart';

part 'control_event.dart';
part 'control_state.dart';

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  BoardRepo boardRepo = BoardRepo();
  ControlBloc() : super(ControlInitial()) {
    on<ControlEvent>((event, emit) async {
      if (event is FetchRegisters) {
        emit(GetRegisterLoading());
        try {
          final registers =
              await boardRepo.getRegisterByGroupID(id: event.groupId);
          if (registers.results?.length == 0)
            emit(GetRegisterEmpty());
          else
            emit(GetRegisterLoaded(registers.results ?? []));
        } catch (e) {
          emit(GetRegisterError(e.toString()));
        }
      }
    });
  }
}
