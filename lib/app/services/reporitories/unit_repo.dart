import 'package:dio/dio.dart';

import '../../data/json_annotation/unit_db.dart';
import '../base_client.dart';

class UnitRepo extends ApiProvider {
  // Method: Lấy danh sách units (Read)
  Future<List<UnitDB>> getUnits() async {
    try {
      final Response response = await httpClient.get('units/');
      
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => UnitDB.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load units. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get units: ${e.message}');
    }
  }

  // Method: Tạo một unit mới (Create)
  Future<UnitDB> createUnit(UnitDB unit) async {
    try {
      final Response response = await httpClient.post(
        'units/',
        data: unit.toJson(),
      );

      if (response.statusCode == 201) {
        return UnitDB.fromJson(response.data);
      } else {
        throw Exception('Failed to create unit. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create unit: ${e.message}');
    }
  }

  // Method: Cập nhật một unit (Update)
  Future<UnitDB> updateUnit(int id, UnitDB unit) async {
    try {
      final Response response = await httpClient.put(
        'units/$id/',
        data: unit.toJson(),
      );

      if (response.statusCode == 200) {
        return UnitDB.fromJson(response.data);
      } else {
        throw Exception('Failed to update unit. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update unit: ${e.message}');
    }
  }

  // Method: Xóa một unit (Delete)
  Future<void> deleteUnit(int id) async {
    try {
      final Response response = await httpClient.delete('units/$id/');
      
      if (response.statusCode != 204) {
        throw Exception('Failed to delete unit. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete unit: ${e.message}');
    }
  }
}