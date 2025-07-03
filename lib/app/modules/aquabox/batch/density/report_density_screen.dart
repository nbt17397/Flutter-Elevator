import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ----------------- Model ----------------- */
class DensityPoint {
  final int day;   // ngày nuôi
  final int qty;   // số lượng con
  DensityPoint(this.day, this.qty);
}

/* --------------- Screen ------------------ */
class ReportDensityScreen extends StatefulWidget {
  const ReportDensityScreen({super.key});

  @override
  State<ReportDensityScreen> createState() => _ReportDensityScreenState();
}

class _ReportDensityScreenState extends State<ReportDensityScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];

  late final Map<String, List<DensityPoint>> _pondData;
  late Set<String> _selectedPonds;

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
    _selectedPonds = _ponds.toSet();
  }

  List<DensityPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    int offset = _ponds.indexOf(pond) * 120;
    int current = 950 + offset + rnd.nextInt(50);
    return List.generate(10, (i) {
      if (i > 0) current -= 40 + rnd.nextInt(60);
      return DensityPoint(i + 1, current.clamp(100, 2000));
    });
  }

  DataTable _buildSummary() {
    final rows = _selectedPonds.map((p) {
      final data = _pondData[p]!;
      final start = data.first.qty;
      final end   = data.last.qty;
      final diff  = end - start;
      return DataRow(cells: [
        DataCell(Text(p)),
        DataCell(Text(start.toString())),
        DataCell(Text(end.toString())),
        DataCell(Text(diff.toString())),
      ]);
    }).toList();

    return DataTable(
      headingRowColor: MaterialStateProperty.resolveWith((_) => Colors.black),
      dataRowColor: MaterialStateProperty.resolveWith((_) => Colors.grey.shade300),
      columnSpacing: 24,
      columns: const [
        DataColumn(label: Text('Bể nuôi',    style: TextStyle(color: Colors.white))),
        DataColumn(label: Text('Ngày 1',     style: TextStyle(color: Colors.white))),
        DataColumn(label: Text('Ngày 10',    style: TextStyle(color: Colors.white))),
        DataColumn(label: Text('Tổng lượng giảm',  style: TextStyle(color: Colors.white))),
      ],
      rows: rows,
      showCheckboxColumn: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final halfHeight = MediaQuery.of(context).size.height * 0.45;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo mật độ nuôi'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [

              // Chart
              Container(
                height: halfHeight,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Mật độ nuôi con/ngày',
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: NumericAxis(
                    interval: 1,
                    minimum: 1,
                    maximum: 10,
                  ),
                  series: _selectedPonds.map((pond) {
                    final baseColor =
                        Colors.primaries[_ponds.indexOf(pond) * 2];
                    return LineSeries<DensityPoint, int>(
                      name: pond,
                      dataSource: _pondData[pond]!,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.qty,
                      markerSettings: const MarkerSettings(
                          isVisible: true, height: 6, width: 6),
                      color: baseColor,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Bảng tóm tắt
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _buildSummary(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
