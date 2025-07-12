import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class FeedPoint {
  final int day;
  final double camNoi, camChim, grower;
  const FeedPoint(this.day, this.camNoi, this.camChim, this.grower);
}

/* ---------- Pie helper ---------- */
class _PieData {
  final String label;
  final double value;
  _PieData(this.label, this.value);
  double percent(List<_PieData> all) =>
      value / all.fold<double>(0, (s, e) => s + e.value) * 100;
}

/* ---------- Màu cám đồng nhất ---------- */
const Map<String, Color> feedColors = {
  'Cám nổi': Color(0xFF1565C0),
  'Cám chìm': Color(0xFFEF6C00),
  'Grower': Color(0xFF2E7D32),
};

/* ---------- Screen ---------- */
class FeedReportScreen extends StatefulWidget {
  const FeedReportScreen({super.key});
  @override
  State<FeedReportScreen> createState() => _FeedReportScreenState();
}

class _FeedReportScreenState extends State<FeedReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];

  late final Map<String, List<FeedPoint>> _pondData;
  String _filterPond = 'Tất cả';
  int _startDayFilter = 1;
  int _endDayFilter = 10;

  @override
  void initState() {
    super.initState();
    _pondData = {for (var p in _ponds) p: _fakeData(p)};
  }

  /* ---------- Fake data ---------- */
  List<FeedPoint> _fakeData(String pond) {
    final rnd = Random(pond.hashCode);
    final off = _ponds.indexOf(pond) * 2;
    return List.generate(10, (i) {
      final a = 5 + off + rnd.nextInt(3) + i * .3;
      final b = 4 + off + rnd.nextInt(2) + i * .25;
      final c = 3 + off + rnd.nextInt(2) + i * .2;
      return FeedPoint(i + 1, a, b, c);
    });
  }

  /* ---------- Data filtered ---------- */
  List<FeedPoint> get _dataFiltered {
    if (_filterPond != 'Tất cả') {
      return _pondData[_filterPond]!
          .where((d) => d.day >= _startDayFilter && d.day <= _endDayFilter)
          .toList();
    }
    // gộp tất cả bể
    final Map<int, List<double>> sums = {
      for (var d = _startDayFilter; d <= _endDayFilter; d++) d: [0, 0, 0]
    };
    for (var p in _ponds) {
      for (var pt in _pondData[p]!) {
        if (pt.day < _startDayFilter || pt.day > _endDayFilter) continue;
        sums[pt.day]![0] += pt.camNoi;
        sums[pt.day]![1] += pt.camChim;
        sums[pt.day]![2] += pt.grower;
      }
    }
    return sums.entries
        .map((e) => FeedPoint(e.key, e.value[0], e.value[1], e.value[2]))
        .toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }

  /* ---------- Pie data ---------- */
  List<_PieData> get _pie {
    double a = 0, b = 0, c = 0;
    for (var p in _dataFiltered) {
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

  /* ---------- Alert filter ---------- */
  void _showFilterDialog() {
    double sDay = _startDayFilter.toDouble();
    double eDay = _endDayFilter.toDouble();
    String pondSel = _filterPond;

    Alert(
      context: context,
      style: AlertStyle(
        backgroundColor: Colors.white,
        overlayColor: Colors.black54,
        isCloseButton: false,
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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

            // Dropdown chọn bể (bọc border)
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
                  items: ['Tất cả', ..._ponds]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => pondSel = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // RangeSlider ngày (bọc border)
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
          child: const Text("HỦY", style: TextStyle(color: Colors.white,fontSize: 16)),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          color: Colors.blue,
          child: const Text("ÁP DỤNG", style: TextStyle(color: Colors.white,fontSize: 16)),
          onPressed: () {
            setState(() {
              _filterPond = pondSel;
              _startDayFilter = sDay.round();
              _endDayFilter = eDay.round();
            });
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final chartH = MediaQuery.of(context).size.height * .33;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo thức ăn'),
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
                _buildLineChart(chartH),
                const SizedBox(height: 16),
                _buildPieChart(chartH),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------- Line Chart ---------- */
  Widget _buildLineChart(double h) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          palette: feedColors.values.toList(),
          title: ChartTitle(
              text:
                  'Khối lượng thức ăn – $_filterPond (ngày $_startDayFilter–$_endDayFilter)',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: NumericAxis(
              minimum: _startDayFilter.toDouble(),
              maximum: _endDayFilter.toDouble(),
              interval: 1),
          series: [
            LineSeries<FeedPoint, int>(
              name: 'Cám nổi',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.camNoi,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
            LineSeries<FeedPoint, int>(
              name: 'Cám chìm',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.camChim,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
            LineSeries<FeedPoint, int>(
              name: 'Grower',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.grower,
              markerSettings: const MarkerSettings(isVisible: true),
            ),
          ],
        ),
      );

  /* ---------- Pie Chart ---------- */
  Widget _buildPieChart(double h) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCircularChart(
          title: ChartTitle(
              text:
                  'Tỷ trọng thức ăn – $_filterPond (${_startDayFilter}–${_endDayFilter})',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            PieSeries<_PieData, String>(
              dataSource: _pie,
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              pointColorMapper: (d, _) => feedColors[d.label],
              dataLabelMapper: (d, _) =>
                  '${d.label}: ${d.percent(_pie).toStringAsFixed(0)}%',
              dataLabelSettings: const DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside),
            ),
          ],
        ),
      );

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}
