import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/data/response/historical_data_response.dart';
import 'package:elevator/config/shared/colors.dart';
import '../../../services/reporitories/historical_data_repo.dart';

enum HistoryViewMode { chart, table }
enum TimeFilter { today, thisWeek, thisMonth, all }

extension TimeFilterExtension on TimeFilter {
  String get displayText {
    switch (this) {
      case TimeFilter.today: return 'Hôm nay';
      case TimeFilter.thisWeek: return 'Tuần này';
      case TimeFilter.thisMonth: return 'Tháng này';
      case TimeFilter.all: return 'Tất cả';
    }
  }
}

class ChartDataPoint {
  final DateTime x;
  final double y;
  ChartDataPoint(this.x, this.y);
}

class DeviceDetailScreen extends StatefulWidget {
  final RegisterDB register;
  const DeviceDetailScreen({super.key, required this.register});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  List<HistoricalData> _historicalData = [];
  bool _isLoadingHistory = true;
  bool _hasErrorHistory = false;
  TimeFilter _timeFilter = TimeFilter.today;
  HistoryViewMode _historyViewMode = HistoryViewMode.chart;
  
  final HistoricalDataRepo _historicalDataRepo = HistoricalDataRepo();

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
  }

  // --- LOGIC LỌC DỮ LIỆU ---
  List<HistoricalData> get _filteredData {
    if (_historicalData.isEmpty) return [];
    final now = DateTime.now();
    
    return _historicalData.where((item) {
      if (item.timestamp == null) return false;
      final itemDate = DateTime.parse(item.timestamp!).toLocal();

      switch (_timeFilter) {
        case TimeFilter.today:
          return itemDate.year == now.year &&
                 itemDate.month == now.month &&
                 itemDate.day == now.day;
        case TimeFilter.thisWeek:
          // Tính từ 00:00:00 thứ 2 đầu tuần
          final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
          return itemDate.isAfter(startOfWeek) || itemDate.isAtSameMomentAs(startOfWeek);
        case TimeFilter.thisMonth:
          return itemDate.year == now.year && itemDate.month == now.month;
        case TimeFilter.all:
          return true;
      }
    }).toList();
  }

  Future<void> _fetchHistoricalData({bool force = false}) async {
    if (!mounted) return;
    setState(() { _isLoadingHistory = true; _hasErrorHistory = false; });

    try {
      final data = await _historicalDataRepo.getHistoricalDataByRegisterID(id: widget.register.id!);
      if (mounted) {
        setState(() {
          _historicalData = data;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _isLoadingHistory = false; _hasErrorHistory = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredData; // Tính toán một lần để dùng cho toàn bộ UI

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          title: Text(widget.register.name?.toUpperCase() ?? "GIÁM SÁT DỮ LIỆU"),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _fetchHistoricalData(force: true),
            ),
            IconButton(
              icon: const Icon(Icons.ios_share),
              onPressed: _exportToExcel,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildLiveValueHeader(filteredList),
            _buildControlBar(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: _buildHistoryContent(filteredList),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveValueHeader(List<HistoricalData> data) {
    String lastVal = data.isNotEmpty ? data.last.value.toString() : "--";
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [CustomColors.appbarColor, const Color(0xFF3949AB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("GIÁ TRỊ CUỐI (BỘ LỌC)", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              const SizedBox(height: 8),
              Text(lastVal, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Colors.white)),
            ],
          ),
          const Icon(Icons.analytics, color: Colors.white30, size: 60),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildTimeFilterModern()),
          const SizedBox(width: 12),
          _toggleBtn(Icons.show_chart, _historyViewMode == HistoryViewMode.chart, 
              () => setState(() => _historyViewMode = HistoryViewMode.chart)),
          const SizedBox(width: 8),
          _toggleBtn(Icons.table_rows, _historyViewMode == HistoryViewMode.table, 
              () => setState(() => _historyViewMode = HistoryViewMode.table)),
        ],
      ),
    );
  }

  Widget _buildTimeFilterModern() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<TimeFilter>(
        value: _timeFilter,
        isExpanded: true,
        style: TextStyle(color: CustomColors.appbarColor, fontWeight: FontWeight.bold),
        onChanged: (v) => setState(() => _timeFilter = v!),
        items: TimeFilter.values.map((f) => DropdownMenuItem(value: f, child: Text(f.displayText))).toList(),
      ),
    ),
  );

  Widget _toggleBtn(IconData icon, bool active, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? CustomColors.appbarColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? CustomColors.appbarColor : Colors.grey.shade300),
      ),
      child: Icon(icon, color: active ? Colors.white : Colors.grey, size: 20),
    ),
  );

  Widget _buildHistoryContent(List<HistoricalData> data) {
    if (_isLoadingHistory) return const Center(child: CircularProgressIndicator());
    if (_hasErrorHistory) return const Center(child: Text("Lỗi tải dữ liệu"));
    if (data.isEmpty) return const Center(child: Text("Không có dữ liệu trong khoảng này"));
    
    return _historyViewMode == HistoryViewMode.chart 
        ? _buildChartView(data) 
        : _buildTableView(data);
  }

  Widget _buildChartView(List<HistoricalData> data) {
    final chartData = data.map((e) => ChartDataPoint(DateTime.parse(e.timestamp!).toLocal(), e.value ?? 0.0)).toList();
    
    // Tự động đổi format trục X theo bộ lọc
    String xAxisFormat = 'HH:mm';
    if (_timeFilter == TimeFilter.thisMonth || _timeFilter == TimeFilter.all) {
      xAxisFormat = 'dd/MM';
    } else if (_timeFilter == TimeFilter.thisWeek) {
      xAxisFormat = 'EEE';
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat(xAxisFormat),
        majorGridLines: const MajorGridLines(width: 0),
      ),
      primaryYAxis: const NumericAxis(
        axisLine: AxisLine(width: 0),
        majorTickLines: MajorTickLines(size: 0),
      ),
      series: <LineSeries<ChartDataPoint, DateTime>>[
        LineSeries<ChartDataPoint, DateTime>(
          dataSource: chartData,
          xValueMapper: (d, _) => d.x,
          yValueMapper: (d, _) => d.y,
          color: CustomColors.appbarColor,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true, width: 4, height: 4, shape: DataMarkerType.circle),
          enableTooltip: true,
        )
      ],
      tooltipBehavior: TooltipBehavior(enable: true, header: 'Giá trị'),
    );
  }

  Widget _buildTableView(List<HistoricalData> data) {
    // Đảo ngược một lần bên ngoài itemBuilder để tối ưu hiệu năng
    final reversedData = data.reversed.toList();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: reversedData.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
      itemBuilder: (context, index) {
        final item = reversedData[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: CustomColors.appbarColor.withOpacity(0.1),
            child: Icon(Icons.show_chart, size: 16, color: CustomColors.appbarColor),
          ),
          title: Text(item.value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('HH:mm:ss dd/MM/yyyy').format(DateTime.parse(item.timestamp!).toLocal())),
        );
      },
    );
  }

  void _exportToExcel() async {
    // Thực hiện export dựa trên _filteredData để file tải về khớp với những gì đang xem
    if (_filteredData.isEmpty) return;
    // Logic export CSV của bạn ở đây...
  }
}