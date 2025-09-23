import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';

import '../base_client.dart';

class HistoricalDataRepo extends ApiProvider {
  Future<List<HistoricalData>> getHistoricalDataByRegisterID(
      {required int id}) async {
    try {
      Response _resp = await httpClient.get(
        'registers/$id/historical-data/all/',
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
