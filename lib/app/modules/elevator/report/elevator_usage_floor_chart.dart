import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';
import 'package:elevator/app/services/reporitories/historical_data_repo.dart';
import 'package:elevator/config/shared/colors.dart';

class ElevatorUsageFloorChart extends StatefulWidget {
  final int registerId;

  const ElevatorUsageFloorChart({Key? key, required this.registerId}) : super(key: key);

  @override
  _ElevatorUsageFloorChartState createState() => _ElevatorUsageFloorChartState();
}

class _ElevatorUsageFloorChartState extends State<ElevatorUsageFloorChart> {
  List<HistoricalData> _historicalData = [];
  Map<int, int> _floorCounts = {};
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  Future<void> _fetchHistoricalData() async {
    try {
      final repo = HistoricalDataRepo();
      // gọi API và lấy về List<HistoricalData>
      final List<HistoricalData> data =
          await repo.getHistoricalDataByRegisterID(id: widget.registerId);
      // tính toán số lần mở/cửa theo tầng
      final Map<int, int> counts = {};
      for (var item in data) {
        if (item.value != null) {
          counts[item.value!] = (counts[item.value!] ?? 0) + 1;
        }
      }

      setState(() {
        _historicalData = data;
        _floorCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Chuyển map thành list chart data
  List<_ChartData> get _chartData {
    return _floorCounts.entries
        .map((e) => _ChartData('Tầng ${e.key}', e.value))
        .toList()
      ..sort((a, b) {
        // sort theo số tầng (tách số ra so sánh)
        final int fa = int.tryParse(a.floor.replaceAll('Tầng ', '')) ?? 0;
        final int fb = int.tryParse(b.floor.replaceAll('Tầng ', '')) ?? 0;
        return fa.compareTo(fb);
      });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Biểu đồ mở cửa tầng"),
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
                              text: "Số lần mở cửa theo tầng",
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            primaryXAxis: CategoryAxis(
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
                                xValueMapper: (_ChartData data, _) => data.floor,
                                yValueMapper: (_ChartData data, _) => data.usage,
                                name: "Số lần mở",
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
  final String floor;
  final int usage;
  _ChartData(this.floor, this.usage);
}
