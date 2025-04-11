part of 'location_bloc.dart';

@immutable
sealed class LocationState {}

final class LocationInitial extends LocationState {}

class GetLocationLoading extends LocationState {}

class GetLocationEmpty extends LocationState {}

class GetLocationLoaded extends LocationState {
  final List<LocationDB> locations;
  final double currentLatitude;
  final double currentLongitude;

  GetLocationLoaded({
    required this.locations,
    required this.currentLatitude,
    required this.currentLongitude,
  });
}

class GetLocationFailure extends LocationState {
  final String error;

  GetLocationFailure({required this.error});
}
