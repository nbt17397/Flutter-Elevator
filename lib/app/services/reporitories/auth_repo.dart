import 'package:dio/dio.dart';

import '../../data/response/login_response.dart';
import '../base_client.dart';

class LoginRepo extends ApiProvider {
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      Response _resp = await httpClient.post(
        'api/login/',
        data: {"username": username, "password": password},
        options: Options(
          headers: {'Authorization': ''},
        ),
      );

      if (_resp.statusCode == 200) {
        return LoginResponse.fromJson(_resp.data);
      } else if (_resp.data['non_field_errors'] != null) {
        throw Exception(_resp.data['non_field_errors'][0]);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      // Thêm xử lý lỗi chung
      throw Exception(e.toString());
    }
  }
}
