import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../data/json_annotation/inventory_db.dart';
import '../../../../services/reporitories/inventory_repo.dart';
import 'bloc/inventory_bloc.dart';

/// ----------------- DataTableSource -----------------
class _StockDataSource extends DataTableSource {
  final List<InventoryDB> _items;
  final Function(InventoryDB) onRowTap;

  _StockDataSource(this._items, this.onRowTap);

  @override
  DataRow? getRow(int index) {
    if (index >= _items.length) return null;
    final i = _items[index];
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => onRowTap(i),
      cells: [
        DataCell(Text(i.product.toString())),
        DataCell(Text(i.productName)),
        DataCell(Text(i.quantity.toStringAsFixed(0))),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => _items.length;
  @override
  int get selectedRowCount => 0;
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late final InventoryBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = InventoryBloc(InventoryRepo());
    _bloc.add(LoadInventories());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  /* ---------- DIALOGS THÊM, SỬA, XOÁ ---------- */

  // Hàm hiển thị hộp thoại hành động khi chạm vào dòng
  void _showActionDialog(InventoryDB inventory) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(inventory.productName),
          contentPadding: EdgeInsets.zero,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Sửa'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showAddUpdateDialog(context, _bloc, inventory: inventory);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Xóa'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showDeleteDialog(context, _bloc, inventory.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showAddUpdateDialog(BuildContext context, InventoryBloc bloc, {InventoryDB? inventory}) {
    final productNameCtrl = TextEditingController(text: inventory?.productName ?? '');
    final quantityCtrl = TextEditingController(text: inventory?.quantity.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: inventory == null ? 'THÊM TỒN KHO' : 'SỬA TỒN KHO',
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: productNameCtrl,
              validator: (v) => v?.isEmpty ?? true ? 'Tên sản phẩm không được trống' : null,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm', isDense: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: quantityCtrl,
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true || double.tryParse(v!) == null ? 'Số lượng không hợp lệ' : null,
              decoration: const InputDecoration(labelText: 'Số lượng', isDense: true),
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
              final newInventory = InventoryDB(
                id: inventory?.id ?? 0,
                productName: productNameCtrl.text,
                quantity: double.parse(quantityCtrl.text),
                updatedAt: DateTime.now(),
                location: 1,
                product: inventory?.product ?? 0,
              );
              if (inventory == null) {
                bloc.add(AddInventory(newInventory));
              } else {
                bloc.add(UpdateInventory(newInventory));
              }
              Navigator.pop(context);
            }
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  static void _showDeleteDialog(BuildContext context, InventoryBloc bloc, int id) {
    Alert(
      context: context,
      title: 'XÁC NHẬN XOÁ',
      desc: 'Bạn có chắc chắn muốn xóa mục này?',
      buttons: [
        DialogButton(
          color: Colors.grey,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red,
          onPressed: () {
            bloc.add(DeleteInventory(id));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- BUILD UI ---------- */
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

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Tồn kho'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddUpdateDialog(context, _bloc),
              tooltip: 'Thêm tồn kho',
            ),
          ],
        ),
        body: BlocProvider.value(
          value: _bloc,
          child: BlocBuilder<InventoryBloc, InventoryState>(
            builder: (context, state) {
              if (state is InventoryLoading) {
                return _buildShimmerEffect();
              } else if (state is InventoryLoaded) {
                final _source = _StockDataSource(state.inventories, _showActionDialog);
                return PaginatedDataTable2(
                  columns: const [
                    DataColumn2(label: Text('Mã'), size: ColumnSize.S),
                    DataColumn2(label: Text('Tên vật phẩm'), size: ColumnSize.L),
                    DataColumn2(label: Text('Số lượng'), numeric: true, size: ColumnSize.S),
                  ],
                  source: _source,
                  rowsPerPage: 10,
                  availableRowsPerPage: const [5, 10, 20],
                  headingRowColor: WidgetStateProperty.resolveWith((_) => Colors.black),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  columnSpacing: 32,
                  showCheckboxColumn: false,
                  border: TableBorder.all(width: 0.3, color: Colors.grey.shade400),
                );
              } else if (state is InventoryError) {
                return Center(child: Text('Lỗi: ${state.message}'));
              }
              return const Center(child: Text('Không có dữ liệu'));
            },
          ),
        ),
      ),
    );
  }
}