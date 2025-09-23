// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_user_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationUserDB _$LocationUserDBFromJson(Map<String, dynamic> json) =>
    LocationUserDB(
      id: (json['id'] as num).toInt(),
      location: (json['location'] as num).toInt(),
      user: (json['user'] as num).toInt(),
      userName: json['user_name'] as String?,
      role: json['role'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );

Map<String, dynamic> _$LocationUserDBToJson(LocationUserDB instance) =>
    <String, dynamic>{
      'id': instance.id,
      'location': instance.location,
      'user': instance.user,
      'user_name': instance.userName,
      'role': instance.role,
      'joined_at': instance.joinedAt.toIso8601String(),
    };
