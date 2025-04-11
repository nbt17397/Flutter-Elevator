import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/tag_response.dart';

import '../base_client.dart';

class TagRepo extends ApiProvider {
  Future<TagResponse> getTags(
  ) async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/tags/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (_resp.statusCode == 200) {
        return TagResponse.fromJson(_resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
