import 'package:bloc/bloc.dart';

import '../../../../../data/json_annotation/animal_type_db.dart';
import '../../../../../services/reporitories/animal_type_repo.dart';

part 'animal_type_event.dart';
part 'animal_type_state.dart';

class AnimalTypeBloc extends Bloc<AnimalTypeEvent, AnimalTypeState> {
  final AnimalTypeRepo animalTypeRepo;

  AnimalTypeBloc(this.animalTypeRepo) : super(AnimalTypeInitial()) {
    on<LoadAnimalTypes>(_onLoadAnimalTypes);
    on<AddAnimalType>(_onAddAnimalType);
    on<UpdateAnimalType>(_onUpdateAnimalType);
    on<DeleteAnimalType>(_onDeleteAnimalType);
  }

  Future<void> _onLoadAnimalTypes(LoadAnimalTypes event, Emitter<AnimalTypeState> emit) async {
    try {
      emit(AnimalTypeLoading());
      final animalTypes = await animalTypeRepo.getAnimalTypes();
      emit(AnimalTypeLoaded(animalTypes));
    } catch (e) {
      emit(AnimalTypeError('Không thể tải dữ liệu: $e'));
    }
  }

  Future<void> _onAddAnimalType(AddAnimalType event, Emitter<AnimalTypeState> emit) async {
    try {
      emit(AnimalTypeLoading());
      await animalTypeRepo.createAnimalType(event.animalType);
      add(LoadAnimalTypes());
    } catch (e) {
      emit(AnimalTypeError('Không thể thêm loại động vật: $e'));
    }
  }

  Future<void> _onUpdateAnimalType(UpdateAnimalType event, Emitter<AnimalTypeState> emit) async {
    try {
      emit(AnimalTypeLoading());
      await animalTypeRepo.updateAnimalType(event.id, event.animalType);
      add(LoadAnimalTypes());
    } catch (e) {
      emit(AnimalTypeError('Không thể cập nhật loại động vật: $e'));
    }
  }

  Future<void> _onDeleteAnimalType(DeleteAnimalType event, Emitter<AnimalTypeState> emit) async {
    try {
      emit(AnimalTypeLoading());
      await animalTypeRepo.deleteAnimalType(event.id);
      add(LoadAnimalTypes());
    } catch (e) {
      emit(AnimalTypeError('Không thể xóa loại động vật: $e'));
    }
  }
}