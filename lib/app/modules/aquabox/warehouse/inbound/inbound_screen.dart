import 'package:data_table_2/data_table_2.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/warehouse/inbound/inbound_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ----------------- Model -----------------
class InboundReceipt {
  final String code;
  final DateTime date;
  final String supplier;
  InboundReceipt(this.code, this.date, this.supplier);
}

/// ----------------- DataTableSource -----------------
class _ReceiptSource extends DataTableSource {
  final List<InboundReceipt> data;
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
          MaterialPageRoute(builder: (_) => InboundDetailScreen()),
        );
      },
      cells: [
        DataCell(Center(child: Text(r.code))),
        DataCell(Center(child: Text(fmt.format(r.date)))),
        DataCell(Center(child: Text(r.supplier))),
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
  late final _ReceiptSource _source;

  @override
  void initState() {
    super.initState();

    final receipts = [
      InboundReceipt('PNK-001', DateTime(2025, 5, 16), 'Cargill VN'),
      InboundReceipt('PNK-002', DateTime(2025, 5, 18), 'Skretting'),
      InboundReceipt('PNK-003', DateTime(2025, 5, 21), 'Thiết bị An Phát'),
      InboundReceipt('PNK-004', DateTime(2025, 6, 2), 'Thức ăn GreenFeed'),
      ...List.generate(
        25,
        (i) => InboundReceipt(
          'PNK-${100 + i}',
          DateTime(2025, 6, 5 + i),
          'Nhà cung cấp $i',
        ),
      ),
    ];

    _source = _ReceiptSource(receipts, context);
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
        ),
        body: PaginatedDataTable2(
          columns: const [
            DataColumn2(label: Center(child: Text('Mã phiếu')), size: ColumnSize.S),
            DataColumn2(label: Center(child: Text('Ngày nhập')), size: ColumnSize.M),
            DataColumn2(label: Center(child: Text('Nhà cung cấp')), size: ColumnSize.L),
          ],
          source: _source,
          rowsPerPage: 10,                     // mặc định 8 dòng / trang
          availableRowsPerPage: const [5, 10, 10, 20],
          showFirstLastButtons: true,         // hiển thị nút «Trang đầu / cuối»
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
