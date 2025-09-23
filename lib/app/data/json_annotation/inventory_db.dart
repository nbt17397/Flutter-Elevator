import 'package:json_annotation/json_annotation.dart';

part 'inventory_db.g.dart';

@JsonSerializable()
class InventoryDB {
  final int id;

  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(fromJson: double.parse, toJson: _doubleToString)
  final double quantity;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  final int location;
  final int product;

  InventoryDB({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.updatedAt,
    required this.location,
    required this.product,
  });

  factory InventoryDB.fromJson(Map<String, dynamic> json) =>
      _$InventoryDBFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryDBToJson(this);

  static String _doubleToString(double value) => value.toString();
}