// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDB _$ProductDBFromJson(Map<String, dynamic> json) => ProductDB(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      type: json['type'] as String,
      unit: (json['unit'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String),
      location: (json['location'] as num).toInt(),
    );

Map<String, dynamic> _$ProductDBToJson(ProductDB instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'type': instance.type,
      'unit': instance.unit,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
