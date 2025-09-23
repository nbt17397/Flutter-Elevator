part of 'animal_type_bloc.dart';


abstract class AnimalTypeState {}

class AnimalTypeInitial extends AnimalTypeState {}

class AnimalTypeLoading extends AnimalTypeState {}

class AnimalTypeLoaded extends AnimalTypeState {
  final List<AnimalTypeDB> animalTypes;
  AnimalTypeLoaded(this.animalTypes);
}

class AnimalTypeError extends AnimalTypeState {
  final String message;
  AnimalTypeError(this.message);
}
