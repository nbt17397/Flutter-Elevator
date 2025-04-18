import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';

import '../base_client.dart';

class HistoricalDataRepo extends ApiProvider {
  Future<List<HistoricalData>> getHistoricalDataByRegisterID(
      {required int id}) async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/registers/$id/historical-data/all/',
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (_resp.statusCode == 200) {
        return (_resp.data as List)
            .map((e) => HistoricalData.fromJson(e))
            .toList();
      } else {
        throw Exception('Lỗi không xác định');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
