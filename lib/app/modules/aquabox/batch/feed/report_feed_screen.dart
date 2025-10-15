import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class FeedPoint {
  final int day;
  final Map<String, double> foodQuantities;
  const FeedPoint(this.day, this.foodQuantities);
}

/* ---------- Pie helper ---------- */
class _PieData {
  final String label;
  final double value;
  _PieData(this.label, this.value);
  double percent(List<_PieData> all) =>
      value / all.fold<double>(0, (s, e) => s + e.value) * 100;
}

/* ---------- Screen ---------- */
class FeedReportScreen extends StatefulWidget {
  final bool isAquatic;
  const FeedReportScreen({super.key, required this.isAquatic});
  @override
  State<FeedReportScreen> createState() => _FeedReportScreenState();
}

class _FeedReportScreenState extends State<FeedReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  final List<String> _cages = ['C1', 'C2', 'C3'];
  final Map<String, List<String>> _foodTypes = {
    'aquatic': ['Cám nổi', 'Cám chìm', 'Grower'],
    'animal': ['Thức ăn viên', 'Cám khô', 'Bột'],
  };
  final Map<String, Color> _foodColors = {
    'Cám nổi': const Color(0xFF1565C0),
    'Cám chìm': const Color(0xFFEF6C00),
    'Grower': const Color(0xFF2E7D32),
    'Thức ăn viên': const Color(0xFF2E7D32),
    'Cám khô': const Color(0xFFC0CA33),
    'Bột': const Color(0xFF757575),
  };

  late final List<String> _currentFoodTypes;
  late final List<String> _currentEntities;
  late final Map<String, List<FeedPoint>> _entityData;

  String _filterEntity = 'Tất cả';
  int _startDayFilter = 1;
  int _endDayFilter = 10;

  @override
  void initState() {
    super.initState();
    _currentFoodTypes =
        widget.isAquatic ? _foodTypes['aquatic']! : _foodTypes['animal']!;
    _currentEntities = widget.isAquatic ? _ponds : _cages;
    _entityData = {for (var e in _currentEntities) e: _fakeData(e)};
  }

  /* ---------- Fake data (đã được sửa lại) ---------- */
  List<FeedPoint> _fakeData(String entity) {
    final rnd = Random(entity.hashCode);
    final off = _currentEntities.indexOf(entity);
    return List.generate(10, (i) {
      final Map<String, double> quantities = {};
      for (var food in _currentFoodTypes) {
        quantities[food] = (10 + off * 2 + rnd.nextInt(5) + i * .5);
      }
      return FeedPoint(i + 1, quantities);
    });
  }

  /* ---------- Data filtered (đã được sửa lại) ---------- */
  List<FeedPoint> get _dataFiltered {
    if (_filterEntity != 'Tất cả') {
      return _entityData[_filterEntity]!
          .where((d) => d.day >= _startDayFilter && d.day <= _endDayFilter)
          .toList();
    }
    // gộp tất cả thực thể
    final Map<int, Map<String, double>> sums = {
      for (var d = _startDayFilter; d <= _endDayFilter; d++)
        d: {for (var food in _currentFoodTypes) food: 0.0}
    };
    for (var entity in _currentEntities) {
      for (var pt in _entityData[entity]!) {
        if (pt.day < _startDayFilter || pt.day > _endDayFilter) continue;
        pt.foodQuantities.forEach((food, qty) {
          sums[pt.day]![food] = (sums[pt.day]![food] ?? 0) + qty;
        });
      }
    }
    return sums.entries.map((e) => FeedPoint(e.key, e.value)).toList()
      ..sort((a, b) => a.day.compareTo(b.day));
  }

  /* ---------- Pie data (đã được sửa lại) ---------- */
  List<_PieData> get _pie {
    final Map<String, double> totalFoodQuantities = {
      for (var food in _currentFoodTypes) food: 0.0
    };
    for (var point in _dataFiltered) {
      point.foodQuantities.forEach((food, qty) {
        totalFoodQuantities[food] = (totalFoodQuantities[food] ?? 0) + qty;
      });
    }
    return totalFoodQuantities.entries
        .map((e) => _PieData(e.key, e.value))
        .toList();
  }

  /* ---------- Alert filter ---------- */
  void _showFilterDialog() {
    double sDay = _startDayFilter.toDouble();
    double eDay = _endDayFilter.toDouble();
    String entitySel = _filterEntity;

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

            // Dropdown chọn bể
            Text(widget.isAquatic ? 'Chọn bể' : 'Chọn chuồng',
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
                  value: entitySel,
                  items: ['Tất cả', ..._currentEntities]
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => entitySel = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // RangeSlider ngày
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
          color: Colors.blue,
          child: const Text("ÁP DỤNG",
              style: TextStyle(color: Colors.white, fontSize: 16)),
          onPressed: () {
            setState(() {
              _filterEntity = entitySel;
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
          title: Text('Báo cáo thức ăn'),
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
          palette: _foodColors.values.toList(),
          title: ChartTitle(
              text:
                  'Khối lượng thức ăn – $_filterEntity (ngày $_startDayFilter–$_endDayFilter)',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: NumericAxis(
              minimum: _startDayFilter.toDouble(),
              maximum: _endDayFilter.toDouble(),
              interval: 1),
          series: _currentFoodTypes.map((foodName) {
            return LineSeries<FeedPoint, int>(
              name: foodName,
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.foodQuantities[foodName],
              markerSettings: const MarkerSettings(isVisible: true),
            );
          }).toList(),
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
                  'Tỷ trọng thức ăn – $_filterEntity ($_startDayFilter–$_endDayFilter)',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            PieSeries<_PieData, String>(
              dataSource: _pie,
              xValueMapper: (d, _) => d.label,
              yValueMapper: (d, _) => d.value,
              pointColorMapper: (d, _) => _foodColors[d.label],
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
