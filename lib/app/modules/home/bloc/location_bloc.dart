import 'package:bloc/bloc.dart';
import 'package:elevator/app/services/reporitories/user_repo.dart';
import 'package:meta/meta.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/response/location_response.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final UserRepo _userRepo = UserRepo();

  LocationBloc() : super(LocationInitial()) {
    on<GetLocationByUser>((event, emit) async {
      emit(GetLocationLoading());
      try {
        LocationResponse resp = await _userRepo.getLocation();
        List<LocationDB> locations = resp.results ?? [];

        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        if (locations.isEmpty) {
          emit(GetLocationEmpty());
        } else {
          emit(GetLocationLoaded(
            locations: locations,
            currentLatitude: position.latitude,
            currentLongitude: position.longitude,
          ));
        }
      } catch (e) {
        print(e);
        emit(GetLocationFailure(error: e.toString()));
      }
    });
  }
}
