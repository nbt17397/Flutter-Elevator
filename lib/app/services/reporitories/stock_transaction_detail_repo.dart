// lib/app/services/reporitories/stock_transaction_detail_repo.dart

import 'package:dio/dio.dart';
import '../../data/json_annotation/stock_transaction_detail_db.dart';
import '../base_client.dart';

class StockTransactionDetailRepo extends ApiProvider {
  // Phương thức: Thêm chi tiết
  Future<StockTransactionDetailDB> createDetail(StockTransactionDetailDB detail) async {
    try {
      final Response response = await httpClient.post(
        'stock-transaction-details/',
        data: detail.toJson(),
      );
      if (response.statusCode == 201) {
        return StockTransactionDetailDB.fromJson(response.data);
      } else {
        throw Exception('Failed to create detail. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create detail: ${e.message}');
    }
  }

  // Phương thức: Cập nhật chi tiết
  Future<StockTransactionDetailDB> updateDetail(int id, StockTransactionDetailDB detail) async {
    try {
      final Response response = await httpClient.put(
        'stock-transaction-details/$id/',
        data: detail.toJson(),
      );
      if (response.statusCode == 200) {
        return StockTransactionDetailDB.fromJson(response.data);
      } else {
        throw Exception('Failed to update detail. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update detail: ${e.message}');
    }
  }

  // Phương thức: Xóa chi tiết
  Future<void> deleteDetail(int id) async {
    try {
      final Response response = await httpClient.delete('stock-transaction-details/$id/');
      if (response.statusCode != 204) {
        throw Exception('Failed to delete detail. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete detail: ${e.message}');
    }
  }
}