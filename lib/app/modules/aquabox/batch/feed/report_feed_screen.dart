import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class FeedPoint {
  final int day;
  final double camNoi;   // Cám nổi
  final double camChim;  // Cám chìm
  final double grower;   // Grower
  const FeedPoint(this.day, this.camNoi, this.camChim, this.grower);
}

/* ---------- Screen ---------- */
class FeedReportScreen extends StatefulWidget {
  const FeedReportScreen({super.key});

  @override
  State<FeedReportScreen> createState() => _FeedReportScreenState();
}

class _FeedReportScreenState extends State<FeedReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  final List<String> _feeds = ['Cám nổi', 'Cám chìm', 'Grower'];   // ✅

  late final Map<String, List<FeedPoint>> _pondData;
  String _filter = 'P1';

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
  }

  /* ---- Giả lập dữ liệu ---- */
  List<FeedPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    final off = _ponds.indexOf(pond) * 2;
    return List.generate(10, (i) {
      final a = 5 + off + rnd.nextInt(3) + i * .3;   // Cám nổi
      final b = 4 + off + rnd.nextInt(2) + i * .25;  // Cám chìm
      final c = 3 + off + rnd.nextInt(2) + i * .2;   // Grower
      return FeedPoint(i + 1, a, b, c);
    });
  }

  List<FeedPoint> get _data => _pondData[_filter]!;

  /* ---- Tổng khối lượng cho Pie ---- */
  List<_PieData> get _pie {
    double a = 0, b = 0, c = 0;
    for (var p in _data) {
      a += p.camNoi;
      b += p.camChim;
      c += p.grower;
    }
    return [
      _PieData('Cám nổi', a),
      _PieData('Cám chìm', b),
      _PieData('Grower', c),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final chartH = h * .33;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo thức ăn'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /* ---------- Dropdown ---------- */
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filter,
                      items: _ponds
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(e, style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _filter = v!),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              /* ---------- Chart 1: Line ---------- */
              Container(
                height: chartH,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: _box,
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Khối lượng thức ăn (kg) – $_filter',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: NumericAxis(minimum: 1, maximum: 10, interval: 1),
                  series: [
                    LineSeries<FeedPoint, int>(
                      name: 'Cám nổi',
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.camNoi,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.blue.shade700,
                    ),
                    LineSeries<FeedPoint, int>(
                      name: 'Cám chìm',
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.camChim,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.orange.shade600,
                    ),
                    LineSeries<FeedPoint, int>(
                      name: 'Grower',
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.grower,
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /* ---------- Chart 2: Pie ---------- */
              Container(
                height: chartH,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: _box,
                child: SfCircularChart(
                  title: ChartTitle(
                      text: 'Tỷ trọng thức ăn – $_filter',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: [
                    PieSeries<_PieData, String>(
                      dataSource: _pie,
                      xValueMapper: (d, _) => d.label,
                      yValueMapper: (d, _) => d.value,
                      dataLabelMapper: (d, _) =>
                          '${d.label}: ${d.percent(_pie).toStringAsFixed(0)}%',
                      dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}

/* ---------- Pie helper ---------- */
class _PieData {
  final String label;
  final double value;
  _PieData(this.label, this.value);
  double percent(List<_PieData> all) =>
      value / all.fold<double>(0, (s, e) => s + e.value) * 100;
}
