import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/batch/water_quality/fullchart_report_water_quality_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* ---------- Model cho dữ liệu Thật (isTest=false) ---------- */
class WaterPoint {
  final int day;
  final double inL, outL, ph, oxy;
  final double rating;
  const WaterPoint(
      this.day, this.inL, this.outL, this.rating, this.ph, this.oxy);
}

class AirPoint {
  final int day;
  final int rating;
  final double co2, airflow;
  AirPoint(this.day, this.rating, this.co2, this.airflow);
}

/* ---------- Model cho Dữ liệu TEST (isTest=true) ---------- */
class TestWaterPoint {
  // Key: day number, week number, or hour number
  final num x;
  // Nhiệt độ (C)
  final double temp;
  // Nồng độ Oxy (mg/l) - thường là DO
  final double doMgL;
  // Hàm lượng Oxy (% bão hòa)
  final double doSat;
  // Thời điểm đầy đủ
  final DateTime time;

  const TestWaterPoint(this.x, this.temp, this.doMgL, this.doSat, this.time);
}

/* ---------- Screen ---------- */
class WaterQualityReportScreen extends StatefulWidget {
  final bool isAquatic;
  final bool isTest;
  const WaterQualityReportScreen(
      {super.key, required this.isAquatic, required this.isTest});

  @override
  State<WaterQualityReportScreen> createState() =>
      _WaterQualityReportScreenState();
}

class _WaterQualityReportScreenState extends State<WaterQualityReportScreen> {
  final List<String> _ponds = ['P1', 'P2', 'P3', 'P4'];
  final List<String> _cages = ['C1', 'C2', 'C3'];
  late final Map<String, dynamic> _entityData;
  late final List<String> _currentEntities;

  /* --- bộ lọc --- */
  late String _filterEntity;
  late List<dynamic> _fullTestData;

  // Lọc cũ cho isTest=false
  int _startDay = 1;
  int _endDay = 10;

  // Lọc mới cho isTest=true
  String _timeRange = 'Ngày'; // 'Giờ', 'Ngày', 'Tuần'
  DateTime _selectedDate = DateTime.now();
  int _selectedWeek = 1;

  @override
  void initState() {
    super.initState();
    _currentEntities = widget.isAquatic ? _ponds : _cages;
    _filterEntity = _currentEntities.first;

    if (widget.isTest) {
      // Dữ liệu giả lập TEST (Thủy sản)
      _fullTestData = _fakeTestData();
      // Khởi tạo entity data dựa trên dữ liệu test chung
      _entityData = {for (var e in _currentEntities) e: _fullTestData};
      // Ngày kết thúc mặc định là ngày hiện tại (nếu lọc theo Ngày/Tuần)
      _selectedDate =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    } else {
      // Dữ liệu giả lập THẬT (WaterPoint/AirPoint)
      _entityData = {for (var e in _currentEntities) e: _fakeData(e)};
    }
  }

  /* ---------- Giả lập dữ liệu cho chế độ TEST (1 data point mỗi giờ trong 7 ngày) ---------- */
  List<dynamic> _fakeTestData() {
    if (!widget.isAquatic) return []; // Chỉ áp dụng cho Aquatic

    final List<TestWaterPoint> data = [];
    final Random rnd = Random(123); // Seed cố định cho dữ liệu test
    final now = DateTime.now();

    // Tạo dữ liệu cho 7 ngày (168 giờ)
    final DateTime start = now.subtract(const Duration(days: 7));

    double baseTemp = 28.0;
    double baseDoMgL = 5.5;
    double baseDoSat = 80.0;

    for (int i = 0; i < 168; i++) {
      final DateTime time = start.add(Duration(hours: i));

      // Biến động nhỏ theo giờ
      baseTemp += (rnd.nextDouble() - 0.5) * 0.2; // +- 0.1 C
      baseDoMgL += (rnd.nextDouble() - 0.5) * 0.1; // +- 0.05 mg/l
      baseDoSat += (rnd.nextDouble() - 0.5) * 0.5; // +- 0.25 %

      // Giới hạn giá trị
      baseTemp = baseTemp.clamp(27.0, 30.0);
      baseDoMgL = baseDoMgL.clamp(4.0, 6.5);
      baseDoSat = baseDoSat.clamp(70.0, 90.0);

      data.add(TestWaterPoint(
        i + 1, // X ban đầu là số giờ
        double.parse(baseTemp.toStringAsFixed(2)),
        double.parse(baseDoMgL.toStringAsFixed(2)),
        double.parse(baseDoSat.toStringAsFixed(2)),
        time,
      ));
    }

    return data;
  }

  /* ---------- Giả lập dữ liệu cho chế độ THẬT (isTest=false) ---------- */
  dynamic _fakeData(String entity) {
    final rnd = Random(entity.hashCode);
    final off = _currentEntities.indexOf(entity) * 10;

    if (widget.isAquatic) {
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
    } else {
      int rating = rnd.nextInt(5) - 2;
      double co2 = 400 + rnd.nextInt(200).toDouble();
      double airflow = 100 + rnd.nextInt(50).toDouble();
      return List.generate(10, (i) {
        if (i > 0) {
          rating = (rating + rnd.nextInt(3) - 1).clamp(-2, 2);
          co2 += (rnd.nextDouble() - 0.5) * 5;
          airflow += (rnd.nextDouble() - 0.5) * 10;
        }
        return AirPoint(i + 1, rating, co2, airflow);
      });
    }
  }

  /* ---------- Dữ liệu sau lọc ---------- */
  List<dynamic> get _dataFiltered {
    if (widget.isTest) {
      if (_timeRange == 'Giờ') {
        // Lọc theo Ngày (24 điểm/giờ)
        return (_entityData[_filterEntity] as List<TestWaterPoint>)
            .where((d) =>
                d.time.day == _selectedDate.day &&
                d.time.month == _selectedDate.month)
            .toList()
            .map((d) => TestWaterPoint(
                d.time.hour, d.temp, d.doMgL, d.doSat, d.time)) // x là giờ
            .toList();
      } else if (_timeRange == 'Tuần') {
        // Lọc theo Tuần (7 điểm/ngày) - Lấy trung bình ngày cho đơn giản
        // Giả sử dữ liệu test chỉ có 7 ngày, nên ta chỉ hiển thị 7 ngày cuối
        final List<TestWaterPoint> allData =
            _entityData[_filterEntity].cast<TestWaterPoint>();
        final Map<int, List<TestWaterPoint>> groupedByDay = {};
        for (var point in allData) {
          final day = point.time.difference(allData.first.time).inDays + 1;
          groupedByDay.putIfAbsent(day, () => []).add(point);
        }
        return groupedByDay.entries.map((e) {
          final avgTemp =
              e.value.map((p) => p.temp).reduce((a, b) => a + b) / e.value.length;
          final avgDoMgL = e.value.map((p) => p.doMgL).reduce((a, b) => a + b) /
              e.value.length;
          final avgDoSat = e.value.map((p) => p.doSat).reduce((a, b) => a + b) /
              e.value.length;

          return TestWaterPoint(
            e.key, // X là Ngày
            double.parse(avgTemp.toStringAsFixed(2)),
            double.parse(avgDoMgL.toStringAsFixed(2)),
            double.parse(avgDoSat.toStringAsFixed(2)),
            e.value.first.time, // Lấy thời gian đầu ngày
          );
        }).toList();
      } else {
        // Lọc theo Ngày (7 điểm/ngày) - Mặc định cho chế độ Ngày/Tuần
        final List<TestWaterPoint> allData =
            _entityData[_filterEntity].cast<TestWaterPoint>();
        final Map<int, List<TestWaterPoint>> groupedByDay = {};
        for (var point in allData) {
          final day = point.time.difference(allData.first.time).inDays + 1;
          groupedByDay.putIfAbsent(day, () => []).add(point);
        }
        return groupedByDay.entries.map((e) {
          final avgTemp =
              e.value.map((p) => p.temp).reduce((a, b) => a + b) / e.value.length;
          final avgDoMgL = e.value.map((p) => p.doMgL).reduce((a, b) => a + b) /
              e.value.length;
          final avgDoSat = e.value.map((p) => p.doSat).reduce((a, b) => a + b) /
              e.value.length;

          return TestWaterPoint(
            e.key, // X là Ngày
            double.parse(avgTemp.toStringAsFixed(2)),
            double.parse(avgDoMgL.toStringAsFixed(2)),
            double.parse(avgDoSat.toStringAsFixed(2)),
            e.value.first.time,
          );
        }).toList();
      }
    } else {
      // Logic lọc cũ (isTest=false)
      return (_entityData[_filterEntity] as List<dynamic>)
          .where((d) => d.day >= _startDay && d.day <= _endDay)
          .toList();
    }
  }

  /* ---------- Hộp thoại lọc ---------- */
  void _showFilterDialog() {
    double sDay = _startDay.toDouble();
    double eDay = _endDay.toDouble();
    String entitySel = _filterEntity;

    String timeRangeSel = _timeRange;
    DateTime dateSel = _selectedDate;

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

            /* ---- Bể/Chuồng ---- */
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

            /* ---- Bộ lọc Ngày/Tuần (cho chế độ Test) ---- */
            if (widget.isTest) ...[
              const Text('Phạm vi dữ liệu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: ['Giờ', 'Ngày', 'Tuần'].map((range) {
                  return ChoiceChip(
                    label: Text(range),
                    selected: timeRangeSel == range,
                    selectedColor: CustomColors.appbarColor.withOpacity(0.8),
                    onSelected: (selected) {
                      if (selected) {
                        setStateDialog(() => timeRangeSel = range);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              if (timeRangeSel == 'Giờ')
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dateSel,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 7)),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setStateDialog(() => dateSel = picked);
                    }
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            'Chọn ngày: ${dateSel.day}/${dateSel.month}/${dateSel.year}'),
                        const Icon(Icons.calendar_today, size: 20),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
            ] else ...[
              /* ---- Khoảng ngày (cho chế độ Thật cũ) ---- */
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
            ]
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
              if (widget.isTest) {
                _timeRange = timeRangeSel;
                _selectedDate = dateSel;
              } else {
                _startDay = sDay.round();
                _endDay = eDay.round();
              }
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
    final chartH = h * 0.3;

    String subtitle = widget.isTest
        ? '$_filterEntity | ${_timeRange == 'Giờ' ? 'Ngày ${_selectedDate.day}/${_selectedDate.month}' : _timeRange}'
        : '$_filterEntity | Ngày $_startDay–$_endDay';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.isAquatic
              ? 'Báo cáo chất lượng nước'
              : 'Báo cáo chất lượng không khí'),
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
                if (widget.isTest) ...[
                  // Biểu đồ TEST: Nhiệt độ, DO (mg/l)
                  _buildTestWaterChart(h * .6, subtitle),
                ] else if (widget.isAquatic) ...[
                  // Biểu đồ THẬT (cũ): Nước vào/xả, pH, Oxy
                  _buildWaterQualityChart(chartH, subtitle),
                  const SizedBox(height: 16),
                  _buildWaterRatingChart(h * 0.25, subtitle),
                ] else ...[
                  // Biểu đồ THẬT (cũ): Chất lượng không khí
                  _buildAirQualityChart(chartH, subtitle),
                  const SizedBox(height: 16),
                  _buildCo2Chart(chartH, subtitle),
                  const SizedBox(height: 16),
                  _buildAirflowChart(chartH, subtitle),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ======================================= */
  /* ---------- Biểu đồ CHẾ ĐỘ TEST ---------- */
  /* ======================================= */

  Widget _buildTestWaterChart(double h, String subtitle) {
    String xTitle = _timeRange == 'Giờ'
        ? 'Giờ (h)'
        : _timeRange == 'Ngày'
            ? 'Ngày (Day)'
            : 'Ngày (Day)'; // Dữ liệu tuần cũng hiển thị theo ngày

    return Stack(
      children: [
        Container(
          height: h,
          padding: const EdgeInsets.all(8),
          decoration: _box,
          child: SfCartesianChart(
            title: ChartTitle(
                text: 'Chất lượng nước • $subtitle',
                textStyle: const TextStyle(fontWeight: FontWeight.bold)),
            legend: Legend(isVisible: true, position: LegendPosition.bottom),
            tooltipBehavior: TooltipBehavior(enable: true),
            primaryXAxis: NumericAxis(
              title: AxisTitle(text: xTitle),
              // Nếu là giờ, interval là 1, nếu là ngày/tuần, interval tùy thuộc số ngày
              interval: _timeRange == 'Giờ' ? 1 : null,
              minimum: _dataFiltered.isEmpty
                  ? 0
                  : _dataFiltered.first.x.toDouble(),
              maximum:
                  _dataFiltered.isEmpty ? 24 : _dataFiltered.last.x.toDouble(),
            ),
            axes: [
              // Axis Y bên trái: Nhiệt độ (°C)
              NumericAxis(
                name: 'TempAxis',
                // title: const AxisTitle(text: 'Nhiệt độ (°C)'),
                minimum: 25, // Điều chỉnh min/max thực tế hơn
                maximum: 35,
                interval: 5,
              ),
              // Axis Y bên phải (Đối diện): Nồng độ Oxy (mg/l)
              NumericAxis(
                name: 'DoMgLAxis',
                // title: const AxisTitle(text: 'Nồng độ O₂ (mg/l)'),
                opposedPosition: true,
                minimum: 0,
                maximum: 10, // Phạm vi điển hình cho DO
                interval: 2,
              ),
            ],
            series: [
              // 1. Nhiệt độ (Temp) - Dùng trục TempAxis (bên trái)
              LineSeries<TestWaterPoint, num>(
                name: 'Nhiệt độ (°C)',
                dataSource: _dataFiltered.cast<TestWaterPoint>(),
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.temp,
                yAxisName: 'TempAxis',
                markerSettings:
                    const MarkerSettings(isVisible: true, width: 6, height: 6),
                color: Colors.red.shade700,
                width: 2,
              ),
              // 2. Nồng độ Oxy (DO mg/l) - Dùng trục DoMgLAxis (bên phải)
              LineSeries<TestWaterPoint, num>(
                name: 'Nồng độ O₂ (mg/l)',
                dataSource: _dataFiltered.cast<TestWaterPoint>(),
                xValueMapper: (d, _) => d.x,
                yValueMapper: (d, _) => d.doMgL,
                yAxisName: 'DoMgLAxis',
                markerSettings:
                    const MarkerSettings(isVisible: true, width: 6, height: 6),
                color: Colors.blue.shade700,
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
                    title: '$_filterEntity • Phạm vi: $_timeRange',
                    data: _dataFiltered.cast<TestWaterPoint>(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /* ======================================= */
  /* ---------- Biểu đồ CHẾ ĐỘ THẬT CŨ ---------- */
  /* ======================================= */

  /* ---------- Chart Chất lượng nước (Cũ - isTest=false) ---------- */
  Widget _buildWaterQualityChart(double h, String subtitle) => Stack(
        children: [
          Container(
            height: h,
            padding: const EdgeInsets.all(8),
            decoration: _box,
            child: SfCartesianChart(
              title: ChartTitle(
                  text: 'Nước vào / Nước xả & pH, Oxy – $_filterEntity',
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
                  dataSource: _dataFiltered.cast<WaterPoint>(),
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.inL,
                  color: Colors.blue.shade700,
                ),
                StackedColumnSeries<WaterPoint, int>(
                  name: 'Nước xả',
                  groupName: 'out',
                  dataSource: _dataFiltered.cast<WaterPoint>(),
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.outL,
                  color: Colors.orange.shade400,
                ),
                LineSeries<WaterPoint, int>(
                  name: 'pH',
                  dataSource: _dataFiltered.cast<WaterPoint>(),
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.ph,
                  yAxisName: 'phOxy',
                  markerSettings:
                      const MarkerSettings(isVisible: true, width: 6, height: 6),
                  color: Colors.purple.shade700,
                  width: 2,
                ),
                LineSeries<WaterPoint, int>(
                  name: 'Oxy',
                  dataSource: _dataFiltered.cast<WaterPoint>(),
                  xValueMapper: (d, _) => d.day,
                  yValueMapper: (d, _) => d.oxy,
                  yAxisName: 'phOxy',
                  markerSettings:
                      const MarkerSettings(isVisible: true, width: 6, height: 6),
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
                      title: '$_filterEntity • Ngày $_startDay–$_endDay',
                      data: _dataFiltered.cast<WaterPoint>(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );

  Widget _buildWaterRatingChart(double h, String subtitle) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Điểm chất lượng nước – $_filterEntity',
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
              dataSource: _dataFiltered.cast<WaterPoint>(),
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.rating,
              markerSettings:
                  const MarkerSettings(isVisible: true, width: 6, height: 6),
              color: Colors.red.shade700,
            ),
          ],
        ),
      );

  /* ---------- Chart Chất lượng không khí (Cũ - isTest=false) ---------- */
  Widget _buildAirQualityChart(double h, String subtitle) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Điểm chất lượng không khí – $_filterEntity',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          primaryXAxis: NumericAxis(
              minimum: _startDay.toDouble(),
              maximum: _endDay.toDouble(),
              interval: 1),
          primaryYAxis: NumericAxis(minimum: -2, maximum: 2, interval: 1),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            LineSeries<AirPoint, int>(
              name: 'Điểm',
              dataSource: _dataFiltered.cast<AirPoint>(),
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.rating,
              markerSettings:
                  const MarkerSettings(isVisible: true, width: 6, height: 6),
              color: Colors.blue.shade700,
            ),
          ],
        ),
      );

  Widget _buildCo2Chart(double h, String subtitle) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Nồng độ CO2 – $_filterEntity',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          primaryXAxis: NumericAxis(
              minimum: _startDay.toDouble(),
              maximum: _endDay.toDouble(),
              interval: 1),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            LineSeries<AirPoint, int>(
              name: 'Nồng độ CO2',
              dataSource: _dataFiltered.cast<AirPoint>(),
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.co2,
              markerSettings:
                  const MarkerSettings(isVisible: true, width: 6, height: 6),
              color: Colors.red.shade700,
            ),
          ],
        ),
      );

  Widget _buildAirflowChart(double h, String subtitle) => Container(
        height: h,
        padding: const EdgeInsets.all(8),
        decoration: _box,
        child: SfCartesianChart(
          title: ChartTitle(
              text: 'Lưu lượng gió – $_filterEntity',
              textStyle: const TextStyle(fontWeight: FontWeight.bold)),
          primaryXAxis: NumericAxis(
              minimum: _startDay.toDouble(),
              maximum: _endDay.toDouble(),
              interval: 1),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            LineSeries<AirPoint, int>(
              name: 'Lưu lượng gió',
              dataSource: _dataFiltered.cast<AirPoint>(),
              xValueMapper: (d, _) => d.day,
              yValueMapper: (d, _) => d.airflow,
              markerSettings:
                  const MarkerSettings(isVisible: true, width: 6, height: 6),
              color: Colors.green.shade700,
            ),
          ],
        ),
      );

  BoxDecoration get _box => BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      );
}