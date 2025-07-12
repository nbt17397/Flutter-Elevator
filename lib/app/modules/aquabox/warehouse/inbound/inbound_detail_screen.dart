import 'dart:math';
import 'package:data_table_2/data_table_2.dart'; // ⬅️ import
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* ----------------- Model ----------------- */
class InboundLine {
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;
  final double weightKg;
  InboundLine(
      this.itemCode, this.itemName, this.quantity, this.unit, this.weightKg);
}

class InboundReceipt {
  final String code;
  final DateTime date;
  final String supplier;
  final List<InboundLine> lines;
  InboundReceipt(this.code, this.date, this.supplier, this.lines);

  int get itemCount => lines.length;
  double get totalKg => lines.fold(0, (s, e) => s + e.weightKg);
}

/* ----------------- Screen ----------------- */
class InboundDetailScreen extends StatelessWidget {
  InboundDetailScreen({super.key});

  final _fmt = DateFormat('dd/MM/yyyy');
  final _rng = Random();

  /* ---- tạo phiếu giả ---- */
  InboundReceipt _fakeReceipt() {
    final suppliers = ['Cargill VN', 'GreenFeed', 'Skretting', 'An Phát'];
    final items = [
      {'code': 'F001', 'name': 'Cám nổi 2mm', 'unit': 'kg'},
      {'code': 'F002', 'name': 'Cám chìm 3mm', 'unit': 'kg'},
      {'code': 'E001', 'name': 'Máy sục khí', 'unit': 'bộ'},
      {'code': 'E002', 'name': 'Bạt lót hồ', 'unit': 'cuộn'},
    ];

    final lines = List.generate(3 + _rng.nextInt(4), (_) {
      final it = items[_rng.nextInt(items.length)];
      final qty = 10 + _rng.nextInt(40);
      final w = it['unit'] == 'kg' ? qty.toDouble() : qty * 5;
      return InboundLine(
          it['code']!, it['name']!, qty.toDouble(), it['unit']!, w.toDouble());
    });

    return InboundReceipt(
      'PNK-${100 + _rng.nextInt(900)}',
      DateTime.now().subtract(Duration(days: _rng.nextInt(10))),
      suppliers[_rng.nextInt(suppliers.length)],
      lines,
    );
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _fakeReceipt();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(receipt.code),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
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
                    _info('Ngày nhập', _fmt.format(receipt.date)),
                    _info('Nhà cung cấp', receipt.supplier),
                    _info('Trạng thái', 'Hoàn thành'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /* ---- Bảng chi tiết (DataTable2) ---- */
              Expanded(
                child: DataTable2(
                  columnSpacing: 24,
                  headingRowColor:
                      WidgetStateProperty.resolveWith((_) => Colors.black),
                  headingTextStyle: const TextStyle(color: Colors.white),
                  dataRowColor:
                      WidgetStateProperty.resolveWith((_) => Colors.white),
                  showCheckboxColumn: false,
                  columns: const [
                    DataColumn2(label: Text('Mã'), size: ColumnSize.S),
                    DataColumn2(
                        label: Text('Tên vật phẩm'), size: ColumnSize.L),
                    DataColumn2(
                        label: Text('SL'), numeric: true, size: ColumnSize.S),
                    DataColumn2(label: Text('Đơn vị'), size: ColumnSize.S),
                  ],
                  rows: receipt.lines
                      .map(
                        (l) => DataRow(cells: [
                          DataCell(Text(l.itemCode)),
                          DataCell(Text(l.itemName)),
                          DataCell(Text(l.quantity.toStringAsFixed(0))),
                          DataCell(Text(l.unit)),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
