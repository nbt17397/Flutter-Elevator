import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../config/shared/colors.dart';

enum ViewMode { day, month, year }

class EnergyReportScreen extends StatefulWidget {
  const EnergyReportScreen({super.key});

  @override
  State<EnergyReportScreen> createState() => _EnergyReportScreenState();
}

class _EnergyReportScreenState extends State<EnergyReportScreen> {
  ViewMode _viewMode = ViewMode.month;

  late List<EnergyData> _data;

  @override
  void initState() {
    super.initState();
    _data = _generateDummyData();
  }

  List<EnergyData> _generateDummyData() {
    double baseValue;
    int count;
    String Function(int) labelBuilder;

    switch (_viewMode) {
      case ViewMode.day:
        baseValue = 15;
        count = 30;
        labelBuilder = (i) => '${i + 1}';
        break;
      case ViewMode.month:
        baseValue = 200;
        count = 12;
        labelBuilder = (i) => 'Thg ${i + 1}';
        break;
      case ViewMode.year:
        baseValue = 800;
        count = 5;
        labelBuilder = (i) => '${2020 + i}';
        break;
    }

    final List<EnergyData> result = [];
    double current = baseValue;
    final List<double> pattern = [5, -3, 4, -2, 6, -4]; // Dao động mẫu cố định

    for (int i = 0; i < count; i++) {
      final delta = pattern[i % pattern.length];
      current += delta;
      result.add(EnergyData(
        labelBuilder(i),
        double.parse(current.toStringAsFixed(1)),
      ));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Màn hình năng lượng'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
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
            const SizedBox(height: 28),
            Expanded(
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Lịch sử điện năng tiêu thụ'),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<EnergyData, String>(
                    dataSource: _data,
                    xValueMapper: (EnergyData data, _) => data.label,
                    yValueMapper: (EnergyData data, _) => data.kwh,
                    name: 'kWh',
                    color: const Color.fromARGB(255, 243, 94, 25),
                    borderRadius: BorderRadius.circular(4),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                  LineSeries<EnergyData, String>(
                    name: 'Đường tham chiếu',
                    dataSource:
                        _generateDummyData(), // hoặc danh sách khác nếu muốn
                    xValueMapper: (EnergyData data, _) => data.label,
                    yValueMapper: (EnergyData data, _) => data.kwh,
                    markerSettings: MarkerSettings(isVisible: true),
                    dataLabelSettings: DataLabelSettings(isVisible: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
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
          backgroundColor: CustomColors.appbarColor,
          selectedColor: Colors.greenAccent,
          selected: _viewMode == ViewMode.month,
          onSelected: (_) => _updateViewMode(ViewMode.month),
        ),
        const SizedBox(width: 10),
        ChoiceChip(
          label: const Text('Ngày'),
          selected: _viewMode == ViewMode.day,
          backgroundColor: CustomColors.appbarColor,
          selectedColor: Colors.greenAccent,
          onSelected: (_) => _updateViewMode(ViewMode.day),
        ),
      ],
    );
  }

  void _updateViewMode(ViewMode mode) {
    setState(() {
      _viewMode = mode;
      _data = _generateDummyData();
    });
  }
}

class EnergyData {
  final String label;
  final double kwh;

  EnergyData(this.label, this.kwh);
}
