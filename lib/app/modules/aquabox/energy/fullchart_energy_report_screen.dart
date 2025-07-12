import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'energy_report_screen.dart';   // để dùng _StatPoint & StatView

class FullChartEnergyReportScreen extends StatefulWidget {
  final List<StatPoint> statPoints;
  final StatView statView;
  final String sysFilter;            // nếu cần hiển thị
  const FullChartEnergyReportScreen({
    super.key,
    required this.statPoints,
    required this.statView,
    required this.sysFilter,
  });

  @override
  State<FullChartEnergyReportScreen> createState() => _FullChartEnergyReportScreenState();
}

class _FullChartEnergyReportScreenState extends State<FullChartEnergyReportScreen> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    /* khoá landscape + ẩn status bar */
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    /* khôi phục */
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _capture() async {
    try {
      final boundary =
          _key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image img = await boundary.toImage(pixelRatio: 3);
      final byteData =
          await img.toByteData(format: ui.ImageByteFormat.png) as ByteData;
      final bytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/stat_chart.png')..writeAsBytesSync(bytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Stat chart');
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
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: RepaintBoundary(
                key: _key,
                child: SfCartesianChart(
                  legend:
                      Legend(isVisible: true, position: LegendPosition.bottom),
                  tooltipBehavior: TooltipBehavior(enable: true),
                  primaryXAxis: CategoryAxis(
                      majorGridLines: const MajorGridLines(width: 0)),
                  series: [
                    ColumnSeries<StatPoint, String>(
                      name: 'Tiêu thụ',
                      dataSource: widget.statPoints,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.cons,
                      color: Colors.red.shade600,
                    ),
                    ColumnSeries<StatPoint, String>(
                      name: 'Solar',
                      dataSource: widget.statPoints,
                      xValueMapper: (p, _) => p.label,
                      yValueMapper: (p, _) => p.solar,
                      color: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
            ),

            /* back */
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            /* download */
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Tải ảnh',
                icon: const Icon(Icons.download),
                onPressed: _capture,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
