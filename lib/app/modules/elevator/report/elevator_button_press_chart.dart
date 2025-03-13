import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ElevatorButtonPressChart extends StatefulWidget {
  final BoardDB board;
  const ElevatorButtonPressChart({super.key, required this.board});

  @override
  State<ElevatorButtonPressChart> createState() => _FloorButtonPressChartState();
}

class _FloorButtonPressChartState extends State<ElevatorButtonPressChart> {
  String selectedTimeFrame = 'Ngày';
  final List<String> timeFrames = ['Ngày', 'Tuần', 'Tháng'];

  final Map<String, List<_ChartData>> chartDataByTime = {
    'Ngày': [
      _ChartData("Tầng 1", 30),
      _ChartData("Tầng 2", 45),
      _ChartData("Tầng 3", 60),
      _ChartData("Tầng 4", 25),
      _ChartData("Tầng 5", 35),
    ],
    'Tuần': [
      _ChartData("Tầng 1", 200),
      _ChartData("Tầng 2", 250),
      _ChartData("Tầng 3", 300),
      _ChartData("Tầng 4", 180),
      _ChartData("Tầng 5", 220),
    ],
    'Tháng': [
      _ChartData("Tầng 1", 800),
      _ChartData("Tầng 2", 950),
      _ChartData("Tầng 3", 1200),
      _ChartData("Tầng 4", 750),
      _ChartData("Tầng 5", 890),
    ],
  };

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Số lần nhấn phím theo tầng"),
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
                    text: "Số lần nhấn phím theo tầng",
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
                      name: "Lượt nhấn",
                      color: Colors.redAccent,
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
