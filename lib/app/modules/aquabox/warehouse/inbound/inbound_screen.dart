import 'package:elevator/app/modules/aquabox/warehouse/inbound/inbound_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ----------------- Model -----------------
class InboundReceipt {
  final String code; // Mã phiếu
  final DateTime date; // Ngày nhập
  final String supplier; // Nhà cung cấp
  final int itemCount; // Số dòng vật phẩm
  final double totalWeight; // Tổng khối lượng (kg)

  InboundReceipt(
      this.code, this.date, this.supplier, this.itemCount, this.totalWeight);
}

/// ----------------- Screen -----------------
class InboundScreen extends StatelessWidget {
  InboundScreen({super.key});

  /* ---- Fake data ---- */
  final List<InboundReceipt> _receipts = [
    InboundReceipt('PNK-001', DateTime(2025, 5, 16), 'Cargill VN', 3, 750),
    InboundReceipt('PNK-002', DateTime(2025, 5, 18), 'Skretting', 2, 500),
    InboundReceipt(
        'PNK-003', DateTime(2025, 5, 21), 'Thiết bị An Phát', 4, 120),
    InboundReceipt(
        'PNK-004', DateTime(2025, 6, 2), 'Thức ăn GreenFeed', 1, 350),
    // ➜ thêm nhiều dòng để test cuộn dọc
    ...List.generate(
      25,
      (i) => InboundReceipt(
        'PNK-${100 + i}',
        DateTime(2025, 6, 5 + i),
        'Nhà cung cấp $i',
        1 + (i % 5),
        100 + i * 10,
      ),
    ),
  ];

  final _fmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu nhập kho'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // cuộn ngang
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical, // cuộn dọc
              child: DataTable(
                headingRowColor:
                    MaterialStateProperty.resolveWith((_) => Colors.black),
                dataRowColor: MaterialStateProperty.resolveWith(
                    (_) => Colors.grey.shade300),
                columnSpacing: 32,
                columns: const [
                  DataColumn(
                      label: Text('Mã phiếu',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Ngày nhập',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      label: Text('Nhà cung cấp',
                          style: TextStyle(color: Colors.white))),
                  DataColumn(
                      numeric: true,
                      label:
                          Text('Mục', style: TextStyle(color: Colors.white))),
                  DataColumn(
                      numeric: true,
                      label: Text('Khối lượng (kg)',
                          style: TextStyle(color: Colors.white))),
                ],
                rows: _receipts
                    .map((r) => DataRow(
                            selected: false,
                            onSelectChanged: (_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InboundDetailScreen(),
                                ),
                              );
                            },
                            cells: [
                              DataCell(Text(r.code)),
                              DataCell(Text(_fmt.format(r.date))),
                              DataCell(Text(r.supplier)),
                              DataCell(Text(r.itemCount.toString())),
                              DataCell(Text(r.totalWeight.toStringAsFixed(0))),
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
