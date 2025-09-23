// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockTransactionDB _$StockTransactionDBFromJson(Map<String, dynamic> json) =>
    StockTransactionDB(
      id: (json['id'] as num).toInt(),
      code: json['code'] as String,
      type: json['type'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      location: (json['location'] as num).toInt(),
      details: (json['details'] as List<dynamic>?)
              ?.map((e) =>
                  StockTransactionDetailDB.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$StockTransactionDBToJson(StockTransactionDB instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'type': instance.type,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
      'location': instance.location,
      'details': instance.details,
    };
