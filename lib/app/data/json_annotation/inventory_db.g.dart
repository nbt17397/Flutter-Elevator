// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InventoryDB _$InventoryDBFromJson(Map<String, dynamic> json) => InventoryDB(
      id: (json['id'] as num).toInt(),
      productName: json['product_name'] as String,
      quantity: double.parse(json['quantity'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      location: (json['location'] as num).toInt(),
      product: (json['product'] as num).toInt(),
    );

Map<String, dynamic> _$InventoryDBToJson(InventoryDB instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'quantity': InventoryDB._doubleToString(instance.quantity),
      'updated_at': instance.updatedAt.toIso8601String(),
      'location': instance.location,
      'product': instance.product,
    };
