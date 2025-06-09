import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/data/response/request_control_response.dart';

import '../base_client.dart';

class BoardRepo extends ApiProvider {
  Future<RegisterResponse> getRegisterByBoardID({required int id}) async {
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

  Future<RegisterResponse> getRegisterByGroupID({required int id}) async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/groups/$id/registers/',
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

  Future<RequestControlResponse> getRequestControlByBoardID(
      {required int id}) async {
    try {
      Response _resp = await httpClient.get(
        'https://api-elevator.haophuong.com/boards/$id/control_requests/',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (_resp.statusCode == 200) {
        return RequestControlResponse.fromJson(_resp.data);
      } else {
        throw Exception('An unknown error occurred');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> requestControl({required int boardId}) async {
    try {
      final Response resp = await httpClient.post(
        'api/request-control/',
        data: {"board_id": boardId},
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        return true;
      } else {
        throw Exception(resp.data?['message'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<bool> checkRequestControl({required int boardId}) async {
    try {
      final Response resp = await httpClient.post(
        'api/check-board-control-permission/',
        data: {"board_id": boardId},
      );

      if (resp.statusCode == 200) {
        return resp.data['has_permission'];
      } else {
        throw Exception(resp.data['message'] ?? 'Lỗi không xác định');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
