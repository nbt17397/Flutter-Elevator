import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'outbound_screen.dart';   // để lấy OutboundReceipt

/* ---------- Line model ---------- */
class OutboundLine {
  final String itemCode;
  final String itemName;
  final double quantity;
  final String unit;
  final double weightKg;

  OutboundLine(
      this.itemCode, this.itemName, this.quantity, this.unit, this.weightKg);
}

/* ---------- Detail screen ---------- */
class OutboundDetailScreen extends StatelessWidget {
  final OutboundReceipt receipt;
  OutboundDetailScreen({super.key, required this.receipt});

  final _fmt = DateFormat('dd/MM/yyyy');
  final _rng = Random();

  /* ---- giả lập dữ liệu dòng chi tiết (5–8 dòng) ---- */
  List<OutboundLine> _fakeLines() {
    final items = [
      {'code': 'F001', 'name': 'Cám nổi 3mm', 'unit': 'kg'},
      {'code': 'F002', 'name': 'Cám chìm 2mm', 'unit': 'kg'},
      {'code': 'E001', 'name': 'Máy sục khí',  'unit': 'bộ'},
      {'code': 'E002', 'name': 'Ống nước PVC', 'unit': 'm'},
    ];
    return List.generate(5 + _rng.nextInt(4), (i) {
      final it = items[_rng.nextInt(items.length)];
      final qty = 5 + _rng.nextInt(30);
      final kg  = it['unit']=='kg' ? qty.toDouble() : qty * 2;
      return OutboundLine(it['code']!, it['name']!, qty.toDouble(),
          it['unit']!, kg.toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final lines = _fakeLines();
    final totalKg =
        lines.fold<double>(0, (s, e) => s + e.weightKg).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ${receipt.code}'),
        backgroundColor: CustomColors.appbarColor,
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
                  _info('Ngày xuất', _fmt.format(receipt.date)),
                  _info('Nơi nhận', receipt.destination),
                  const SizedBox(height: 4),
                  _info('Số mục', lines.length.toString()),
                  _info('Tổng khối lượng', '$totalKg kg'),
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
                      DataColumn(label: Text('Kg', style: _headStyle), numeric: true),
                    ],
                    rows: lines
                        .map((l) => DataRow(cells: [
                              DataCell(Text(l.itemCode)),
                              DataCell(Text(l.itemName)),
                              DataCell(Text(l.quantity.toStringAsFixed(0))),
                              DataCell(Text(l.unit)),
                              DataCell(Text(l.weightKg.toStringAsFixed(0))),
                            ]))
                        .toList(),
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

  Widget _info(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            SizedBox(width: 120, child: Text('$k:')),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );
}

const _headStyle = TextStyle(color: Colors.white);
