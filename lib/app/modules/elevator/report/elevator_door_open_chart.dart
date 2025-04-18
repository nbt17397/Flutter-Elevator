import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';
import 'package:elevator/app/services/reporitories/historical_data_repo.dart';
import 'package:elevator/config/shared/colors.dart';

class ElevatorDoorOpenChart extends StatefulWidget {
  final int registerId;

  const ElevatorDoorOpenChart({Key? key, required this.registerId}) : super(key: key);

  @override
  _ElevatorDoorOpenChartState createState() => _ElevatorDoorOpenChartState();
}

class _ElevatorDoorOpenChartState extends State<ElevatorDoorOpenChart> {
  List<HistoricalData> _historicalData = [];
  Map<String, int> _dateCounts = {};
  bool _isLoading = true;
  String _errorMessage = '';

  final DateFormat _dayFormatter = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fetchAndGroupByDate();
  }

  Future<void> _fetchAndGroupByDate() async {
    try {
      final repo = HistoricalDataRepo();
      final List<HistoricalData> data =
          await repo.getHistoricalDataByRegisterID(id: widget.registerId);

      // Group by day
      final Map<String, int> counts = {};
      for (var item in data) {
        if (item.timestamp != null) {
          final dt = DateTime.tryParse(item.timestamp!);
          if (dt != null) {
            final key = _dayFormatter.format(dt);
            counts[key] = (counts[key] ?? 0) + 1;
          }
        }
      }

      setState(() {
        _historicalData = data;
        _dateCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<_ChartData> get _chartData {
    // Convert map entries to list and sort by actual date
    final entries = _dateCounts.entries
        .map((e) {
          final dt = _dayFormatter.parse(e.key);
          return _ChartData(date: dt, label: e.key, count: e.value);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Biểu đồ số lần mở cửa theo ngày"),
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
                          'Không có dữ liệu.',
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
                              text: "Số lần mở cửa theo ngày",
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            primaryXAxis: CategoryAxis(
                              interval: 1,
                              labelRotation: 45,
                              majorGridLines: const MajorGridLines(width: 0),
                              labelStyle: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                            primaryYAxis: NumericAxis(
                              minimum: 0,
                              majorGridLines:
                                  const MajorGridLines(dashArray: [5, 5]),
                              labelStyle: const TextStyle(
                                  color: Colors.black, fontSize: 12),
                            ),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: <CartesianSeries<_ChartData, String>>[
                              ColumnSeries<_ChartData, String>(
                                dataSource: _chartData,
                                xValueMapper: (_ChartData data, _) =>
                                    data.label,
                                yValueMapper: (_ChartData data, _) =>
                                    data.count,
                                name: "Lượt mở",
                                dataLabelSettings: const DataLabelSettings(
                                  isVisible: true,
                                  textStyle: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
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
  final int count;
  _ChartData({
    required this.date,
    required this.label,
    required this.count,
  });
}
