import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'report_water_quality_screen.dart'; // có WaterPoint

class FullChartWaterQualityScreen extends StatefulWidget {
  final String title;
  final List<WaterPoint> data;
  const FullChartWaterQualityScreen(
      {super.key, required this.title, required this.data});

  @override
  State<FullChartWaterQualityScreen> createState() =>
      _FullChartWaterQualityScreenState();
}

class _FullChartWaterQualityScreenState
    extends State<FullChartWaterQualityScreen> {
  final _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // lock landscape & ẩn status bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  @override
  void dispose() {
    // restore portrait & status bar
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /* ---- capture & share ---- */
  Future<void> _captureChart() async {
    try {
      final boundary =
          _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3);
      final ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/chart.png')..writeAsBytesSync(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: widget.title);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Lỗi chụp ảnh: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- Biểu đồ ----------
            Center(
              child: RepaintBoundary(
                key: _chartKey,
                child: SfCartesianChart(
                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: NumericAxis(
                      minimum: widget.data.first.day.toDouble(),
                      maximum: widget.data.last.day.toDouble(),
                      interval: 1),
                  axes: [
                    NumericAxis(
                        name: 'phOxy',
                        opposedPosition: true,
                        minimum: 0,
                        maximum: 10,
                        interval: 2),
                  ],
                  title: ChartTitle(
                      text: widget.title,
                      textStyle:
                          const TextStyle(fontSize: 16)),
                  series: [
                    StackedColumnSeries<WaterPoint, int>(
                      name: 'Nước vào',
                      groupName: 'in',
                      dataSource: widget.data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.inL,
                      color: Colors.blue.shade700,
                    ),
                    StackedColumnSeries<WaterPoint, int>(
                      name: 'Nước xả',
                      groupName: 'out',
                      dataSource: widget.data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.outL,
                      color: Colors.orange.shade400,
                    ),
                    LineSeries<WaterPoint, int>(
                      name: 'pH',
                      dataSource: widget.data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.ph,
                      yAxisName: 'phOxy',
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.purple.shade700,
                      width: 2,
                    ),
                    LineSeries<WaterPoint, int>(
                      name: 'Oxy',
                      dataSource: widget.data,
                      xValueMapper: (d, _) => d.day,
                      yValueMapper: (d, _) => d.oxy,
                      yAxisName: 'phOxy',
                      markerSettings: const MarkerSettings(isVisible: true),
                      color: Colors.green.shade700,
                      width: 2,
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Nút back ----------
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // ---------- Nút download ----------
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                tooltip: 'Tải xuống',
                icon: const Icon(Icons.download),
                onPressed: _captureChart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
