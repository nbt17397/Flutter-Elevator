import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'outbound_detail_screen.dart';

/* ---------- Model ---------- */
class OutboundReceipt {
  final String code;
  final DateTime date;
  final String destination;
  final int itemCount;
  final double totalWeight;
  OutboundReceipt(
      this.code, this.date, this.destination, this.itemCount, this.totalWeight);
}

/* ---------- Screen ---------- */
class OutboundScreen extends StatelessWidget {
  OutboundScreen({super.key});

  final _fmt = DateFormat('dd/MM/yyyy');

  final List<OutboundReceipt> _receipts = List.generate(
    12,
    (i) => OutboundReceipt(
      'PXK-${200 + i}',
      DateTime(2025, 6, 10 + i),
      'Ao nuôi $i',
      1 + (i % 4),
      150 + i * 15,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phiếu xuất kho'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
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
                DataColumn(label: Text('Mã',        style: _head)),
                DataColumn(label: Text('Ngày',      style: _head)),
                DataColumn(label: Text('Nơi nhận',  style: _head)),
                DataColumn(label: Text('Số mục',    style: _head), numeric: true),
                DataColumn(label: Text('Kg',        style: _head), numeric: true),
              ],
              rows: _receipts
                  .map((r) => DataRow(
                        cells: [
                          DataCell(Text(r.code)),
                          DataCell(Text(_fmt.format(r.date))),
                          DataCell(Text(r.destination)),
                          DataCell(Text(r.itemCount.toString())),
                          DataCell(Text(r.totalWeight.toStringAsFixed(0))),
                        ],
                        onSelectChanged: (_) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                OutboundDetailScreen(receipt: r),
                          ),
                        ),
                      ))
                  .toList(),
              showCheckboxColumn: false,
            ),
          ),
        ),
      ),
    );
  }
}

const _head = TextStyle(color: Colors.white);
