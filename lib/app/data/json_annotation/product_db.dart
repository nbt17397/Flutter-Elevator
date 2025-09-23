// lib/data/json_annotation/product_db.dart

import 'package:json_annotation/json_annotation.dart';

part 'product_db.g.dart';

@JsonSerializable()
class ProductDB {
  final int id;
  final String name;
  final String type;
  final int unit; // Giả sử 'unit' là ID của đơn vị
  
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  
  final int location;

  ProductDB({
    required this.id,
    required this.name,
    required this.type,
    required this.unit,
    required this.createdAt,
    required this.location,
  });

  factory ProductDB.fromJson(Map<String, dynamic> json) => _$ProductDBFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDBToJson(this);
}