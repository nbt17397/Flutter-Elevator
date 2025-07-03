import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class HealthPoint {
  final int day;
  final double lengthCm;
  final double widthCm;
  final int healthRating;   // -2 … 2
  final int fecesRating;    // -2 … 2
  const HealthPoint(this.day, this.lengthCm, this.widthCm,
      this.healthRating, this.fecesRating);
}

/* ---------- Screen ---------- */
class HealthReportScreen extends StatefulWidget {
  const HealthReportScreen({super.key});

  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  late final Map<String, List<HealthPoint>> _pondData;

  String _filter = 'P1'; // mặc định P1

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
  }

  /* ---- Fake data ---- */
  List<HealthPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    final off = _ponds.indexOf(pond) * .5;
    double len = 5 + off;
    double wid = 1.5 + off * .5;
    int hRate = rnd.nextInt(5) - 2;   // -2..2
    int fRate = rnd.nextInt(5) - 2;
    return List.generate(10, (i) {
      if (i > 0) {
        len += rnd.nextDouble() * .4;
        wid += rnd.nextDouble() * .2;
        hRate = (hRate + rnd.nextInt(3) - 1).clamp(-2, 2);
        fRate = (fRate + rnd.nextInt(3) - 1).clamp(-2, 2);
      }
      return HealthPoint(i + 1, len, wid, hRate, fRate);
    });
  }

  List<HealthPoint> get _data => _pondData[_filter]!;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final chartH = h * .33;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo sức khoẻ'),
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

              /* ---------- Chart 1: Chiều dài / rộng ---------- */
              _buildSizeChart(chartH),

              const SizedBox(height: 16),

              /* ---------- Chart 2: Rating sức khỏe & phân ---------- */
              _buildRatingChart(chartH),
            ],
          ),
        ),
      ),
    );
  }

  /* --- Chart kích thước --- */
  Widget _buildSizeChart(double height) => Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Kích thước (cm) – $_filter',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: NumericAxis(minimum: 1, maximum: 10, interval: 1),
          series: [
            LineSeries<HealthPoint, int>(
              name: 'Chiều dài',
              dataSource: _data,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.lengthCm,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.blue.shade700,
            ),
            LineSeries<HealthPoint, int>(
              name: 'Chiều rộng',
              dataSource: _data,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.widthCm,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.orange.shade600,
            ),
          ],
        ),
      );

  /* --- Chart rating --- */
  Widget _buildRatingChart(double height) => Container(
        height: height,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Điểm sức khoẻ – $_filter',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: NumericAxis(minimum: 1, maximum: 10, interval: 1),
          primaryYAxis: NumericAxis(
              minimum: -2, maximum: 2, interval: 1),
          series: [
            LineSeries<HealthPoint, int>(
              name: 'Tình trạng sức khoẻ',
              dataSource: _data,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.healthRating,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.green.shade700,
            ),
            LineSeries<HealthPoint, int>(
              name: 'Tình trạng phân',
              dataSource: _data,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.fecesRating,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.purple.shade600,
            ),
          ],
        ),
      );
}
