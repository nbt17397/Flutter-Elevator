import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ----------------- Model ----------------- */
class DensityPoint {
  final int day;
  final int qty;
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

  int _startDayFilter = 1;
  int _endDayFilter = 10;

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
    _selectedPonds = _ponds.toSet();
  }

  /* ------------ Fake data ------------- */
  List<DensityPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    int offset = _ponds.indexOf(pond) * 120;
    int current = 950 + offset + rnd.nextInt(50);
    return List.generate(10, (i) {
      if (i > 0) current -= 40 + rnd.nextInt(60);
      return DensityPoint(i + 1, current.clamp(100, 2000));
    });
  }

  void _showRangePicker() {
    double start = _startDayFilter.toDouble();
    double end = _endDayFilter.toDouble();

    Alert(
      context: context,
      style: AlertStyle(
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        backgroundColor: Colors.white,
        overlayColor: Colors.black.withOpacity(0.6),
        isCloseButton: false,
      ),
      title: "",
      content: StatefulBuilder(
        builder: (context, setStateDialog) => Column(
          children: [
            /* --------- Header icon ---------- */
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CustomColors.appbarColor,
                    CustomColors.appbarColor.withOpacity(0.7)
                  ],
                ),
              ),
              child:
                  const Icon(Icons.filter_alt, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 20),

            /* --------- RangeSlider ---------- */
            RangeSlider(
              min: 1,
              max: 10,
              divisions: 9,
              values: RangeValues(start, end),
              labels:
                  RangeLabels(start.round().toString(), end.round().toString()),
              activeColor: CustomColors.appbarColor,
              inactiveColor: CustomColors.appbarColor.withOpacity(0.2),
              onChanged: (v) => setStateDialog(() {
                start = v.start;
                end = v.end;
              }),
            ),
            Text(
              'Từ ngày ${start.round()} đến ngày ${end.round()}',
              style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 14),
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          child: const Text("HỦY",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          child: const Text("ÁP DỤNG",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          color: Colors.blue.shade700,
          onPressed: () {
            setState(() {
              _startDayFilter = start.round();
              _endDayFilter = end.round();
            });
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  /* -------------- Bảng tóm tắt -------------- */
  DataTable _buildSummary() {
    final rows = _selectedPonds.map((p) {
      final data = _pondData[p]!
          .where((d) => d.day >= _startDayFilter && d.day <= _endDayFilter)
          .toList();
      final start = data.first.qty;
      final end = data.last.qty;
      final diff = end - start;
      return DataRow(cells: [
        DataCell(Text(p)),
        DataCell(Text(start.toString())),
        DataCell(Text(end.toString())),
        DataCell(Text(diff.toString())),
      ]);
    }).toList();

    return DataTable(
      headingRowColor: WidgetStateProperty.resolveWith((_) => Colors.black),
      dataRowColor: WidgetStateProperty.resolveWith((_) => Colors.white),
      columnSpacing: 24,
      columns: const [
        DataColumn(
            label: Text('Bể nuôi', style: TextStyle(color: Colors.white))),
        DataColumn(
            label: Text('Ngày đầu', style: TextStyle(color: Colors.white))),
        DataColumn(
            label: Text('Ngày cuối', style: TextStyle(color: Colors.white))),
        DataColumn(
            label: Text('SL giảm', style: TextStyle(color: Colors.white))),
      ],
      rows: rows,
      showCheckboxColumn: false,
    );
  }

  /* --------------- UI chính --------------- */
  @override
  Widget build(BuildContext context) {
    final halfHeight = MediaQuery.of(context).size.height * 0.45;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo mật độ nuôi'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              tooltip: 'Lọc khoảng ngày',
              icon: const Icon(Icons.filter_alt),
              onPressed: _showRangePicker,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                /* ---------- Biểu đồ ---------- */
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
                    legend: Legend(
                        isVisible: true, position: LegendPosition.bottom),
                    tooltipBehavior: TooltipBehavior(enable: true),
                    primaryXAxis: NumericAxis(
                      interval: 1,
                      minimum: _startDayFilter.toDouble(),
                      maximum: _endDayFilter.toDouble(),
                    ),
                    series: _selectedPonds.map((pond) {
                      final baseColor =
                          Colors.primaries[_ponds.indexOf(pond) * 2];
                      final filtered = _pondData[pond]!
                          .where((d) =>
                              d.day >= _startDayFilter &&
                              d.day <= _endDayFilter)
                          .toList();
                      return LineSeries<DensityPoint, int>(
                        name: pond,
                        dataSource: filtered,
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

                /* ---------- Bảng tóm tắt ---------- */
                SizedBox(
                  width: MediaQuery.of(context).size.width - 24,
                  child: _buildSummary(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
