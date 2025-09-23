import 'package:dio/dio.dart';

import '../../data/json_annotation/location_user_db.dart';
import '../base_client.dart';

class LocationUserRepo extends ApiProvider {
  // Phương thức: GET - Lấy danh sách người dùng cho một địa điểm cụ thể.
  // URL này vẫn lồng nhau để đảm bảo lấy đúng dữ liệu.
  Future<List<LocationUserDB>> getLocationUsersByLocationId(
      int locationId) async {
    try {
      final Response response =
          await httpClient.get('locations/$locationId/accessible_locations/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => LocationUserDB.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load location users. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get location users: ${e.message}');
    }
  }

  // Phương thức: CREATE - Tạo người dùng mới cho địa điểm.
  // URL được thay đổi thành '/location-users/'.
  Future<LocationUserDB> createLocationUser(LocationUserDB locationUser) async {
    try {
      final Response response = await httpClient.post(
        'location-users/',
        data: locationUser.toJson(),
      );
      if (response.statusCode == 201) {
        return LocationUserDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create location user. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create location user: ${e.message}');
    }
  }

  // Phương thức: UPDATE - Sửa thông tin người dùng cho địa điểm.
  // URL được thay đổi thành '/location-users/{user_id}/'.
  Future<LocationUserDB> updateLocationUser(
      int userId, LocationUserDB locationUser) async {
    try {
      final Response response = await httpClient.put(
        'location-users/$userId/',
        data: locationUser.toJson(),
      );
      if (response.statusCode == 200) {
        return LocationUserDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update location user. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update location user: ${e.message}');
    }
  }

  // Phương thức: DELETE - Xóa người dùng khỏi địa điểm.
  // URL được thay đổi thành '/location-users/{user_id}/'.
  Future<void> deleteLocationUser(int userId) async {
    try {
      final Response response =
          await httpClient.delete('location-users/$userId/');
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete location user. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete location user: ${e.message}');
    }
  }
}
