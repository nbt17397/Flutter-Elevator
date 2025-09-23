part of 'stock_transaction_bloc.dart';


abstract class StockTransactionState {}

class StockTransactionInitial extends StockTransactionState {}

class StockTransactionLoading extends StockTransactionState {}

class StockTransactionLoaded extends StockTransactionState {
  final List<StockTransactionDB> transactions;
  StockTransactionLoaded(this.transactions);
}

class StockTransactionError extends StockTransactionState {
  final String message;
  StockTransactionError(this.message);
}

class StockTransactionDetailLoading extends StockTransactionState {}

class StockTransactionDetailLoaded extends StockTransactionState {
  final StockTransactionDB transaction;
  StockTransactionDetailLoaded(this.transaction);
}