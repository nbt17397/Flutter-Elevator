import 'package:bloc/bloc.dart';
import 'package:elevator/app/services/reporitories/user_repo.dart';
import 'package:meta/meta.dart';

import '../../../data/response/location_response.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final UserRepo _userRepo = UserRepo();
  LocationBloc() : super(LocationInitial()) {
    on<LocationEvent>((event, emit) async {
      if (event is GetLocationByUser) {
        emit(GetLocationLoading());
        try {
          LocationResponse resp = await _userRepo.getLocation();
          if (resp.results?.length == 0)
            emit(GetLocationEmpty());
          else
            emit(GetLocationLoaded(locations: resp.results ?? []));
        } catch (e) {
          print(e);
          emit(GetLocationFailure(error: e.toString()));
        }
      }
    });
  }
}
