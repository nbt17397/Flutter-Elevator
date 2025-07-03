import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class WaterPoint {
  final int day;
  final double inL; // nước vào (m³)
  final double outL; // nước xả (m³)
  final int rating; // -1 .. 1
  const WaterPoint(this.day, this.inL, this.outL, this.rating);
}

/* ---------- Screen ---------- */
class WaterQualityReportScreen extends StatefulWidget {
  const WaterQualityReportScreen({super.key});

  @override
  State<WaterQualityReportScreen> createState() =>
      _WaterQualityReportScreenState();
}

class _WaterQualityReportScreenState extends State<WaterQualityReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  late final Map<String, List<WaterPoint>> _pondData;

  String _filter = 'P1'; // 👉 mặc định P1

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
  }

  /* ---- Sinh dữ liệu giả ---- */
  List<WaterPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    final off = _ponds.indexOf(pond) * 10; // lệch nhẹ theo bể
    int rating = rnd.nextInt(3) - 1; // -1..1
    return List.generate(10, (i) {
      if (i > 0) rating = (rating + rnd.nextInt(3) - 1).clamp(-1, 1);
      final inL = 30 + off + rnd.nextInt(4);
      final outL = 20 + off + rnd.nextInt(4);
      return WaterPoint(i + 1, inL.toDouble(), outL.toDouble(), rating);
    });
  }

  /* ---- Lấy dữ liệu bể đang chọn ---- */
  List<WaterPoint> get _data => _pondData[_filter]!;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final chartH = height * 0.35;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo chất lượng nước'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /* ---------- Dropdown filter ---------- */
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
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
                              child: Text(e,
                                  style: const TextStyle(fontSize: 14))))
                          .toList(),
                      onChanged: (v) => setState(() => _filter = v!),
                      isDense: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      dropdownColor: Colors.white,
                      style: const TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              /* ---------- Chart 1: Nước vào / Nước xả ---------- */
              Container(
                height: chartH,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Nước vào & Nước xả (m³) – $_filter',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis:
                      NumericAxis(minimum: 1, maximum: 10, interval: 1),
                  series: [
                    StackedColumnSeries<WaterPoint, int>(
                      name: 'Nước vào',
                      groupName: 'in', // nhóm 1
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.inL,
                      color: Colors.blue.shade700,
                    ),
                    StackedColumnSeries<WaterPoint, int>(
                      name: 'Nước xả',
                      groupName: 'out', // nhóm 2
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.outL,
                      color: Colors.orange.shade400,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              /* ---------- Chart 2: Điểm chất lượng ---------- */
              Container(
                height: height * 0.25,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Điểm chất lượng nước – $_filter',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  primaryXAxis:
                      NumericAxis(minimum: 1, maximum: 10, interval: 1),
                  primaryYAxis:
                      NumericAxis(minimum: -2, maximum: 2, interval: 1),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: [
                    LineSeries<WaterPoint, int>(
                      name: 'Điểm',
                      dataSource: _data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.rating,
                      markerSettings: const MarkerSettings(
                          isVisible: true, height: 6, width: 6),
                      color: Colors.green.shade700,
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
}
