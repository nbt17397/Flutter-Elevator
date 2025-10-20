import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';
// Import model WaterPoint từ file gốc của bạn
import 'report_water_quality_screen.dart'; 

/* * Định nghĩa lại TestWaterPoint ở đây để đảm bảo code hoạt động 
 * do nó chưa có trong file này. 
 * Trong dự án thực tế, bạn chỉ cần IMPORT nó.
 */

// Model giả định cho chế độ Test
class TestWaterPoint {
  final num x;
  final double temp;
  final double doMgL;
  final double doSat;
  final DateTime time;
  const TestWaterPoint(this.x, this.temp, this.doMgL, this.doSat, this.time);
}
// END MOCK TESTWATERPOINT

class FullChartWaterQualityScreen extends StatefulWidget {
  final String title;
  // Sửa đổi: Chấp nhận List<dynamic> để linh hoạt với WaterPoint hoặc TestWaterPoint
  final List<dynamic> data; 
  final bool isTestMode; // Thêm cờ để phân biệt dữ liệu

  const FullChartWaterQualityScreen({
    super.key, 
    required this.title, 
    required this.data, 
    this.isTestMode = false, // Giá trị mặc định là false (dữ liệu cũ)
  });

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
        // Cập nhật cách hiển thị SnackBar cho rõ ràng hơn
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi chụp ảnh: ${e.toString()}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem dữ liệu là WaterPoint hay TestWaterPoint
    final isTestMode = widget.data.isNotEmpty && widget.data.first is TestWaterPoint;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // ---------- Biểu đồ ----------
            Center(
              child: RepaintBoundary(
                key: _chartKey,
                child: isTestMode
                    ? _buildTestChart(widget.data.cast<TestWaterPoint>())
                    : _buildDefaultChart(widget.data.cast<WaterPoint>()),
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

  // ===========================================
  // ---- Biểu đồ cho Dữ liệu Gốc (WaterPoint) ----
  // ===========================================
  Widget _buildDefaultChart(List<WaterPoint> data) {
    return SfCartesianChart(
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: NumericAxis(
          minimum: data.first.day.toDouble(),
          maximum: data.last.day.toDouble(),
          interval: 1,
          title: const AxisTitle(text: 'Ngày')), // Thêm tiêu đề trục
      axes: [
        NumericAxis(
            name: 'phOxy',
            title: const AxisTitle(text: 'pH / Oxy'),
            opposedPosition: true,
            minimum: 0,
            maximum: 10,
            interval: 2),
        NumericAxis(
            name: 'InOut',
            title: const AxisTitle(text: 'Lượng nước (L)'),
            minimum: 0,
            // Giả định max 100 để biểu đồ dễ nhìn, có thể điều chỉnh
            maximum: (data.map((d) => d.inL).reduce(max) * 1.2).ceilToDouble(), 
        ),
      ],
      title: ChartTitle(
          text: widget.title,
          textStyle: const TextStyle(fontSize: 16)),
      series: [
        StackedColumnSeries<WaterPoint, int>(
          name: 'Nước vào',
          groupName: 'in',
          dataSource: data,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.inL,
          yAxisName: 'InOut',
          color: Colors.blue.shade700,
        ),
        StackedColumnSeries<WaterPoint, int>(
          name: 'Nước xả',
          groupName: 'out',
          dataSource: data,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.outL,
          yAxisName: 'InOut',
          color: Colors.orange.shade400,
        ),
        LineSeries<WaterPoint, int>(
          name: 'pH',
          dataSource: data,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.ph,
          yAxisName: 'phOxy',
          markerSettings: const MarkerSettings(isVisible: true),
          color: Colors.purple.shade700,
          width: 2,
        ),
        LineSeries<WaterPoint, int>(
          name: 'Oxy',
          dataSource: data,
          xValueMapper: (d, _) => d.day,
          yValueMapper: (d, _) => d.oxy,
          yAxisName: 'phOxy',
          markerSettings: const MarkerSettings(isVisible: true),
          color: Colors.green.shade700,
          width: 2,
        ),
      ],
    );
  }

  // ==============================================
  // ---- Biểu đồ cho Dữ liệu Test (TestWaterPoint) ----
  // ==============================================
  Widget _buildTestChart(List<TestWaterPoint> data) {
    if (data.isEmpty) {
        return const Center(child: Text("Không có dữ liệu để hiển thị"));
    }
    
    // Kiểm tra loại trục X (Giờ/Ngày)
    final isHourX = data.first.x is int && data.first.x >= 0 && data.first.x <= 24;
    final xTitle = isHourX ? 'Giờ (h)' : 'Ngày (Day)';
    
    return SfCartesianChart(
      title: ChartTitle(
          text: 'TEST: ${widget.title}',
          textStyle: const TextStyle(fontSize: 16)),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: NumericAxis(
        title: AxisTitle(text: xTitle),
        minimum: data.first.x.toDouble(),
        maximum: data.last.x.toDouble(),
        interval: isHourX ? 1 : null,
      ),
      axes: [
        // Axis cho Nhiệt độ và Nồng độ Oxy (Left side)
        NumericAxis(
          name: 'TempDo',
          title: const AxisTitle(text: 'Nhiệt độ (°C) / Nồng độ O₂ (mg/l)'),
          minimum: 0,
          maximum: 40,
          interval: 10,
        ),
        // Axis cho Hàm lượng Oxy (%) (Right side)
        NumericAxis(
          name: 'DoSat',
          opposedPosition: true,
          title: const AxisTitle(text: 'Hàm lượng O₂ (%)'),
          minimum: 0,
          maximum: 100,
          interval: 20,
        ),
      ],
      series: [
        // 1. Nhiệt độ (Temp)
        LineSeries<TestWaterPoint, num>(
          name: 'Nhiệt độ (°C)',
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.temp,
          yAxisName: 'TempDo',
          markerSettings: const MarkerSettings(isVisible: true, width: 6, height: 6),
          color: Colors.red.shade700,
          width: 2,
        ),
        // 2. Nồng độ Oxy (DO mg/l)
        LineSeries<TestWaterPoint, num>(
          name: 'Nồng độ O₂ (mg/l)',
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.doMgL,
          yAxisName: 'TempDo',
          markerSettings: const MarkerSettings(isVisible: true, width: 6, height: 6),
          color: Colors.blue.shade700,
          width: 2,
        ),
        // 3. Hàm lượng Oxy (DO %)
        LineSeries<TestWaterPoint, num>(
          name: 'Hàm lượng O₂ (%)',
          dataSource: data,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.doSat,
          yAxisName: 'DoSat',
          markerSettings: const MarkerSettings(isVisible: true, width: 6, height: 6),
          color: Colors.green.shade700,
          width: 2,
        ),
      ],
    );
  }
}