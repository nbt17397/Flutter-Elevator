import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class StockItem {
  final String code;
  final String name;
  final double quantity;
  StockItem(this.code, this.name, this.quantity);
}

/// DataTableSource giúp PaginatedDataTable2 tự động sinh trang
class _StockDataSource extends DataTableSource {
  final List<StockItem> _items;
  _StockDataSource(this._items);

  @override
  DataRow? getRow(int index) {
    if (index >= _items.length) return null;
    final i = _items[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(i.code)),
        DataCell(Text(i.name)),
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
  late final _StockDataSource _source;

  @override
  void initState() {
    super.initState();

    final items = [
      StockItem('F001', 'Cám nổi 3mm', 820),
      StockItem('F002', 'Cám chìm 2mm', 650),
      StockItem('F003', 'Grower 45%', 300),
      StockItem('E001', 'Máy sục khí', 5),
      StockItem('E002', 'Máy cho ăn tự động', 2),
      StockItem('E003', 'Máy bơm nước', 3),
      ...List.generate(
        20,
        (i) => StockItem('F10$i', 'Thức ăn bổ sung $i', 100 + i * 5),
      ),
    ];

    _source = _StockDataSource(items);
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
        ),
        body: PaginatedDataTable2(
          columns: const [
            DataColumn2(label: Text('Mã'), size: ColumnSize.S),
            DataColumn2(label: Text('Tên vật phẩm'), size: ColumnSize.L),
            DataColumn2(
                label: Text('Số lượng'), numeric: true, size: ColumnSize.S),
          ],
          source: _source,
          rowsPerPage: 10, // mặc định mỗi trang 8 dòng
          availableRowsPerPage: const [5, 10, 10, 20], // tuỳ chọn cho dropdown
          headingRowColor: WidgetStateProperty.resolveWith(
              (_) => Colors.black), // màu tiêu đề
          headingTextStyle: TextStyle(color: Colors.white),
          columnSpacing: 32,
          showCheckboxColumn: false,
          border: TableBorder.all(width: 0.3, color: Colors.grey.shade400),
        ),
      ),
    );
  }
}
