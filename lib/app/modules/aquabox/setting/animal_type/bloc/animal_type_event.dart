part of 'animal_type_bloc.dart';

abstract class AnimalTypeEvent {}

class LoadAnimalTypes extends AnimalTypeEvent {}

class AddAnimalType extends AnimalTypeEvent {
  final AnimalTypeDB animalType;
  AddAnimalType(this.animalType);
}

class UpdateAnimalType extends AnimalTypeEvent {
  final int id;
  final AnimalTypeDB animalType;
  UpdateAnimalType(this.id, this.animalType);
}

class DeleteAnimalType extends AnimalTypeEvent {
  final int id;
  DeleteAnimalType(this.id);
}
