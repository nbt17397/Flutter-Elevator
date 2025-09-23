import 'package:json_annotation/json_annotation.dart';

part 'stock_transaction_detail_db.g.dart';

@JsonSerializable()
class StockTransactionDetailDB {
  final int id;

  @JsonKey(name: 'product_name')
  final String productName;

  @JsonKey(fromJson: double.parse, toJson: _doubleToString)
  final double quantity;

  @JsonKey(name: 'unit_price', fromJson: double.parse, toJson: _doubleToString)
  final double unitPrice;

  @JsonKey(name: 'total_price', fromJson: double.parse, toJson: _doubleToString)
  final double totalPrice;

  final String? note;

  @JsonKey(name: 'stock_transaction')
  final int stockTransaction;

  final int product;

  StockTransactionDetailDB({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.note,
    required this.stockTransaction,
    required this.product,
  });

  factory StockTransactionDetailDB.fromJson(Map<String, dynamic> json) =>
      _$StockTransactionDetailDBFromJson(json);

  Map<String, dynamic> toJson() => _$StockTransactionDetailDBToJson(this);

  static double _doubleParse(dynamic value) {
    if (value is String) {
      return double.parse(value);
    }
    return (value as num).toDouble();
  }

  static String _doubleToString(double value) => value.toString();
}