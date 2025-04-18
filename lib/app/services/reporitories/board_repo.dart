import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/register_response.dart';

import '../base_client.dart';

class BoardRepo extends ApiProvider {
  Future<RegisterResponse> getRegisterByBoardID({required int id}
  ) async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/boards/$id/registers/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (_resp.statusCode == 200) {
        return RegisterResponse.fromJson(_resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
