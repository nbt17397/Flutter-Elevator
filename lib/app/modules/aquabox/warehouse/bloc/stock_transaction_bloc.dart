import 'package:bloc/bloc.dart';

import '../../../../data/json_annotation/stock_transaction_db.dart';
import '../../../../data/json_annotation/stock_transaction_detail_db.dart';
import '../../../../services/reporitories/stock_transaction_detail_repo.dart';
import '../../../../services/reporitories/stock_transaction_repo.dart';

part 'stock_transaction_event.dart';
part 'stock_transaction_state.dart';

class StockTransactionBloc
    extends Bloc<StockTransactionEvent, StockTransactionState> {
  final StockTransactionRepo transactionRepo;
  final StockTransactionDetailRepo detailRepo;

  StockTransactionBloc(this.transactionRepo,this.detailRepo)
      : super(StockTransactionInitial()) {
    on<LoadStockTransactions>(_onLoadStockTransactions);
    on<LoadStockTransactionById>(_onLoadStockTransactionById);
    on<AddStockTransaction>(_onAddStockTransaction);
    on<UpdateStockTransaction>(_onUpdateStockTransaction);
    on<DeleteStockTransaction>(_onDeleteStockTransaction);
    on<AddStockTransactionDetail>(_onAddDetail);
    on<UpdateStockTransactionDetail>(_onUpdateDetail);
    on<DeleteStockTransactionDetail>(_onDeleteDetail);
  }

  Future<void> _onLoadStockTransactions(
      LoadStockTransactions event, Emitter<StockTransactionState> emit) async {
    try {
      emit(StockTransactionLoading());
      final transactions = await transactionRepo.getStockTransactions();
      emit(StockTransactionLoaded(transactions));
    } catch (e) {
      emit(StockTransactionError('Failed to load transactions: $e'));
    }
  }

  Future<void> _onLoadStockTransactionById(LoadStockTransactionById event, Emitter<StockTransactionState> emit) async {
    try {
      emit(StockTransactionDetailLoading());
      final transaction = await transactionRepo.getStockTransactionById(event.id);
      emit(StockTransactionDetailLoaded(transaction));
    } catch (e) {
      emit(StockTransactionError('Failed to load transaction detail: $e'));
    }
  }

  Future<void> _onAddStockTransaction(
      AddStockTransaction event, Emitter<StockTransactionState> emit) async {
    try {
      await transactionRepo.createStockTransaction(event.transaction);
      add(LoadStockTransactions());
    } catch (e) {
      emit(StockTransactionError('Failed to add transaction: $e'));
      // Có thể giữ lại trạng thái cũ để không mất dữ liệu
      if (state is StockTransactionLoaded) {
        emit(StockTransactionLoaded(
            (state as StockTransactionLoaded).transactions));
      }
    }
  }

  Future<void> _onUpdateStockTransaction(
      UpdateStockTransaction event, Emitter<StockTransactionState> emit) async {
    try {
      await transactionRepo.updateStockTransaction(event.id, event.transaction);
      add(LoadStockTransactions());
    } catch (e) {
      emit(StockTransactionError('Failed to update transaction: $e'));
      if (state is StockTransactionLoaded) {
        emit(StockTransactionLoaded(
            (state as StockTransactionLoaded).transactions));
      }
    }
  }

  Future<void> _onDeleteStockTransaction(
      DeleteStockTransaction event, Emitter<StockTransactionState> emit) async {
    try {
      await transactionRepo.deleteStockTransaction(event.id);
      add(LoadStockTransactions());
    } catch (e) {
      emit(StockTransactionError('Failed to delete transaction: $e'));
      if (state is StockTransactionLoaded) {
        emit(StockTransactionLoaded(
            (state as StockTransactionLoaded).transactions));
      }
    }
  }

  // Hàm xử lý mới: Thêm chi tiết
  Future<void> _onAddDetail(AddStockTransactionDetail event, Emitter<StockTransactionState> emit) async {
    if (state is! StockTransactionDetailLoaded) return;
    final currentTransactionId = (state as StockTransactionDetailLoaded).transaction.id;
    
    try {
      emit(StockTransactionDetailLoading());
      await detailRepo.createDetail(event.detail);
      // Tải lại chi tiết phiếu sau khi thêm thành công
      add(LoadStockTransactionById(currentTransactionId));
    } catch (e) {
      emit(StockTransactionError('Failed to add detail: $e'));
      // Giữ lại trạng thái cũ
      emit(StockTransactionDetailLoaded((state as StockTransactionDetailLoaded).transaction));
    }
  }

  // Hàm xử lý mới: Sửa chi tiết
  Future<void> _onUpdateDetail(UpdateStockTransactionDetail event, Emitter<StockTransactionState> emit) async {
    if (state is! StockTransactionDetailLoaded) return;
    final currentTransactionId = (state as StockTransactionDetailLoaded).transaction.id;

    try {
      emit(StockTransactionDetailLoading());
      await detailRepo.updateDetail(event.id, event.detail);
      // Tải lại chi tiết phiếu sau khi sửa thành công
      add(LoadStockTransactionById(currentTransactionId));
    } catch (e) {
      emit(StockTransactionError('Failed to update detail: $e'));
      emit(StockTransactionDetailLoaded((state as StockTransactionDetailLoaded).transaction));
    }
  }

  // Hàm xử lý mới: Xóa chi tiết
  Future<void> _onDeleteDetail(DeleteStockTransactionDetail event, Emitter<StockTransactionState> emit) async {
    if (state is! StockTransactionDetailLoaded) return;
    final currentTransactionId = (state as StockTransactionDetailLoaded).transaction.id;

    try {
      emit(StockTransactionDetailLoading());
      await detailRepo.deleteDetail(event.id);
      // Tải lại chi tiết phiếu sau khi xóa thành công
      add(LoadStockTransactionById(currentTransactionId));
    } catch (e) {
      emit(StockTransactionError('Failed to delete detail: $e'));
      emit(StockTransactionDetailLoaded((state as StockTransactionDetailLoaded).transaction));
    }
  }
}
