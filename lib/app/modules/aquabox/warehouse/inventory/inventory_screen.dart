import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class StockItem {
  final String code;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  StockItem(this.code, this.name, this.category, this.quantity, this.unit);
}

class InventoryScreen extends StatelessWidget {
  InventoryScreen({super.key});

  final List<StockItem> _items = [
    StockItem('F001', 'Cám nổi 3mm', 'Thức ăn', 820, 'kg'),
    StockItem('F002', 'Cám chìm 2mm', 'Thức ăn', 650, 'kg'),
    StockItem('F003', 'Grower 45%',   'Thức ăn', 300, 'kg'),
    StockItem('E001', 'Máy sục khí',  'Thiết bị', 5,   'bộ'),
    StockItem('E002', 'Máy cho ăn tự động', 'Thiết bị', 2, 'bộ'),
    StockItem('E003', 'Máy bơm nước', 'Thiết bị', 3,   'bộ'),
    ...List.generate(
        20,
        (i) => StockItem(
            'F10$i', 'Thức ăn bổ sung $i', 'Thức ăn', 100 + i * 5, 'kg')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tồn kho'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,            // ⬅️ cuộn dọc
              child: DataTable(
                headingRowColor: MaterialStateProperty.resolveWith(
                    (_) => Colors.black),
                dataRowColor: MaterialStateProperty.resolveWith(
                    (_) => Colors.grey.shade300),
                columnSpacing: 32,
                columns: const [
                  DataColumn(
                      label: Text('Mã',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Tên vật phẩm',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Loại',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      numeric: true,
                      label: Text('Số lượng',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Đơn vị',
                          style: TextStyle(color: Colors.white))),
                ],
                rows: _items
                    .map((i) => DataRow(cells: [
                          DataCell(Text(i.code)),
                          DataCell(Text(i.name)),
                          DataCell(Text(i.category)),
                          DataCell(Text(i.quantity.toStringAsFixed(0))),
                          DataCell(Text(i.unit)),
                        ]))
                    .toList(),
                showCheckboxColumn: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
