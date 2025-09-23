import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/warehouse/inbound/inbound_detail_screen.dart';
import 'package:elevator/app/services/reporitories/stock_transaction_repo.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/json_annotation/stock_transaction_db.dart';
import '../../../../services/reporitories/stock_transaction_detail_repo.dart';
import '../bloc/stock_transaction_bloc.dart';

/// ----------------- DataTableSource -----------------
class _ReceiptSource extends DataTableSource {
  final List<StockTransactionDB> data;
  final DateFormat fmt = DateFormat('dd/MM/yyyy');
  final BuildContext ctx;

  _ReceiptSource(this.data, this.ctx);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final r = data[index];
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) {
        Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => InboundDetailScreen(transactionId: r.id),
          ),
        );
      },
      cells: [
        DataCell(Center(child: Text(r.code,maxLines: 2))),
        DataCell(Center(child: Text(fmt.format(r.createdAt)))),
        DataCell(Center(child: Text(r.note ?? ''))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

/// ----------------- Screen -----------------
class InboundScreen extends StatefulWidget {
  const InboundScreen({super.key});

  @override
  State<InboundScreen> createState() => _InboundScreenState();
}

class _InboundScreenState extends State<InboundScreen> {
  late final StockTransactionBloc _bloc;
  _ReceiptSource? _source;

  @override
  void initState() {
    super.initState();
    _bloc = StockTransactionBloc(StockTransactionRepo(),StockTransactionDetailRepo());
    _bloc.add(LoadStockTransactions());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  static void _showAddTransactionDialog(BuildContext context, StockTransactionBloc bloc) {
    final codeCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: 'THÊM PHIẾU',
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: codeCtrl,
              validator: (v) => v?.isEmpty ?? true ? 'Không được để trống' : null,
              decoration: const InputDecoration(labelText: 'Mã phiếu', isDense: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: noteCtrl,
              decoration: const InputDecoration(labelText: 'Ghi chú', isDense: true),
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.blue,
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              final newTransaction = StockTransactionDB(
                id: 0,
                code: codeCtrl.text,
                type: 'import',
                note: noteCtrl.text.isNotEmpty ? noteCtrl.text : null,
                createdAt: DateTime.now(),
                location: 1,
              );
              bloc.add(AddStockTransaction(newTransaction));
              Navigator.pop(context);
            }
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Phiếu nhập kho'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddTransactionDialog(context, _bloc),
              tooltip: 'Thêm phiếu nhập',
            ),
          ],
        ),
        body: BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<StockTransactionBloc, StockTransactionState>(
            builder: (context, state) {
              if (state is StockTransactionLoading) {
                return _buildShimmerEffect();
              } else if (state is StockTransactionLoaded) {
                _source = _ReceiptSource(state.transactions, context);
                return PaginatedDataTable2(
                  columns: const [
                    DataColumn2(label: Center(child: Text('Mã phiếu')), size: ColumnSize.S),
                    DataColumn2(label: Center(child: Text('Ngày nhập')), size: ColumnSize.M),
                    DataColumn2(label: Center(child: Text('Ghi chú')), size: ColumnSize.L),
                  ],
                  source: _source!,
                  rowsPerPage: 10,
                  availableRowsPerPage: const [5, 10, 20],
                  showFirstLastButtons: true,
                  columnSpacing: 24,
                  headingRowColor: WidgetStateProperty.resolveWith((_) => Colors.black),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  showCheckboxColumn: false,
                );
              } else if (state is StockTransactionError) {
                return Center(child: Text('Lỗi: ${state.message}', style: const TextStyle(color: Colors.red)));
              }
              return const Center(child: Text('Không có dữ liệu'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(height: 50, color: Colors.white),
          const SizedBox(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (_, __) => Container(
                height: 50,
                margin: const EdgeInsets.only(bottom: 1),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}