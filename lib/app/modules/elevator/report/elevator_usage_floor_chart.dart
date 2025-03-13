import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ElevatorUsageFloorChart extends StatefulWidget {
  final BoardDB board;

  const ElevatorUsageFloorChart({super.key, required this.board});

  @override
  State<ElevatorUsageFloorChart> createState() =>
      _ElevatorUsageFloorChartState();
}

class _ElevatorUsageFloorChartState extends State<ElevatorUsageFloorChart> {
  String selectedTimeFrame = 'Ngày'; // Mặc định theo ngày
  final List<String> timeFrames = ['Ngày', 'Tuần', 'Tháng', 'Năm'];

  final Map<String, List<_ChartData>> chartDataByTime = {
    'Ngày': [
      _ChartData("Tầng 1", 10),
      _ChartData("Tầng 2", 15),
      _ChartData("Tầng 3", 25),
      _ChartData("Tầng 4", 30),
      _ChartData("Tầng 5", 12),
    ],
    'Tuần': [
      _ChartData("Tầng 1", 70),
      _ChartData("Tầng 2", 75),
      _ChartData("Tầng 3", 125),
      _ChartData("Tầng 4", 130),
      _ChartData("Tầng 5", 112),
    ],
    'Tháng': [
      _ChartData("Tầng 1", 100),
      _ChartData("Tầng 2", 150),
      _ChartData("Tầng 3", 250),
      _ChartData("Tầng 4", 300),
      _ChartData("Tầng 5", 120),
    ],
    'Năm': [
      _ChartData("Tầng 1", 1000),
      _ChartData("Tầng 2", 1500),
      _ChartData("Tầng 3", 2500),
      _ChartData("Tầng 4", 3000),
      _ChartData("Tầng 5", 1200),
    ],
  };

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Biểu đồ đóng/mở cửa tầng"),
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
                    text: "Số lần đóng/mở cửa theo tầng",
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
                      xValueMapper: (_ChartData data, _) => data.floor,
                      yValueMapper: (_ChartData data, _) => data.usage,
                      name: "Lượt đóng/mở",
                      color: Colors.blueAccent,
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
  final String floor;
  final int usage;
  _ChartData(this.floor, this.usage);
}
