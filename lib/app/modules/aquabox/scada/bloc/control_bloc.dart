import 'package:bloc/bloc.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/services/reporitories/board_repo.dart';

part 'control_event.dart';
part 'control_state.dart';

class ControlBloc extends Bloc<ControlEvent, ControlState> {
  final BoardRepo boardRepo = BoardRepo();

  ControlBloc() : super(ControlInitial()) {
    on<ControlEvent>((event, emit) async {
      if (event is FetchRegisters) {
        emit(GetRegisterLoading());
        try {
          final registers = await boardRepo.getRegisterByGroupID(id: event.groupId);
          final results = registers.results ?? [];

          if (results.isEmpty) {
            emit(GetRegisterEmpty());
          } else {
            emit(GetRegisterLoaded(results));
          }
        } catch (e) {
          emit(GetRegisterError(e.toString()));
        }
      }
    });
  }
}
