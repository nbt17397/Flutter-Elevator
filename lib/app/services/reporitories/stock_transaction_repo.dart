import 'package:dio/dio.dart';
import '../../data/json_annotation/stock_transaction_db.dart';
import '../base_client.dart';

class StockTransactionRepo extends ApiProvider {
  // Phương thức: Get (Lấy danh sách)
  Future<List<StockTransactionDB>> getStockTransactions() async {
    try {
      final Response response = await httpClient.get('stock-transactions/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results
            .map((json) => StockTransactionDB.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load stock transactions. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get stock transactions: ${e.message}');
    }
  }

  // Phương thức: Get Detail by ID (Lấy chi tiết)
  Future<StockTransactionDB> getStockTransactionById(int id) async {
    try {
      final Response response = await httpClient.get('stock-transactions/$id/');
      if (response.statusCode == 200) {
        return StockTransactionDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to get transaction detail. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get transaction detail: ${e.message}');
    }
  }

  // Phương thức: Create (Tạo mới)
  Future<StockTransactionDB> createStockTransaction(
      StockTransactionDB transaction) async {
    try {
      final Response response = await httpClient.post(
        'stock-transactions/',
        data: transaction.toJson(),
      );
      if (response.statusCode == 201) {
        return StockTransactionDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create stock transaction. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create stock transaction: ${e.message}');
    }
  }

  // Phương thức: Update (Cập nhật)
  Future<StockTransactionDB> updateStockTransaction(
      int id, StockTransactionDB transaction) async {
    try {
      final Response response = await httpClient.put(
        'stock-transactions/$id/',
        data: transaction.toJson(),
      );
      if (response.statusCode == 200) {
        return StockTransactionDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update stock transaction. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update stock transaction: ${e.message}');
    }
  }

  // Phương thức: Delete (Xóa)
  Future<void> deleteStockTransaction(int id) async {
    try {
      final Response response = await httpClient.delete('stock-transactions/$id/');
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete stock transaction. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete stock transaction: ${e.message}');
    }
  }
}