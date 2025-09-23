import 'package:dio/dio.dart';
import '../../data/json_annotation/inventory_db.dart';
import '../base_client.dart';

class InventoryRepo extends ApiProvider {
  // Phương thức: Get (Lấy danh sách tồn kho)
  Future<List<InventoryDB>> getInventories() async {
    try {
      final Response response = await httpClient.get('inventories/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => InventoryDB.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load inventories. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get inventories: ${e.message}');
    }
  }

  // Phương thức: Create (Thêm tồn kho mới)
  Future<InventoryDB> createInventory(InventoryDB inventory) async {
    try {
      final Response response = await httpClient.post(
        'inventories/',
        data: inventory.toJson(),
      );
      if (response.statusCode == 201) {
        return InventoryDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to create inventory. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to create inventory: ${e.message}');
    }
  }

  // Phương thức: Update (Cập nhật tồn kho)
  Future<InventoryDB> updateInventory(int id, InventoryDB inventory) async {
    try {
      final Response response = await httpClient.put(
        'inventories/$id/',
        data: inventory.toJson(),
      );
      if (response.statusCode == 200) {
        return InventoryDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update inventory. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to update inventory: ${e.message}');
    }
  }

  // Phương thức: Delete (Xóa tồn kho)
  Future<void> deleteInventory(int id) async {
    try {
      final Response response = await httpClient.delete('inventories/$id/');
      if (response.statusCode != 204) {
        throw Exception(
            'Failed to delete inventory. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to delete inventory: ${e.message}');
    }
  }
}