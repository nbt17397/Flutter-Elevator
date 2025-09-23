// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_transaction_detail_db.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockTransactionDetailDB _$StockTransactionDetailDBFromJson(
        Map<String, dynamic> json) =>
    StockTransactionDetailDB(
      id: (json['id'] as num).toInt(),
      productName: json['product_name'] as String,
      quantity: double.parse(json['quantity'] as String),
      unitPrice: double.parse(json['unit_price'] as String),
      totalPrice: double.parse(json['total_price'] as String),
      note: json['note'] as String?,
      stockTransaction: (json['stock_transaction'] as num).toInt(),
      product: (json['product'] as num).toInt(),
    );

Map<String, dynamic> _$StockTransactionDetailDBToJson(
        StockTransactionDetailDB instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_name': instance.productName,
      'quantity': StockTransactionDetailDB._doubleToString(instance.quantity),
      'unit_price':
          StockTransactionDetailDB._doubleToString(instance.unitPrice),
      'total_price':
          StockTransactionDetailDB._doubleToString(instance.totalPrice),
      'note': instance.note,
      'stock_transaction': instance.stockTransaction,
      'product': instance.product,
    };
