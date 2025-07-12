import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/batch/water_quality/fullchart_report_water_quality_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class WaterPoint {
  final int day;
  final double inL, outL, ph, oxy;
  final double rating;
  const WaterPoint(
      this.day, this.inL, this.outL, this.rating, this.ph, this.oxy);
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

  /* --- bộ lọc --- */
  String _filterPond = 'P1'; // mặc định P1 (không còn “Tất cả”)
  int _startDay = 1;
  int _endDay = 10;

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
  }

  /* ---------- Giả lập dữ liệu ---------- */
  List<WaterPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    final off = _ponds.indexOf(pond) * 10;
    int rating = rnd.nextInt(3) - 1;
    return List.generate(10, (i) {
      if (i > 0) rating = (rating + rnd.nextInt(3) - 1).clamp(-1, 1);
      final inL = 30 + off + rnd.nextInt(4);
      final outL = 20 + off + rnd.nextInt(4);
      final ph = 6.5 + rnd.nextDouble() * 1.5;
      final oxy = 4.5 + rnd.nextDouble() * 2.0;
      return WaterPoint(
          i + 1, inL.toDouble(), outL.toDouble(), rating.toDouble(), ph, oxy);
    });
  }

  /* ---------- Dữ liệu sau lọc ---------- */
  List<WaterPoint> get _dataFiltered => _pondData[_filterPond]!
      .where((d) => d.day >= _startDay && d.day <= _endDay)
      .toList();

  /* ---------- Hộp thoại lọc ---------- */
  void _showFilterDialog() {
    double sDay = _startDay.toDouble();
    double eDay = _endDay.toDouble();
    String pondSel = _filterPond;

    Alert(
      context: context,
      style: AlertStyle(
        backgroundColor: Colors.white,
        overlayColor: Colors.black54,
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      title: "",
      content: StatefulBuilder(
        builder: (_, setStateDialog) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      CustomColors.appbarColor,
                      CustomColors.appbarColor.withOpacity(0.7)
                    ],
                  ),
                ),
                child:
                    const Icon(Icons.filter_alt, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 16),

            /* ---- Bể ---- */
            const Text('Chọn bể',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: pondSel,
                  items: _ponds
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => pondSel = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            /* ---- Khoảng ngày ---- */
            const Text('Khoảng ngày',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black54),
                borderRadius: BorderRadius.circular(8),
              ),
              child: RangeSlider(
                min: 1,
                max: 10,
                divisions: 9,
                values: RangeValues(sDay, eDay),
                labels: RangeLabels(
                    sDay.round().toString(), eDay.round().toString()),
                activeColor: CustomColors.appbarColor,
                inactiveColor: CustomColors.appbarColor.withOpacity(0.2),
                onChanged: (v) => setStateDialog(() {
                  sDay = v.start;
                  eDay = v.end;
                }),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('Từ ngày ${sDay.round()} đến ${eDay.round()}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          child: const Text("HỦY",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          color: CustomColors.appbarColor,
          child: const Text("ÁP DỤNG",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () {
            setState(() {
              _filterPond = pondSel;
              _startDay = sDay.round();
              _endDay = eDay.round();
            });
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final chartH = h * 0.5;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo chất lượng nước'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              tooltip: 'Bộ lọc',
              icon: const Icon(Icons.filter_alt),
              onPressed: _showFilterDialog,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildComboChart(chartH),
                const SizedBox(height: 16),
                _buildRatingChart(h * 0.25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------- Chart 1 ---------- */
  Widget _buildComboChart(double h) => Stack(
        children: [
          Container(
            height: h,
            padding: const EdgeInsets.all(8),
            decoration: _box,
            child: SfCartesianChart(
              title: ChartTitle(
                  text: 'Nước vào / Nước xả & pH, Oxy – $_filterPond',
                  textStyle: const TextStyle(fontWeight: FontWeight.bold)),
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              tooltipBehavior: TooltipBehavior(enable: true),
              primaryXAxis: NumericAxis(
                  minimum: _startDay.toDouble(),
                  maximum: _endDay.toDouble(),
                  interval: 1),
              axes: [
                NumericAxis(
                  name: 'phOxy',
                  opposedPosition: true,
                  minimum: 0,
                  maximum: 10,
                  interval: 2,
                ),
              ],
              series: [
                StackedColumnSeries<WaterPoint, int>(
                  name: 'Nước vào',
                  groupName: 'in',
                  dataSource: _dataFiltered,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.inL,
                  color: Colors.blue.shade700,
                ),
                StackedColumnSeries<WaterPoint, int>(
                  name: 'Nước xả',
                  groupName: 'out',
                  dataSource: _dataFiltered,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.outL,
                  color: Colors.orange.shade400,
                ),
                LineSeries<WaterPoint, int>(
                  name: 'pH',
                  dataSource: _dataFiltered,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.ph,
                  yAxisName: 'phOxy',
                  markerSettings: const MarkerSettings(
                      isVisible: true, width: 6, height: 6),
                  color: Colors.purple.shade700,
                  width: 2,
                ),
                LineSeries<WaterPoint, int>(
                  name: 'Oxy',
                  dataSource: _dataFiltered,
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.oxy,
                  yAxisName: 'phOxy',
                  markerSettings: const MarkerSettings(
                      isVisible: true, width: 6, height: 6),
                  color: Colors.green.shade700,
                  width: 2,
                ),
              ],
            ),
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              tooltip: 'Mở rộng',
              icon: const Icon(Icons.open_in_full, size: 18),
              splashRadius: 18,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullChartWaterQualityScreen(
                      title: '$_filterPond • Ngày $_startDay–$_endDay',
                      data: _dataFiltered,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  /* ---------- Chart 2 ---------- */
  Widget _buildRatingChart(double h) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Điểm chất lượng nước – $_filterPond',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          primaryXAxis: NumericAxis(
              minimum: _startDay.toDouble(),
              maximum: _endDay.toDouble(),
              interval: 1),
          primaryYAxis: NumericAxis(minimum: -2, maximum: 2, interval: 1),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            LineSeries<WaterPoint, int>(
              name: 'Điểm',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.rating,
              markerSettings:
                  const MarkerSettings(isVisible: true, width: 6, height: 6),
              color: Colors.red.shade700,
            ),
          ],
        ),
      );

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}
