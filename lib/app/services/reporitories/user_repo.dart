import 'package:dio/dio.dart';
import 'package:elevator/app/services/hive/hive_service.dart';

import '../../data/models/user_model.dart';
import '../../data/response/location_response.dart';
import '../base_client.dart';

class UserRepo extends ApiProvider {
  Future<LocationResponse> getLocation() async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/users/1/locations/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (_resp.statusCode == 200) {
        return LocationResponse.fromJson(_resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<LocationResponse> getLocationByUser() async {
    try {
      UserModel? _user = await HiveServie.getUserModel();

      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/users/${_user?.userId}/locations/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (_resp.statusCode == 200) {
        return LocationResponse.fromJson(_resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
