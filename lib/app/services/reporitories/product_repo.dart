// lib/app/services/reporitories/product_repo.dart

import 'package:dio/dio.dart';
import '../../data/json_annotation/product_db.dart';
import '../base_client.dart';

class ProductRepo extends ApiProvider {
  Future<List<ProductDB>> getProducts() async {
    try {
      final Response response = await httpClient.get('products/');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => ProductDB.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get products: ${e.message}');
    }
  }
}