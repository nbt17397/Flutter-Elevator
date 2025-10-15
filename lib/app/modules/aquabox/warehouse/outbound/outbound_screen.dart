import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/warehouse/outbound/outbound_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

/* ---------- DataSource ---------- */
class _OutboundSource extends DataTableSource {
  final List<OutboundReceipt> data;
  final DateFormat fmt = DateFormat('dd/MM/yyyy');
  final BuildContext ctx;
  _OutboundSource(this.data, this.ctx);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final r = data[index];
    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => OutboundDetailScreen(receipt: r)),
      ),
      cells: [
        DataCell(Center(child: Text(r.code))),
        DataCell(Center(child: Text(fmt.format(r.date)))),
        DataCell(Center(child: Text(r.destination))),
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

/* ---------- Screen ---------- */
class OutboundScreen extends StatefulWidget {
  const OutboundScreen({super.key});

  @override
  State<OutboundScreen> createState() => _OutboundScreenState();
}

class _OutboundScreenState extends State<OutboundScreen> {
  late final _OutboundSource _source;

  @override
  void initState() {
    super.initState();

    _source = _OutboundSource(
      List.generate(
        12,
        (i) => OutboundReceipt(
          'PXK-${200 + i}',
          DateTime(2025, 6, 10 + i),
          'Ao nuôi $i',
          1 + (i % 4),
          150 + i * 15,
        ),
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Phiếu xuất kho'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: PaginatedDataTable2(
          columns: const [
            DataColumn2(label: Center(child: Text('Mã')), size: ColumnSize.S),
            DataColumn2(label: Center(child: Text('Ngày')), size: ColumnSize.M),
            DataColumn2(label: Center(child: Text('Nơi nhận')), size: ColumnSize.L),
          ],
          source: _source,
          rowsPerPage: 10,
          availableRowsPerPage: const [5, 10, 10, 20],
          showFirstLastButtons: true,
          columnSpacing: 24,
          headingRowColor:
              WidgetStateProperty.resolveWith((_) => Colors.black),
          headingTextStyle: const TextStyle(color: Colors.white),
          showCheckboxColumn: false,
        ),
      ),
    );
  }
}
