import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class ElevatorDistanceChart extends StatefulWidget {
  final BoardDB board;

  const ElevatorDistanceChart({super.key, required this.board});

  @override
  State<ElevatorDistanceChart> createState() => _ElevatorDistanceChartState();
}

class _ElevatorDistanceChartState extends State<ElevatorDistanceChart> {
  String selectedTimeFrame = 'Ngày'; // Mặc định theo ngày
  final List<String> timeFrames = ['Ngày', 'Tuần', 'Tháng'];

  @override
  void initState() {
    super.initState();
    _generateData();
  }

  Map<String, List<_ChartData>> chartDataByTime = {
    'Ngày': [],
    'Tuần': [],
    'Tháng': [],
  };

  void _generateData() {
    final now = DateTime.now();

    // Dữ liệu theo 7 ngày gần nhất
    chartDataByTime['Ngày'] = List.generate(7, (index) {
      DateTime date = now.subtract(Duration(days: index));
      return _ChartData(DateFormat('dd/MM').format(date), (index + 1) * 5);
    }).reversed.toList();

    // Dữ liệu theo 7 tuần gần nhất
    chartDataByTime['Tuần'] = List.generate(7, (index) {
      DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1 + index * 7));
      String weekLabel = 'Tuần ${DateFormat('dd/MM').format(startOfWeek)}';
      return _ChartData(weekLabel, (index + 1) * 20);
    }).reversed.toList();

    // Dữ liệu theo 12 tháng gần nhất
    chartDataByTime['Tháng'] = List.generate(12, (index) {
      DateTime month = DateTime(now.year, now.month - index, 1);
      return _ChartData(DateFormat('MM/yyyy').format(month), (index + 1) * 50);
    }).reversed.toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tổng quãng đường di chuyển"),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(left: 4),
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: DropdownButton<String>(
                value: selectedTimeFrame,
                items: timeFrames.map((String timeFrame) {
                  return DropdownMenuItem<String>(
                    value: timeFrame,
                    child: Text(timeFrame),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedTimeFrame = newValue!;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Center(
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
                    text: "Quãng đường di chuyển theo $selectedTimeFrame",
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  primaryXAxis: CategoryAxis(
                    majorGridLines: const MajorGridLines(width: 0),
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    majorGridLines: const MajorGridLines(dashArray: [5, 5]),
                    labelStyle:
                        const TextStyle(color: Colors.black, fontSize: 12),
                  ),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  series: <CartesianSeries<_ChartData, String>>[
                    ColumnSeries<_ChartData, String>(
                      dataSource: chartDataByTime[selectedTimeFrame]!,
                      xValueMapper: (_ChartData data, _) => data.timeLabel,
                      yValueMapper: (_ChartData data, _) => data.usage,
                      name: "Quãng đường (m)",
                      color: Colors.greenAccent,
                      dataLabelSettings: const DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String timeLabel;
  final int usage;
  _ChartData(this.timeLabel, this.usage);
}
