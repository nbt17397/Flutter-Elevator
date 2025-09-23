import 'package:dio/dio.dart';

import '../../data/json_annotation/pond_db.dart';
import '../base_client.dart';

class PondRepo extends ApiProvider {
  Future<List<PondDB>> getPondsBySystemId(int systemId) async {
    try {
      final Response response =
          await httpClient.get('systems/$systemId/ponds/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => PondDB.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load ponds. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get ponds: ${e.message}');
    }
  }

  Future<PondDB> createPond(PondDB pond) async {
    try {
      final Response response = await httpClient.post(
        'ponds/',
        data: pond.toJson(),
      );
      if (response.statusCode == 201) {
        return PondDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create pond. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create pond: ${e.message}');
    }
  }

  Future<PondDB> updatePond(int pondId, PondDB pond) async {
    try {
      final Response response = await httpClient.put(
        'ponds/$pondId/', // URL đã sửa
        data: pond.toJson(),
      );
      if (response.statusCode == 200) {
        return PondDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update pond. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update pond: ${e.message}');
    }
  }

  Future<void> deletePond(int pondId) async {
    try {
      final Response response =
          await httpClient.delete('ponds/$pondId/'); // URL đã sửa
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete pond. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete pond: ${e.message}');
    }
  }
}
