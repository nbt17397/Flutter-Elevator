import 'dart:math';
import 'dart:math' show sin, pi;
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'energy_setting_screen.dart';
import 'fullchart_energy_report_screen.dart';

/* ---------- Data models ---------- */
class FlowPoint {
  final DateTime time;
  final double consumption, solar;
  FlowPoint(this.time, this.consumption, this.solar);
}

/* cho Chart 2: chỉ 2 cột */
class StatPoint {
  final String label;
  final double cons, solar;
  StatPoint(this.label, this.cons, this.solar);
}

enum StatView { month, year, total }

/* ---------- Screen ---------- */
class EnergyReportScreen extends StatefulWidget {
  const EnergyReportScreen({super.key});
  @override
  State<EnergyReportScreen> createState() => _EnergyReportScreenState();
}

class _EnergyReportScreenState extends State<EnergyReportScreen> {
  /* Chart 1 */
  final _rng = Random();
  final DateFormat _fmt = DateFormat('dd/MM/yyyy');
  DateTime _selected = DateTime.now();
  late List<FlowPoint> _points;

  final List<String> _systems = ['Hệ 1', 'Hệ 2', 'Hệ 3'];
  String _sysFilter = 'Hệ 1';

  /* Chart 2 */
  StatView _statView = StatView.month;
  late List<StatPoint> _statPoints;

  @override
  void initState() {
    super.initState();
    _genFlowData();
    _updateStat();
  }

  /* ---------- Fake data cho chart 1 ---------- */
  void _genFlowData() {
    _points = List.generate(48, (i) {
      final t = DateTime(_selected.year, _selected.month, _selected.day)
          .add(Duration(minutes: 30 * i));
      final h = t.hour + t.minute / 60;
      final cons = 60 +
          40 * (0.5 + 0.5 * sin((h - 12) / 24 * 2 * pi)) +
          _rng.nextDouble() * 10;

      double solar = 0;
      if (h >= 6 && h <= 18) {
        final n = (h - 6) / 12;
        solar = 50 * sin(pi * n) + _rng.nextDouble() * 5;
      }
      return FlowPoint(t, cons, solar);
    });
  }

  /* ---------- Fake data cho chart 2 ---------- */
  StatPoint _randStat(String lbl) => StatPoint(
        lbl,
        50 + _rng.nextDouble() * 30, // consumption
        20 + _rng.nextDouble() * 25, // solar
      );

  void _updateStat() {
    switch (_statView) {
      case StatView.month:
        _genMonthData();
        break;
      case StatView.year:
        _genYearData();
        break;
      case StatView.total:
        _genTotalData();
        break;
    }
  }

  void _genMonthData() {
    final days = DateUtils.getDaysInMonth(_selected.year, _selected.month);
    _statPoints = List.generate(days, (i) => _randStat('${i + 1}'));
  }

  void _genYearData() {
    _statPoints = List.generate(12, (i) {
      final lbl = DateFormat.MMM().format(DateTime(0, i + 1));
      return _randStat(lbl);
    });
  }

  void _genTotalData() {
    const years = [2022, 2023, 2024, 2025];
    _statPoints = years.map((y) => _randStat('$y')).toList();
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Báo cáo năng lượng'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Cài đặt',
              onPressed: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => const EnergySettingsScreen())),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildFlowChart(size.height * .3),
                const SizedBox(height: 16),
                _buildStatChart(size.height * .4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /* ---------- Chart 1 (Flow) ---------- */
  Widget _buildFlowChart(double h) => Container(
        height: h,
        decoration: _box,
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            /* ------- Thanh lọc ở đầu khung ------- */
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 18),
                  tooltip: 'Chọn ngày',
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  onPressed: _pickDate,
                ),
                Text(_fmt.format(_selected),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black54),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isDense: true,
                      value: _sysFilter,
                      items: _systems
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s,
                                    style: const TextStyle(fontSize: 13)),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _sysFilter = v!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            /* ------- Biểu đồ chiếm phần còn lại ------- */
            Expanded(
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.hours,
                  dateFormat: DateFormat('HH:mm'),
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  minimum: -120,
                  maximum: 120,
                  interval: 20,
                  majorGridLines: const MajorGridLines(width: .4),
                  axisLine: const AxisLine(width: .7),
                ),
                series: [
                  SplineAreaSeries<FlowPoint, DateTime>(
                      name: 'Tiêu thụ',
                      dataSource: _points,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.consumption,
                      borderColor: Colors.red.shade800,
                      borderWidth: 1.2,
                      color: Color(0xFFCC0000)),
                  SplineAreaSeries<FlowPoint, DateTime>(
                      name: 'Solar',
                      isVisibleInLegend: false,
                      dataSource: _points,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.solar,
                      borderColor: Color(0xFFCCE609),
                      borderWidth: 1.2,
                      color: Color(0xFFCCE609)),
                  SplineAreaSeries<FlowPoint, DateTime>(
                      name: 'Solar',
                      dataSource: _points,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => -p.solar,
                      borderColor: Color(0xFFCCE609),
                      borderWidth: 1.2,
                      color: Color(0xFFCCE609)),
                ],
              ),
            ),
          ],
        ),
      );

  /* ---------- Chart 2 ---------- */
  Widget _buildStatChart(double h) => Container(
        height: h,
        decoration: _box,
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
        child: Column(
          children: [
            Align(alignment: Alignment.center, child: _buildSegment()),
            const SizedBox(height: 4),
            Expanded(
              child: SfCartesianChart(
                legend:
                    Legend(isVisible: true, position: LegendPosition.bottom),
                // Bật tooltip để show data khi tap
                tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                primaryXAxis: CategoryAxis(
                  majorGridLines: const MajorGridLines(width: 0),
                ),
                primaryYAxis: NumericAxis(
                  majorGridLines: const MajorGridLines(width: .4),
                  axisLine: const AxisLine(width: .7),
                ),
                series: <StackedColumnSeries>[
                  StackedColumnSeries<StatPoint, String>(
                      name: 'Solar',
                      dataSource: _statPoints,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.solar,
                      color: Color(0xFFCCE609)),
                  StackedColumnSeries<StatPoint, String>(
                      name: 'Tiêu thụ',
                      dataSource: _statPoints,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.cons,
                      color: Color(0xFFCC0000)),
                ],
              ),
            ),
          ],
        ),
      );

  /* ---------- segmented + dropdown ---------- */
  Widget _buildSegment() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            tooltip: 'Mở rộng',
            icon: const Icon(Icons.open_in_full, size: 18),
            splashRadius: 18,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullChartEnergyReportScreen(
                    statPoints: _statPoints,
                    statView: _statView,
                    sysFilter: _sysFilter,
                  ),
                ),
              );
            },
          ),
          /* --- Thanh chọn Month / Year / Total --- */
          CupertinoSlidingSegmentedControl<StatView>(
            groupValue: _statView,
            children: const {
              StatView.month: Text('Tháng'),
              StatView.year: Text('Năm'),
              StatView.total: Text('Tất cả'),
            },
            onValueChanged: (v) {
              setState(() {
                _statView = v!;
                _updateStat();
              });
            },
          ),
          const SizedBox(width: 12),

          /* --- Dropdown chọn hệ --- */
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: _sysFilter, // biến state đã có
                items: _systems
                    .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _sysFilter = v!),
              ),
            ),
          ),
        ],
      );

  /* ---------- Pick date ---------- */
  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null && d != _selected) {
      setState(() => _selected = d);
      _genFlowData();
      if (_statView == StatView.month) _updateStat();
    }
  }

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}
