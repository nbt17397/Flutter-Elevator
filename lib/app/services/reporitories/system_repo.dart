import 'package:dio/dio.dart';

import '../../data/json_annotation/system_db.dart';
import '../base_client.dart';

class SystemRepo extends ApiProvider {
  Future<List<SystemDB>> getSystems() async {
    try {
      final Response response = await httpClient.get('systems/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => SystemDB.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load systems. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get systems: ${e.message}');
    }
  }

  Future<SystemDB> createSystem(SystemDB system) async {
    try {
      final Response response = await httpClient.post(
        'systems/',
        data: system.toJson(),
      );
      if (response.statusCode == 201) {
        return SystemDB.fromJson(response.data);
      } else {
        throw Exception('Failed to create system. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create system: ${e.message}');
    }
  }

  Future<SystemDB> updateSystem(int id, SystemDB system) async {
    try {
      final Response response = await httpClient.put(
        'systems/$id/',
        data: system.toJson(),
      );
      if (response.statusCode == 200) {
        return SystemDB.fromJson(response.data);
      } else {
        throw Exception('Failed to update system. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update system: ${e.message}');
    }
  }

  Future<void> deleteSystem(int id) async {
    try {
      final Response response = await httpClient.delete('systems/$id/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete system. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete system: ${e.message}');
    }
  }
}