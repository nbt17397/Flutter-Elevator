import 'package:json_annotation/json_annotation.dart';

import 'stock_transaction_detail_db.dart';

part 'stock_transaction_db.g.dart';

@JsonSerializable()
class StockTransactionDB {
  final int id;
  final String code;
  final String type;
  final String? note;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  final int location;
  final List<StockTransactionDetailDB> details; // Tạm thời để List<dynamic> vì details là một mảng rỗng trong dữ liệu mẫu

  StockTransactionDB({
    required this.id,
    required this.code,
    required this.type,
    this.note,
    required this.createdAt,
    required this.location,
    this.details = const [],
  });

  factory StockTransactionDB.fromJson(Map<String, dynamic> json) =>
      _$StockTransactionDBFromJson(json);

  Map<String, dynamic> toJson() => _$StockTransactionDBToJson(this);
}