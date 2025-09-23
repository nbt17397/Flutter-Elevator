// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pond_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PondDB _$PondDBFromJson(Map<String, dynamic> json) => PondDB(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      volume: (json['volume'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      system: (json['system'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PondDBToJson(PondDB instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'volume': instance.volume,
      'created_at': instance.createdAt.toIso8601String(),
      if (instance.system case final value?) 'system': value,
    };
