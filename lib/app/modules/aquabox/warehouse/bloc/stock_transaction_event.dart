part of 'stock_transaction_bloc.dart';


abstract class StockTransactionEvent {}

class LoadStockTransactions extends StockTransactionEvent {}

class AddStockTransaction extends StockTransactionEvent {
  final StockTransactionDB transaction;
  AddStockTransaction(this.transaction);
}

class UpdateStockTransaction extends StockTransactionEvent {
  final int id;
  final StockTransactionDB transaction;
  UpdateStockTransaction(this.id, this.transaction);
}

class DeleteStockTransaction extends StockTransactionEvent {
  final int id;
  DeleteStockTransaction(this.id);
}

class LoadStockTransactionById extends StockTransactionEvent {
  final int id;
  LoadStockTransactionById(this.id);
}

// Events mới cho chi tiết phiếu
class AddStockTransactionDetail extends StockTransactionEvent {
  final StockTransactionDetailDB detail;
  AddStockTransactionDetail(this.detail);
}

class UpdateStockTransactionDetail extends StockTransactionEvent {
  final int id;
  final StockTransactionDetailDB detail;
  UpdateStockTransactionDetail(this.id, this.detail);
}

class DeleteStockTransactionDetail extends StockTransactionEvent {
  final int id;
  DeleteStockTransactionDetail(this.id);
}