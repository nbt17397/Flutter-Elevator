import 'package:dio/dio.dart';

import '../../data/json_annotation/animal_type_db.dart';
import '../base_client.dart';

class AnimalTypeRepo extends ApiProvider {
  // Lấy danh sách các loại động vật (Read)
  Future<List<AnimalTypeDB>> getAnimalTypes() async {
    try {
      final Response response = await httpClient.get('animal-types/');
      
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => AnimalTypeDB.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load animal types. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get animal types: ${e.message}');
    }
  }

  // Tạo một loại động vật mới (Create)
  Future<AnimalTypeDB> createAnimalType(AnimalTypeDB animalType) async {
    try {
      final Response response = await httpClient.post(
        'animal-types/',
        data: animalType.toJson(),
      );

      if (response.statusCode == 201) {
        return AnimalTypeDB.fromJson(response.data);
      } else {
        throw Exception('Failed to create animal type. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create animal type: ${e.message}');
    }
  }

  // Cập nhật một loại động vật (Update)
  Future<AnimalTypeDB> updateAnimalType(int id, AnimalTypeDB animalType) async {
    try {
      final Response response = await httpClient.put(
        'animal-types/$id/',
        data: animalType.toJson(),
      );

      if (response.statusCode == 200) {
        return AnimalTypeDB.fromJson(response.data);
      } else {
        throw Exception('Failed to update animal type. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update animal type: ${e.message}');
    }
  }

  // Xóa một loại động vật (Delete)
  Future<void> deleteAnimalType(int id) async {
    try {
      final Response response = await httpClient.delete('animal-types/$id/');
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete animal type. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete animal type: ${e.message}');
    }
  }
}