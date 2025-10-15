import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model ---------- */
class HealthPoint {
  final int day;
  final double lengthCm, widthCm, weightKg;
  final int healthRating, fecesRating;
  const HealthPoint(this.day, this.lengthCm, this.widthCm, this.weightKg,
      this.healthRating, this.fecesRating);
}

/* ---------- Screen ---------- */
class HealthReportScreen extends StatefulWidget {
  final bool isAquatic;
  const HealthReportScreen({super.key, required this.isAquatic});
  @override
  State<HealthReportScreen> createState() => _HealthReportScreenState();
}

class _HealthReportScreenState extends State<HealthReportScreen> {
  // Dữ liệu giả định cho các thực thể
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  final List<String> _cages = ['C1', 'C2', 'C3'];
  late final Map<String, List<HealthPoint>> _entityData;
  late final List<String> _currentEntities;

  /* --- Bộ lọc --- */
  late String _filterEntity;
  int _startDay = 1;
  int _endDay = 10;

  @override
  void initState() {
    super.initState();
    // Chọn danh sách thực thể dựa trên isAquatic
    _currentEntities = widget.isAquatic ? _ponds : _cages;
    _filterEntity = _currentEntities.first;
    _entityData = {for (var e in _currentEntities) e: _fakeData(e)};
  }

  /* ---- Fake data (đã thêm cân nặng) ---- */
  List<HealthPoint> _fakeData(String entity) {
    final rnd = Random(entity.hashCode);
    final off = _currentEntities.indexOf(entity) * .5;
    double len = 5 + off;
    double wid = 1.5 + off * .5;
    double weight = 20 + off * 10;
    int hRate = rnd.nextInt(5) - 2;
    int fRate = rnd.nextInt(5) - 2;
    return List.generate(10, (i) {
      if (i > 0) {
        len += rnd.nextDouble() * .4;
        wid += rnd.nextDouble() * .2;
        weight += rnd.nextDouble() * 2;
        hRate = (hRate + rnd.nextInt(3) - 1).clamp(-2, 2);
        fRate = (fRate + rnd.nextInt(3) - 1).clamp(-2, 2);
      }
      return HealthPoint(i + 1, len, wid, weight, hRate, fRate);
    });
  }

  /* ---- Data sau lọc ---- */
  List<HealthPoint> get _dataFiltered => _entityData[_filterEntity]!
      .where((d) => d.day >= _startDay && d.day <= _endDay)
      .toList();

  /* ---------- Hộp thoại lọc ---------- */
  void _showFilterDialog() {
    double sDay = _startDay.toDouble();
    double eDay = _endDay.toDouble();
    String entitySel = _filterEntity;

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

            /* ---- Dropdown chọn thực thể ---- */
            Text(widget.isAquatic ? 'Chọn bể' : 'Chọn chuồng',
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                  items: _currentEntities
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (v) => setStateDialog(() => entitySel = v!),
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
              _filterEntity = entitySel;
              _startDay = sDay.round();
              _endDay = eDay.round();
            });
            Navigator.pop(context);
          },
        ),
      ],
    ).show();
  }

  /* ---------- UI chính ---------- */
  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final chartH = h * .33;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo sức khoẻ'),
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
                _buildSizeChart(chartH),
                const SizedBox(height: 16),
                _buildRatingChart(chartH),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* --- Chart kích thước --- */
  Widget _buildSizeChart(double height) {
    final List<LineSeries<HealthPoint, int>> seriesList = [
      LineSeries<HealthPoint, int>(
        name: 'Chiều dài',
        dataSource: _dataFiltered,
        xValueMapper: (d, _) => d.day,
        yValueMapper: (d, _) => d.lengthCm,
        markerSettings: const MarkerSettings(isVisible: true),
        color: Colors.blue.shade700,
      ),
      LineSeries<HealthPoint, int>(
        name: 'Chiều rộng',
        dataSource: _dataFiltered,
        xValueMapper: (d, _) => d.day,
        yValueMapper: (d, _) => d.widthCm,
        markerSettings: const MarkerSettings(isVisible: true),
        color: Colors.orange.shade600,
      ),
    ];
    // Thêm series cân nặng nếu không phải thủy sản
    if (!widget.isAquatic) {
      seriesList.add(
        LineSeries<HealthPoint, int>(
          name: 'Cân nặng',
          dataSource: _dataFiltered,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.weightKg,
          markerSettings: const MarkerSettings(isVisible: true),
          color: Colors.green.shade700,
        ),
      );
    }
    return Container(
      height: height,
      padding: const EdgeInsets.all(8),
      decoration: _box,
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'Kích thước & Cân nặng (cm/kg) – $_filterEntity',
            textStyle: const TextStyle(fontWeight: FontWeight.bold)),
        legend: Legend(isVisible: true, position: LegendPosition.bottom),
        tooltipBehavior: TooltipBehavior(enable: true),
        primaryXAxis: NumericAxis(
            minimum: _startDay.toDouble(),
            maximum: _endDay.toDouble(),
            interval: 1),
        series: seriesList,
      ),
    );
  }

  /* --- Chart rating --- */
  Widget _buildRatingChart(double height) => Container(
        height: height,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Điểm sức khoẻ – $_filterEntity',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          legend: Legend(isVisible: true, position: LegendPosition.bottom),
          tooltipBehavior: TooltipBehavior(enable: true),
          primaryXAxis: NumericAxis(
              minimum: _startDay.toDouble(),
              maximum: _endDay.toDouble(),
              interval: 1),
          primaryYAxis: NumericAxis(minimum: -2, maximum: 2, interval: 1),
          series: [
            LineSeries<HealthPoint, int>(
              name: 'Tình trạng sức khoẻ',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.healthRating,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.green.shade700,
            ),
            LineSeries<HealthPoint, int>(
              name: 'Tình trạng phân',
              dataSource: _dataFiltered,
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.fecesRating,
              markerSettings: const MarkerSettings(isVisible: true),
              color: Colors.purple.shade600,
            ),
          ],
        ),
      );

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}
