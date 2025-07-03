import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'energy_setting_screen.dart';

/// ------------------------- DATA MODEL -------------------------
class FlowPoint {
  final DateTime time; // mốc 30-phút
  final double consumption; // kWh tiêu thụ (dương)
  final double solar; // kWh phát từ solar (dưới trục 0)
  FlowPoint(this.time, this.consumption, this.solar);
}

// NEW: model cho cột tổng hợp 7 ngày
class DailyPoint {
  final DateTime day;
  final double sys1;
  final double sys2;
  final double sys3;
  DailyPoint(this.day, this.sys1, this.sys2, this.sys3);
}

//------------------------------------------------------------------
class EnergyReportScreen extends StatefulWidget {
  const EnergyReportScreen({super.key});

  @override
  State<EnergyReportScreen> createState() => _EnergyReportScreenState();
}

class _EnergyReportScreenState extends State<EnergyReportScreen> {
  /* ------------------ STATE ------------------ */
  DateTime _selected = DateTime.now();
  final _rng = Random();
  late List<FlowPoint> _points;

  // NEW: dữ liệu 7 ngày
  late List<DailyPoint> _weekPoints;

  @override
  void initState() {
    super.initState();
    _genDayData();
    _genWeekData();
  }

  /* ------------------ 1. FAKE DATA 1 NGÀY ------------------ */
  void _genDayData() {
    // 48 mốc (30-phút) từ 00:00 tới 23:30
    _points = List.generate(48, (i) {
      final time = DateTime(_selected.year, _selected.month, _selected.day)
          .add(Duration(minutes: 30 * i));

      // tạo profile tiêu thụ dạng sin + nhiễu
      final hour = time.hour + time.minute / 60.0;
      final baseCons = 60 + 40 * (0.5 + 0.5 * (sin((hour - 12) / 24 * 2 * pi)));
      final consumption = baseCons + _rng.nextDouble() * 10;

      // solar chỉ sinh ban ngày (6h-18h)
      double solar = 0;
      if (hour >= 6 && hour <= 18) {
        final norm = (hour - 6) / 12; // 0→1
        solar = 50 * sin(pi * norm) + _rng.nextDouble() * 5;
      }

      return FlowPoint(time, consumption, -solar); // solar âm để vẽ dưới trục
    });
  }

  /* ------------------ 2. FAKE DATA 7 NGÀY ------------------ */
  void _genWeekData() {
    // 7 ngày kết thúc ở _selected (ngày 0 là hôm nay, 6 là 6 ngày trước)
    _weekPoints = List.generate(7, (i) {
      final day = _selected.subtract(Duration(days: 6 - i));

      // tạo số liệu tiêu thụ ngẫu nhiên cho 3 hệ
      double sys1 = 800 + _rng.nextDouble() * 200; // 800-1000
      double sys2 = 900 + _rng.nextDouble() * 250; // 900-1150
      double sys3 = 700 + _rng.nextDouble() * 150; // 700-850

      return DailyPoint(day, sys1, sys2, sys3);
    });
  }

  /* ------------------ UI ------------------ */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo năng lượng'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Thêm vụ nuôi',
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => EnergySettingsScreen(),
                  ));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          // NEW: scroll nếu chiều cao hơi thiếu
          child: Column(
            children: [
              // ---- Hàng hiển thị ngày + nút chọn ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ngày: ${DateFormat('dd/MM/yyyy').format(_selected)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    tooltip: 'Chọn ngày',
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ---- Biểu đồ ENERGY-FLOW ----
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .4,
                padding: const EdgeInsets.all(8),
                decoration: _box,
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Dòng năng lượng trong ngày',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                  primaryXAxis: DateTimeAxis(
                    intervalType: DateTimeIntervalType.hours,
                    dateFormat: DateFormat('HH:mm'),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: .4),
                    axisLine: const AxisLine(width: .7),
                  ),
                  series: [
                    // Tiêu thụ
                    SplineAreaSeries<FlowPoint, DateTime>(
                      name: 'Tiêu thụ',
                      dataSource: _points,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.consumption,
                      borderColor: Colors.red.shade800,
                      borderWidth: 1.2,
                      color: Colors.red.shade600.withOpacity(0.85),
                    ),
                    // Solar (âm)
                    SplineAreaSeries<FlowPoint, DateTime>(
                      name: 'Solar',
                      dataSource: _points,
                      xValueMapper: (p, _) => p.time,
                      yValueMapper: (p, _) => p.solar,
                      borderColor: Colors.green.shade800,
                      borderWidth: 1.2,
                      color: Colors.green.shade600.withOpacity(0.9),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // NEW: Biểu đồ cột tổng tiêu thụ 7 ngày
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * .35,
                padding: const EdgeInsets.all(8),
                decoration: _box,
                child: SfCartesianChart(
                  title: ChartTitle(
                      text: 'Tổng điện tiêu thụ (7 ngày gần nhất)',
                      textStyle: const TextStyle(fontWeight: FontWeight.bold)),
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true, header: ''),
                  primaryXAxis: DateTimeAxis(
                    interval: 1,
                    intervalType: DateTimeIntervalType.days,
                    dateFormat: DateFormat('dd/MM'),
                    majorGridLines: const MajorGridLines(width: 0),
                  ),
                  primaryYAxis: NumericAxis(
                    majorGridLines: const MajorGridLines(width: .4),
                    axisLine: const AxisLine(width: .7),
                  ),
                  series: [
                    ColumnSeries<DailyPoint, DateTime>(
                      name: 'Hệ 1',
                      dataSource: _weekPoints,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.sys1,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: Colors.blue.shade600,
                    ),
                    ColumnSeries<DailyPoint, DateTime>(
                      name: 'Hệ 2',
                      dataSource: _weekPoints,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.sys2,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: Colors.orange.shade600,
                    ),
                    ColumnSeries<DailyPoint, DateTime>(
                      name: 'Hệ 3',
                      dataSource: _weekPoints,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.sys3,
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      color: Colors.green.shade600,
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

  /* ------------------ PICK DATE ------------------ */
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selected) {
      setState(() {
        _selected = picked;
        _genDayData(); // cập nhật biểu đồ ngày
        _genWeekData(); // cập nhật biểu đồ 7 ngày
      });
    }
  }

  /* ------------------ BOX DECORATION ------------------ */
  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      );
}
