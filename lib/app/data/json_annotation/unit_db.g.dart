// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitDB _$UnitDBFromJson(Map<String, dynamic> json) => UnitDB(
      id: (json['id'] as num).toInt(),
      type: json['type'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: (json['location'] as num).toInt(),
    );

Map<String, dynamic> _$UnitDBToJson(UnitDB instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
