part of 'location_user_bloc.dart';

abstract class LocationUserState {}

class LocationUserInitial extends LocationUserState {}

class LocationUserLoading extends LocationUserState {}

class LocationUserLoaded extends LocationUserState {
  final List<LocationUserDB> locationUsers;
  LocationUserLoaded({this.locationUsers = const []});
}

class LocationUserError extends LocationUserState {
  final String message;
  LocationUserError(this.message);
}