import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/services/reporitories/stock_transaction_repo.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/json_annotation/product_db.dart';
import '../../../../data/json_annotation/stock_transaction_detail_db.dart';
import '../../../../services/reporitories/product_repo.dart';
import '../../../../services/reporitories/stock_transaction_detail_repo.dart';
import '../bloc/stock_transaction_bloc.dart';

class InboundDetailScreen extends StatefulWidget {
  final int transactionId;
  const InboundDetailScreen({super.key, required this.transactionId});

  @override
  State<InboundDetailScreen> createState() => _InboundDetailScreenState();
}

class _InboundDetailScreenState extends State<InboundDetailScreen> {
  late final StockTransactionBloc _bloc;
  final _fmt = DateFormat('dd/MM/yyyy');
  final ProductRepo _productRepo = ProductRepo();

  @override
  void initState() {
    super.initState();
    // Tạo một instance Bloc duy nhất và sử dụng lại
    _bloc = StockTransactionBloc(
        StockTransactionRepo(), StockTransactionDetailRepo());
    _bloc.add(LoadStockTransactionById(widget.transactionId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /* ---- helper ---- */
  Widget _info(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 130, child: Text('$k:')),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  /* ---- Dialog thêm/sửa chi tiết ---- */
  // Nhận bloc trực tiếp làm tham số
  Future<void> _showDetailDialog(StockTransactionBloc bloc,
      {StockTransactionDetailDB? detail}) async {
    final formKey = GlobalKey<FormState>();
    final quantityCtrl =
        TextEditingController(text: detail?.quantity.toString() ?? '');
    final noteCtrl = TextEditingController(text: detail?.note ?? '');
    ProductDB? selectedProduct;
    final int transactionId =
        widget.transactionId; // Lấy transactionId từ widget
    final Future<List<ProductDB>> productsFuture = _productRepo.getProducts();

    Alert(
      context: context,
      title: detail == null ? 'THÊM VẬT PHẨM' : 'SỬA VẬT PHẨM',
      content: Form(
        key: formKey,
        child: Column(
          children: [
            // Thêm dropdown cho Product và Unit ở đây
            if (detail == null)
              FutureBuilder<List<ProductDB>>(
                future: productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text('Không thể tải sản phẩm',
                        style: TextStyle(color: Colors.red));
                  }
                  final products = snapshot.data!;
                  return DropdownButtonFormField<ProductDB>(
                    decoration: const InputDecoration(
                        labelText: 'Sản phẩm',
                        border: OutlineInputBorder(),
                        isDense: true),
                    items: products
                        .map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product.name),
                            ))
                        .toList(),
                    onChanged: (value) => selectedProduct = value,
                    validator: (v) => v == null ? 'Không được để trống' : null,
                  );
                },
              ),
            if (detail == null) const SizedBox(height: 12),
            TextFormField(
              controller: quantityCtrl,
              decoration: const InputDecoration(labelText: 'Số lượng'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v?.isEmpty ?? true ? 'Không được để trống' : null,
            ),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú'),
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
            child: const Text('Huỷ'), onPressed: () => Navigator.pop(context)),
        DialogButton(
          child: const Text('Lưu'),
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              final newDetail = StockTransactionDetailDB(
                id: detail?.id ?? 0,
                // Lấy thông tin từ dropdown hoặc từ detail cũ
                productName: selectedProduct?.name ?? detail!.productName,
                product: selectedProduct?.id ?? detail!.product,
                quantity: double.tryParse(quantityCtrl.text) ?? 0,
                unitPrice: 0, // Cần lấy từ API hoặc gán cứng nếu cần
                totalPrice: 0, // Tính toán hoặc gán cứng
                note: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                stockTransaction: transactionId,
              );
              if (detail == null) {
                bloc.add(AddStockTransactionDetail(newDetail));
              } else {
                bloc.add(UpdateStockTransactionDetail(newDetail.id, newDetail));
              }
              Navigator.pop(context);
            }
          },
        ),
      ],
    ).show();
  }

  /* ---- Xác nhận xóa chi tiết ---- */
  // Nhận bloc trực tiếp làm tham số
  void _confirmDelete(
      StockTransactionBloc bloc, StockTransactionDetailDB detail) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XÓA VẬT PHẨM',
      desc: 'Bạn có chắc muốn xóa vật phẩm "${detail.productName}"?',
      buttons: [
        DialogButton(
            child: const Text('Huỷ'), onPressed: () => Navigator.pop(context)),
        DialogButton(
          child: const Text('Xóa'),
          onPressed: () {
            bloc.add(DeleteStockTransactionDetail(detail.id));
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  /* ---- Xác nhận xóa phiếu nhập ---- */
  void _confirmDeleteTransaction() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XÓA PHIẾU NHẬP',
      desc:
          'Bạn có chắc chắn muốn xóa toàn bộ phiếu nhập này?',
      buttons: [
        DialogButton(
            child: const Text('Huỷ'), onPressed: () => Navigator.pop(context)),
        DialogButton(
          color: Colors.red,
          onPressed: () {
            _bloc.add(DeleteStockTransaction(widget.transactionId));
            Navigator.pop(context);
            Navigator.pop(context); // Quay lại màn hình danh sách phiếu
          },
          child: const Text('Xóa'),
        ),
      ],
    ).show();
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => Container(
                height: 50,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Chi tiết phiếu'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            // Nút "Xóa phiếu"
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDeleteTransaction,
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showDetailDialog(_bloc),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocProvider.value(
            value: _bloc,
            child: BlocBuilder<StockTransactionBloc, StockTransactionState>(
              builder: (context, state) {
                if (state is StockTransactionDetailLoading) {
                  return _buildShimmerEffect();
                } else if (state is StockTransactionDetailLoaded) {
                  final receipt = state.transaction;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* ---- Thông tin chung ---- */
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _info('Mã phiếu', receipt.code),
                            _info('Ngày nhập', _fmt.format(receipt.createdAt)),
                            _info('Ghi chú', receipt.note ?? ''),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      /* ---- Bảng chi tiết (DataTable2) ---- */
                      Expanded(
                        child: DataTable2(
                          columnSpacing: 24,
                          headingRowColor: WidgetStateProperty.resolveWith(
                              (_) => Colors.black),
                          headingTextStyle:
                              const TextStyle(color: Colors.white),
                          dataRowColor: WidgetStateProperty.resolveWith(
                              (_) => Colors.white),
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn2(label: Text('Mã'), size: ColumnSize.S),
                            DataColumn2(
                                label: Text('Tên vật phẩm'),
                                size: ColumnSize.L),
                            DataColumn2(
                                label: Text('SL'),
                                numeric: true,
                                size: ColumnSize.S),
                            DataColumn2(
                                label: Text('Đơn vị'), size: ColumnSize.S),
                            DataColumn2(label: Text(''), size: ColumnSize.S),
                          ],
                          rows: receipt.details
                              .map(
                                (l) => DataRow(cells: [
                                  DataCell(Text(l.product.toString())),
                                  DataCell(Text(l.productName)),
                                  DataCell(Text(l.quantity.toStringAsFixed(0))),
                                  DataCell(Text('kg')), // Tạm thời
                                  DataCell(
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showDetailDialog(_bloc, detail: l);
                                        } else if (value == 'delete') {
                                          _confirmDelete(_bloc, l);
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                            value: 'edit', child: Text('Sửa')),
                                        PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Xóa')),
                                      ],
                                      icon: const Icon(Icons.more_vert),
                                    ),
                                  ),
                                ]),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  );
                } else if (state is StockTransactionError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ),
      ),
    );
  }
}
