// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SystemDB _$SystemDBFromJson(Map<String, dynamic> json) => SystemDB(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: (json['location'] as num).toInt(),
    );

Map<String, dynamic> _$SystemDBToJson(SystemDB instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
