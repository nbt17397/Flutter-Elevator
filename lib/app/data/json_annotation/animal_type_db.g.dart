// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_type_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnimalTypeDB _$AnimalTypeDBFromJson(Map<String, dynamic> json) => AnimalTypeDB(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: (json['location'] as num).toInt(),
    );

Map<String, dynamic> _$AnimalTypeDBToJson(AnimalTypeDB instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
    };
