import 'package:dio/dio.dart';
import 'package:elevator/app/data/local/hive_service.dart';
import 'package:elevator/app/data/models/user_model.dart';

import '../../data/response/location_response.dart';
import '../../data/response/login_response.dart';
import '../base_client.dart';

class UserRepo extends ApiProvider {
  Future<List<UserInfo>> getUsers() async {
    try {
      final Response response = await httpClient.get('users/'); // Giả định API endpoint là 'users/'
      
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => UserInfo.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get users: ${e.message}');
    }
  }

  Future<LocationResponse> getLocation() async {
    try {
      Response resp = await httpClient.get(
        'users/1/locations/',
      );

      if (resp.statusCode == 200) {
        return LocationResponse.fromJson(resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<LocationResponse> getLocationByUser() async {
    try {
      UserModel? user = await HiveServie.getUserModel();
      Response resp = await httpClient.get(
        'users/${user?.userId}/locations/',
      
      );

      if (resp.statusCode == 200) {
        return LocationResponse.fromJson(resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
