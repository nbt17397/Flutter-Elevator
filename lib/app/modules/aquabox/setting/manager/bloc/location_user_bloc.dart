import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../data/json_annotation/location_user_db.dart';
import '../../../../../services/reporitories/location_user_repo.dart';

part 'location_user_event.dart';
part 'location_user_state.dart';

class LocationUserBloc extends Bloc<LocationUserEvent, LocationUserState> {
  final LocationUserRepo locationUserRepo;

  LocationUserBloc(this.locationUserRepo) : super(LocationUserInitial()) {
    on<LoadLocationUsers>(_onLoadLocationUsers);
    on<AddLocationUser>(_onAddLocationUser);
    on<UpdateLocationUser>(_onUpdateLocationUser);
    on<DeleteLocationUser>(_onDeleteLocationUser);
  }

  Future<void> _onLoadLocationUsers(
      LoadLocationUsers event, Emitter<LocationUserState> emit) async {
    emit(LocationUserLoading());
    try {
      final users =
          await locationUserRepo.getLocationUsersByLocationId(event.locationId);
      emit(LocationUserLoaded(locationUsers: users));
    } catch (e) {
      emit(LocationUserError(e.toString()));
    }
  }

  Future<void> _onAddLocationUser(
      AddLocationUser event, Emitter<LocationUserState> emit) async {
    try {
      emit(LocationUserLoading());
      await locationUserRepo.createLocationUser(event.newUser);
      // Giả định bạn cần biết locationId hiện tại để tải lại
      // Nếu màn hình có locationId, bạn cần truyền nó vào đây
      // (ví dụ: từ màn hình đã gọi bloc)
    } catch (e) {
      emit(LocationUserError(e.toString()));
    }
  }

  Future<void> _onUpdateLocationUser(
      UpdateLocationUser event, Emitter<LocationUserState> emit) async {
    try {
      emit(LocationUserLoading());
      await locationUserRepo.updateLocationUser(
          event.userId, event.updatedUser);
      // Tương tự, cần locationId để tải lại
    } catch (e) {
      emit(LocationUserError(e.toString()));
    }
  }

  Future<void> _onDeleteLocationUser(
      DeleteLocationUser event, Emitter<LocationUserState> emit) async {
    try {
      emit(LocationUserLoading());
      await locationUserRepo.deleteLocationUser(event.userId);
      // Tương tự, cần locationId để tải lại
    } catch (e) {
      emit(LocationUserError(e.toString()));
    }
  }
}
