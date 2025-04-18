import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';
import 'package:elevator/app/services/reporitories/historical_data_repo.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:elevator/app/data/response/location_response.dart';

class ElevatorTemperatureChart extends StatefulWidget {
  final int registerId;
  const ElevatorTemperatureChart({Key? key, required this.registerId}) : super(key: key);

  @override
  _ElevatorTemperatureChartState createState() => _ElevatorTemperatureChartState();
}

class _ElevatorTemperatureChartState extends State<ElevatorTemperatureChart> {
  List<_ChartData> _chartData = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final DateFormat _timeFormatter = DateFormat('HH:mm dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchTemperatureData();
  }

  Future<void> _fetchTemperatureData() async {
    try {
      final repo = HistoricalDataRepo();
      final List<HistoricalData> data =
          await repo.getHistoricalDataByRegisterID(id: widget.registerId);

      // Chuyển thành _ChartData, lọc các bản ghi có value và timestamp
      final list = data
          .where((e) => e.value != null && e.timestamp != null)
          .map((e) {
            final dt = DateTime.tryParse(e.timestamp!);
            return _ChartData(
              date: dt ?? DateTime.now(),
              label: dt != null ? _timeFormatter.format(dt) : '',
              value: e.value!.toDouble(),
            );
          })
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      setState(() {
        _chartData = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhiệt độ thang máy'),
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      'Lỗi: $_errorMessage',
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  )
                : _chartData.isEmpty
                    ? const Center(
                        child: Text(
                          'Không có dữ liệu nhiệt độ.',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      )
                    : Center(
                        child: Container(
                          width: size.width * 0.9,
                          height: size.height * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SfCartesianChart(
                            title: ChartTitle(
                              text: 'Biểu đồ nhiệt độ theo thời gian',
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            primaryXAxis: CategoryAxis(
                              labelRotation: 45,
                              majorGridLines: const MajorGridLines(width: 0),
                              labelStyle:
                                  const TextStyle(color: Colors.black, fontSize: 12),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0,
                              majorGridLines:
                                  const MajorGridLines(dashArray: [5, 5]),
                              labelStyle:
                                  const TextStyle(color: Colors.black, fontSize: 12),
                              title: AxisTitle(text: 'Nhiệt độ (°C)'),
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<_ChartData, String>>[
                              LineSeries<_ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (_ChartData data, _) => data.label,
                                yValueMapper: (_ChartData data, _) => data.value,
                                name: 'Nhiệt độ',
                                markerSettings: const MarkerSettings(isVisible: true),
                                dataLabelSettings: const DataLabelSettings(isVisible: false),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }
}

class _ChartData {
  final DateTime date;
  final String label;
  final double value;
  _ChartData({required this.date, required this.label, required this.value});
}
