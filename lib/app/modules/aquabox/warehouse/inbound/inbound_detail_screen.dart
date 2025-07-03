import 'dart:math';
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

  int    get itemCount => lines.length;
  double get totalKg   => lines.fold(0, (s, e) => s + e.weightKg);
}

/* ----------------- Screen ----------------- */
class InboundDetailScreen extends StatelessWidget {
  InboundDetailScreen({super.key});

  final _fmt = DateFormat('dd/MM/yyyy');
  final _rng = Random();

  /* ---- sinh 1 phiếu nhập giả ---- */
  InboundReceipt _fakeReceipt() {
    final suppliers = ['Cargill VN', 'GreenFeed', 'Skretting', 'An Phát'];
    final items = [
      {'code': 'F001', 'name': 'Cám nổi 2mm', 'unit': 'kg'},
      {'code': 'F002', 'name': 'Cám chìm 3mm', 'unit': 'kg'},
      {'code': 'E001', 'name': 'Máy sục khí', 'unit': 'bộ'},
      {'code': 'E002', 'name': 'Bạt lót hồ', 'unit': 'cuộn'},
    ];

    // tạo 3–6 dòng vật phẩm
    final lines = List.generate(3 + _rng.nextInt(4), (i) {
      final itm = items[_rng.nextInt(items.length)];
      final qty = 10 + _rng.nextInt(40);         // 10–50
      final w   = itm['unit']=='kg' ? qty.toDouble() : qty * 5;
      return InboundLine(itm['code']!, itm['name']!, qty.toDouble(),
          itm['unit']!, w.toDouble());
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
    final receipt = _fakeReceipt();            // 👉 sinh dữ liệu tại đây

    return Scaffold(
      appBar: AppBar(
        title: Text('Phiếu nhập: ${receipt.code}'),
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
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _info('Mã phiếu', receipt.code),
                  _info('Ngày nhập', _fmt.format(receipt.date)),
                  _info('Nhà cung cấp', receipt.supplier),
                  const SizedBox(height: 4),
                  _info('Số mục', receipt.itemCount.toString()),
                  _info('Tổng khối lượng', '${receipt.totalKg.toStringAsFixed(0)} kg'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            /* ---- Bảng chi tiết ---- */
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith(
                        (_) => Colors.black),
                    dataRowColor: MaterialStateProperty.resolveWith(
                        (_) => Colors.grey.shade300),
                    columnSpacing: 28,
                    columns: const [
                      DataColumn(label: Text('Mã', style: _headStyle)),
                      DataColumn(label: Text('Tên vật phẩm', style: _headStyle)),
                      DataColumn(label: Text('SL', style: _headStyle), numeric: true),
                      DataColumn(label: Text('Đơn vị', style: _headStyle)),
                      DataColumn(label: Text('Khối lượng (kg)', style: _headStyle), numeric: true),
                    ],
                    rows: receipt.lines.map((l) => DataRow(cells: [
                      DataCell(Text(l.itemCode)),
                      DataCell(Text(l.itemName)),
                      DataCell(Text(l.quantity.toStringAsFixed(0))),
                      DataCell(Text(l.unit)),
                      DataCell(Text(l.weightKg.toStringAsFixed(0))),
                    ])).toList(),
                    showCheckboxColumn: false,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---- helper info line ---- */
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

const _headStyle = TextStyle(color: Colors.white);
