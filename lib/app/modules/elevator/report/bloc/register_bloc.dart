import 'package:bloc/bloc.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/services/reporitories/board_repo.dart';
import 'package:meta/meta.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  BoardRepo boardRepo = BoardRepo();

  RegisterBloc() : super(RegisterInitial()) {
    on<FetchRegisterEvent>((event, emit) async {
      emit(RegisterLoading());
      try {
        final response =
            await boardRepo.getRegisterByBoardID(id: event.boardId);
        emit(RegisterLoaded(response));
      } catch (e) {
        emit(RegisterError(e.toString()));
      }
    });
  }
}
