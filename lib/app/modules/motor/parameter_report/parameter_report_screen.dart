import 'dart:async';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../../../../config/shared/colors.dart';

enum ViewMode { day, month, year }

class ParameterReportScreen extends StatefulWidget {
  const ParameterReportScreen({super.key});

  @override
  State<ParameterReportScreen> createState() => _ParameterReportScreenState();
}

class _ParameterReportScreenState extends State<ParameterReportScreen> {
  ViewMode _viewMode = ViewMode.month;
  DateTime selectedDate = DateTime.now();
  late List<WaterQualityData> _data;
  bool isConnected = true;
  bool _blink = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _data = _generateDummyData();
    _checkConnection();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isConnected = false;
      _data = _generateDummyData();

      // Bắt đầu hiệu ứng nhấp nháy
      _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          _blink = !_blink;
        });
      });
    });
  }

  List<WaterQualityData> _generateDummyData() {
    List<WaterQualityData> result = [];
    final pattern = [0.5, -0.3, 0.4, -0.2, 0.6, -0.4];
    double oxy = 7.0, pH = 7.2, temp = 27.0;

    switch (_viewMode) {
      case ViewMode.year:
        for (int i = 0; i < 5; i++) {
          final delta = pattern[i % pattern.length];
          oxy += delta;
          pH += delta * 0.2;
          temp += delta * 1.5;
          result.add(WaterQualityData(
            'Thg ${i + 1}',
            double.parse(oxy.toStringAsFixed(2)),
            double.parse(pH.toStringAsFixed(2)),
            double.parse(temp.toStringAsFixed(2)),
          ));
        }
        break;
      case ViewMode.month:
        for (int i = 0; i < 30; i++) {
          final delta = pattern[i % pattern.length];
          oxy += delta;
          pH += delta * 0.2;
          temp += delta * 1.5;
          final date = DateTime(selectedDate.year, selectedDate.month, i + 1);
          result.add(WaterQualityData(
            DateFormat('dd/MM').format(date),
            double.parse(oxy.toStringAsFixed(2)),
            double.parse(pH.toStringAsFixed(2)),
            double.parse(temp.toStringAsFixed(2)),
          ));
        }
        break;
      case ViewMode.day:
        for (int i = 0; i < 48; i++) {
          final delta = pattern[i % pattern.length];
          oxy += delta;
          pH += delta * 0.2;
          temp += delta * 1.5;
          final time = selectedDate.add(Duration(minutes: i * 30));
          result.add(WaterQualityData(
            DateFormat('HH:mm').format(time),
            double.parse(oxy.toStringAsFixed(2)),
            double.parse(pH.toStringAsFixed(2)),
            double.parse(temp.toStringAsFixed(2)),
          ));
        }
        break;
    }

    return result;
  }

  void _updateViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
      _data = _generateDummyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final showDropdown = _viewMode == ViewMode.year ||
        _viewMode == ViewMode.month ||
        _viewMode == ViewMode.day;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo chất lượng nước'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildTabBar(),
            const SizedBox(height: 20),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelStyle:
                      const TextStyle(color: Colors.white, fontSize: 11),
                ),
                title: ChartTitle(
                  text: 'Thông số chất lượng nước',
                  textStyle: const TextStyle(color: Colors.white),
                ),
                legend: Legend(
                  isVisible: true,
                  textStyle: const TextStyle(color: Colors.white),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  LineSeries<WaterQualityData, String>(
                    name: 'Oxy (mg/L)',
                    dataSource: _data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.oxy,
                    color: Colors.blue,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<WaterQualityData, String>(
                    name: 'pH',
                    dataSource: _data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.ph,
                    color: Colors.green,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                  LineSeries<WaterQualityData, String>(
                    name: 'Nhiệt độ (°C)',
                    dataSource: _data,
                    xValueMapper: (d, _) => d.label,
                    yValueMapper: (d, _) => d.temp,
                    color: Colors.redAccent,
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            if (!isConnected)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, color: Colors.redAccent),
                    const SizedBox(width: 6),
                    AnimatedOpacity(
                      opacity: _blink ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 1500),
                      child: const Text(
                        'Không thể kết nối tới máy chủ.',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            if (showDropdown) _buildDropdowns(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdowns() {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: _viewMode == ViewMode.year
              ? DropdownButton<int>(
                  value: selectedDate.year,
                  dropdownColor: Colors.black,
                  underline: Container(),
                  onChanged: (_) {}, // Không thay đổi
                  items: [
                    DropdownMenuItem(
                      value: 2025,
                      child: Text(
                        'Năm 2025',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    )
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_viewMode == ViewMode.month)
                      DropdownButton<int>(
                        value: selectedDate.month,
                        dropdownColor: Colors.black,
                        underline: Container(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedDate = DateTime(selectedDate.year, value);
                              _data = _generateDummyData();
                            });
                          }
                        },
                        items: List.generate(12, (i) {
                          final month = i + 1;
                          return DropdownMenuItem(
                            value: month,
                            child: Text(
                              'Tháng $month',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          );
                        }),
                      ),
                    if (_viewMode == ViewMode.day)
                      DropdownButton<int>(
                        value: selectedDate.day,
                        dropdownColor: Colors.black,
                        underline: Container(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedDate = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                value,
                              );
                              _data = _generateDummyData();
                            });
                          }
                        },
                        items: List.generate(31, (i) {
                          final day = i + 1;
                          return DropdownMenuItem(
                            value: day,
                            child: Text(
                              'Ngày $day',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Năm'),
          selectedColor: Colors.greenAccent,
          backgroundColor: CustomColors.appbarColor,
          selected: _viewMode == ViewMode.year,
          onSelected: (_) => _updateViewMode(ViewMode.year),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Tháng'),
          selectedColor: Colors.greenAccent,
          backgroundColor: CustomColors.appbarColor,
          selected: _viewMode == ViewMode.month,
          onSelected: (_) => _updateViewMode(ViewMode.month),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Ngày'),
          selectedColor: Colors.greenAccent,
          backgroundColor: CustomColors.appbarColor,
          selected: _viewMode == ViewMode.day,
          onSelected: (_) => _updateViewMode(ViewMode.day),
        ),
      ],
    );
  }
}

class WaterQualityData {
  final String label;
  final double oxy;
  final double ph;
  final double temp;

  WaterQualityData(this.label, this.oxy, this.ph, this.temp);
}
