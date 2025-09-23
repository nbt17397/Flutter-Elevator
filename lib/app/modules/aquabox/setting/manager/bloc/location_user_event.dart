part of 'location_user_bloc.dart';

abstract class LocationUserEvent {}

class LoadLocationUsers extends LocationUserEvent {
  final int locationId;
  LoadLocationUsers(this.locationId);
}

class AddLocationUser extends LocationUserEvent {
  final LocationUserDB newUser;
  AddLocationUser(this.newUser);
}

class UpdateLocationUser extends LocationUserEvent {
  final LocationUserDB updatedUser;
  final int userId;
  UpdateLocationUser(this.userId, this.updatedUser);
}

class DeleteLocationUser extends LocationUserEvent {
  final int userId;
  DeleteLocationUser(this.userId);
}