import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

// Thêm các import cần thiết
import 'package:elevator/app/data/response/historical_data_response.dart';
import '../../../services/reporitories/historical_data_repo.dart';

import 'package:intl/intl.dart'; // Để định dạng ngày tháng
import 'package:syncfusion_flutter_charts/charts.dart'; // Thư viện biểu đồ
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

// Định nghĩa Enum cho chế độ xem
enum HistoryViewMode { chart, table }

// Định nghĩa Enum cho bộ lọc thời gian
enum TimeFilter { today, thisWeek, thisMonth, all }

// Lớp phụ trợ cho dữ liệu Biểu đồ
class ChartDataPoint {
  final DateTime x;
  final double y;
  ChartDataPoint(this.x, this.y);
}

// Extension để dễ dàng lấy chuỗi hiển thị
extension TimeFilterExtension on TimeFilter {
  String get displayText {
    switch (this) {
      case TimeFilter.today:
        return 'Hôm nay';
      case TimeFilter.thisWeek:
        return 'Tuần này';
      case TimeFilter.thisMonth:
        return 'Tháng này';
      case TimeFilter.all:
        return 'Tất cả';
    }
  }
}

class DeviceDetailScreen extends StatefulWidget {
  final RegisterDB register;
  const DeviceDetailScreen({super.key, required this.register});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  // Cài đặt
  bool _mute = false;
  bool _openLoopEnabled = false;
  final _openLoopCtrl = TextEditingController(text: '0');

  bool _maintainEnabled = false;
  final _maintainCtrl = TextEditingController(text: '0');

  final _timeoutCtrl = TextEditingController(text: '10');
  final _delayCtrl = TextEditingController(text: '3');

  final _formKey = GlobalKey<FormState>();

  // Lịch sử
  List<HistoricalData> _historicalData = [];
  bool _isLoadingHistory = true;
  bool _hasErrorHistory = false;

  // Trạng thái Lịch sử/Biểu đồ mới
  late bool _showHistory;
  late HistoryViewMode _historyViewMode;
  TimeFilter _timeFilter = TimeFilter.today;

  // Biến cho Zoom/Pan của Chart
  late ZoomPanBehavior _zoomPanBehavior;

  // Khởi tạo Repository
  late final HistoricalDataRepo _historicalDataRepo;

  @override
  void initState() {
    super.initState();
    _historicalDataRepo = HistoricalDataRepo();

    // Khởi tạo mặc định theo yêu cầu
    final isParam = widget.register.type == 'param';
    _showHistory = isParam;
    _historyViewMode = isParam ? HistoryViewMode.chart : HistoryViewMode.table;

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
      enablePanning: true,
    );

    // Tải dữ liệu lịch sử nếu mặc định là show lịch sử
    if (_showHistory) {
      // Dùng Future.microtask để tránh lỗi setState trong initState
      Future.microtask(() => _fetchHistoricalData());
    }
  }

  // Phương thức gọi API (Cập nhật để có tùy chọn force reload)
  Future<void> _fetchHistoricalData({bool force = false}) async {
    // Chỉ tải nếu cần
    if (!force &&
        !_isLoadingHistory &&
        !_hasErrorHistory &&
        _historicalData.isNotEmpty) return;

    if (mounted) {
      setState(() {
        _isLoadingHistory = true;
        _hasErrorHistory = false;
      });
    }

    try {
      // Tải dữ liệu
      final data = await _historicalDataRepo.getHistoricalDataByRegisterID(
        id: widget.register.id!,
      );
      if (mounted) {
        setState(() {
          _historicalData = data;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi tải Historical Data: $e');
      if (mounted) {
        setState(() {
          _isLoadingHistory = false;
          _hasErrorHistory = true;
        });
      }
    }
  }

  // Phương thức lọc dữ liệu theo TimeFilter
  List<HistoricalData> _getFilteredData() {
    if (_historicalData.isEmpty) return [];

    final now = DateTime.now().toLocal();
    DateTime? startDate;

    switch (_timeFilter) {
      case TimeFilter.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case TimeFilter.thisWeek:
        // Lấy ngày đầu tuần (Thứ Hai)
        int weekday = now.weekday;
        // Nếu là CN (7), weekday - 1 = 6. Thứ 2 (1), weekday - 1 = 0
        startDate = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday == 7 ? 6 : weekday - 1));
        break;
      case TimeFilter.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case TimeFilter.all:
        return _historicalData;
    }

    final filtered = _historicalData.where((data) {
      try {
        final dataDate = DateTime.parse(data.timestamp!).toLocal();
        return dataDate.isAfter(startDate!) ||
            dataDate.isAtSameMomentAs(startDate);
      } catch (e) {
        return false;
      }
    }).toList();

    // Sắp xếp theo thứ tự thời gian tăng dần cho biểu đồ/bảng
    filtered.sort((a, b) =>
        DateTime.parse(a.timestamp!).compareTo(DateTime.parse(b.timestamp!)));

    return filtered;
  }

  // Trong class _DeviceDetailScreenState

// Hàm trợ giúp để lấy thư mục Downloads/Documents (Đã cập nhật)
Future<Directory> _getDownloadDirectory() async {
  if (Platform.isAndroid) {
    // 💡 GIẢI PHÁP HIỆN ĐẠI CHO ANDROID 13+ (Sử dụng getExternalStorageDirectory và tính toán path)
    // File được lưu vào thư mục này sẽ hiển thị trong file manager.
    final externalDir = await getExternalStorageDirectory(); 
    if (externalDir == null) {
      // Trường hợp khẩn cấp, quay về Documents của app
      return getApplicationDocumentsDirectory(); 
    }
    
    // Đường dẫn chung của Android (Ví dụ: /storage/emulated/0/Download)
    // Ta cắt bỏ /Android/data/your.package.name/files để lấy thư mục gốc
    String rootPath = externalDir.path.split('Android')[0];
    Directory downloadDir = Directory('${rootPath}Download'); 
    
    if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
    }
    return downloadDir;

  } else if (Platform.isIOS) {
    // iOS: Vẫn dùng Documents là an toàn nhất vì Apple hạn chế truy cập Downloads
    return getApplicationDocumentsDirectory(); 
  } else {
    // Desktop/Web
    return getApplicationDocumentsDirectory(); 
  }
}


void _exportToExcel() async {
  final dataToExport = _getFilteredData();

  if (dataToExport.isEmpty) {
    debugPrint('Xuất Excel: Không có dữ liệu để xuất.');
    return;
  }

  try {
    // 1. Chuẩn bị dữ liệu CSV (giữ nguyên)
    List<List<dynamic>> csvData = [
      ['Thời gian', 'Giá trị', 'Thiết bị'],
      ...dataToExport.map((e) => [
            _formatTimestamp(e.timestamp),
            (e.value ?? 'N/A').toString(),
            widget.register.name.toString(),
          ]),
    ];
    String csvString = const ListToCsvConverter().convert(csvData);

    // 2. Lấy thư mục Downloads/Công khai
    final directory = await _getDownloadDirectory(); 
    
    final fileName =
        'Data_${widget.register.name}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.csv';
    final path = '${directory.path}/$fileName';

    final file = File(path);
    await file.writeAsString(csvString,
          encoding: const Utf8Codec(allowMalformed: true)); 

    // ✅ PHẢN HỒI THÀNH CÔNG RÕ RÀNG
    debugPrint('✅ Xuất file CSV thành công! File đã lưu tại: $path');

  } catch (e) {
    debugPrint('❌ Lỗi xuất file CSV: ${e.toString()}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi xuất file!'),
        content: Text('Không thể lưu file vào Downloads: ${e.toString()}'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

  @override
  void dispose() {
    _timeoutCtrl.dispose();
    _delayCtrl.dispose();
    _openLoopCtrl.dispose();
    _maintainCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ẩn nút Lưu nếu đang ở chế độ xem lịch sử
    final hideBottomSheet = _showHistory;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.register.name.toString()),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            // Nút chuyển đổi Giữa Cài đặt và Lịch sử/Biểu đồ
            IconButton(
              icon: Icon(_showHistory ? Icons.settings : Icons.history),
              tooltip:
                  _showHistory ? 'Chuyển sang Cài đặt' : 'Chuyển sang Lịch sử',
              onPressed: () {
                setState(() => _showHistory = !_showHistory);
                if (_showHistory &&
                    (_historicalData.isEmpty || _hasErrorHistory)) {
                  _fetchHistoricalData();
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: _showHistory ? _buildHistoryContainer() : _buildSettingsView(),
        ),
        bottomSheet: !hideBottomSheet
            ? Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF5FAFF), Color(0xFFE8F1FC)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    print("======");
                  },
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text('Lưu',
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: CustomColors.appbarColor,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  // --------------------------------------------------
  //          PHẦN GIAO DIỆN CÀI ĐẶT
  // --------------------------------------------------

  Widget _buildSettingsView() {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          _cardSwitch(
            title: 'Thông báo',
            value: !_mute,
            onToggle: (v) => setState(() => _mute = !v),
          ),
          _cardInput(
            title: 'Timeout',
            controller: _timeoutCtrl,
            unit: 'giây',
            min: 1,
            max: 300,
          ),
          _cardInput(
            title: 'Delay',
            controller: _delayCtrl,
            unit: 'giây',
            min: 0,
            max: 60,
          ),
          _cardSwitchInput(
            title: 'Điều khiển vòng hở',
            enabled: _openLoopEnabled,
            controller: _openLoopCtrl,
            onToggle: (v) => setState(() => _openLoopEnabled = v),
            unit: '',
            min: 0,
            max: 1000,
          ),
          _cardSwitchInput(
            title: 'Thời gian bảo trì',
            enabled: _maintainEnabled,
            controller: _maintainCtrl,
            onToggle: (v) => setState(() => _maintainEnabled = v),
            unit: 'giờ',
            min: 0,
            max: 1000,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // --------------------------------------------------
  //          PHẦN GIAO DIỆN LỊCH SỬ/BIỂU ĐỒ
  // --------------------------------------------------

  Widget _buildHistoryContainer() {
    final isParam = widget.register.type == 'param';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bộ lọc thời gian (Dropdown)
        _buildTimeFilter(),
        const SizedBox(height: 12),

        // Các nút điều khiển (Chart/Table Switch và Export/Refresh)
        // Thay thế đoạn code Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [...])
// trong _buildHistoryContainer() bằng đoạn sau:

        Row(
          // Giữ mainAxisAlignment.start để dồn các thành phần về bên trái và dùng Spacer để đẩy các nút cuối cùng sang phải
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (isParam) // Chỉ show nút chuyển đổi nếu là param
              // Giữ Flexible để SegmentedButton co giãn tối đa, nhưng đặt giới hạn chiều rộng
              Flexible(
                child: SegmentedButton<HistoryViewMode>(
                  segments: const [
                    ButtonSegment(
                        value: HistoryViewMode.chart,
                        label: Text('Biểu đồ'),
                        icon: Icon(Icons.ssid_chart)),
                    ButtonSegment(
                        value: HistoryViewMode.table,
                        label: Text('Bảng'),
                        icon: Icon(Icons.table_chart)),
                  ],
                  selected: {_historyViewMode},
                  onSelectionChanged: (Set<HistoryViewMode> newSelection) {
                    setState(() {
                      _historyViewMode = newSelection.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor:
                        CustomColors.appbarColor.withOpacity(0.1),
                    selectedForegroundColor: CustomColors.appbarColor,
                    // Thêm padding nhỏ hơn cho các nút để giảm kích thước tổng thể
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    textStyle: const TextStyle(fontSize: 12), // Thu nhỏ chữ
                  ),
                ),
              ),

            // Thêm khoảng cách giữa SegmentedButton và các nút hành động
            const Spacer(),

            // Nút Xuất Excel (Chuyển từ OutlinedButton.icon sang IconButton)
            IconButton(
              onPressed: _exportToExcel,
              icon: const Icon(Icons.download),
              tooltip:
                  'Xuất Excel', // Thêm tooltip để người dùng biết chức năng
              color: CustomColors.appbarColor,
            ),

            // Nút Tải lại (Giữ nguyên)
            IconButton(
              onPressed: () => _fetchHistoricalData(force: true),
              icon: const Icon(Icons.refresh),
              tooltip: 'Tải lại',
              color: CustomColors.appbarColor,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Khu vực hiển thị Biểu đồ hoặc Bảng
        Expanded(
          child: _buildHistoryContent(),
        ),
      ],
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoadingHistory) {
      return Center(
          child: CircularProgressIndicator(color: CustomColors.appbarColor));
    }

    if (_hasErrorHistory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không thể tải dữ liệu lịch sử. Vui lòng thử lại.',
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _fetchHistoricalData(force: true),
              child:
                  const Text('Tải lại', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                  backgroundColor: CustomColors.appbarColor),
            ),
          ],
        ),
      );
    }

    final filteredData = _getFilteredData();

    if (filteredData.isEmpty) {
      return Center(
          child: Text(
        'Không có dữ liệu lịch sử cho ${_timeFilter.displayText}.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.grey),
      ));
    }

    if (widget.register.type == 'param' &&
        _historyViewMode == HistoryViewMode.chart) {
      return _buildChartView(filteredData);
    } else {
      return _buildHistoryTableView(filteredData);
    }
  }

  Widget _buildTimeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TimeFilter>(
          value: _timeFilter,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: CustomColors.appbarColor),
          style: const TextStyle(fontSize: 14, color: Colors.black),
          items: TimeFilter.values.map((TimeFilter filter) {
            return DropdownMenuItem<TimeFilter>(
              value: filter,
              child: Text(filter.displayText,
                  style: TextStyle(
                    fontWeight: _timeFilter == filter
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: _timeFilter == filter
                        ? CustomColors.appbarColor
                        : Colors.black,
                  )),
            );
          }).toList(),
          onChanged: (TimeFilter? newValue) {
            if (newValue != null) {
              setState(() {
                _timeFilter = newValue;
              });
              // Nếu chuyển sang "Tất cả" và dữ liệu chưa đầy đủ, tải lại
              if (newValue == TimeFilter.all && _historicalData.length < 5) {
                _fetchHistoricalData(force: true);
              }
            }
          },
        ),
      ),
    );
  }

  Widget _buildChartView(List<HistoricalData> data) {
    final List<ChartDataPoint> chartData = data.map((e) {
      try {
        final dateTime = DateTime.parse(e.timestamp!).toLocal();
        return ChartDataPoint(dateTime, e.value ?? 0.0);
      } catch (_) {
        return ChartDataPoint(DateTime.now().toLocal(), 0.0);
      }
    }).toList();

    DateTime? minDate = chartData.isNotEmpty ? chartData.first.x : null;
    DateTime? maxDate = chartData.isNotEmpty ? chartData.last.x : null;

    if (_timeFilter == TimeFilter.today && minDate != null) {
      minDate = DateTime(minDate.year, minDate.month, minDate.day);
      maxDate = minDate.add(const Duration(days: 1));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4)
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: SfCartesianChart(
        title: ChartTitle(
            text: 'Biểu đồ ${widget.register.name}',
            textStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        legend: const Legend(isVisible: false),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          header: 'Thời gian',
          // Tùy chỉnh format cho Tooltip
          tooltipPosition: TooltipPosition.auto,
          builder: (data, point, series, pointIndex, seriesIndex) {
            final ChartDataPoint chartPoint = data as ChartDataPoint;
            final timeFormat = DateFormat('HH:mm:ss dd/MM');
            return Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(
                '${timeFormat.format(chartPoint.x)}\nGiá trị: ${chartPoint.y.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            );
          },
        ),
        zoomPanBehavior: _zoomPanBehavior,
        primaryXAxis: DateTimeAxis(
          title: const AxisTitle(text: 'Thời gian'),
          dateFormat: _timeFilter == TimeFilter.today
              ? DateFormat('HH:mm')
              : DateFormat('dd/MM'),
          intervalType: _timeFilter == TimeFilter.today
              ? DateTimeIntervalType.hours
              : DateTimeIntervalType.days,
          // visibleMinimum: _timeFilter == TimeFilter.all ? null : minDate,
          // visibleMaximum: _timeFilter == TimeFilter.all ? null : maxDate,
          edgeLabelPlacement: EdgeLabelPlacement.shift,
        ),
        primaryYAxis: const NumericAxis(
          title: AxisTitle(text: 'Giá trị'),
        ),
        series: <LineSeries<ChartDataPoint, DateTime>>[
          LineSeries<ChartDataPoint, DateTime>(
            name: widget.register.name.toString(),
            dataSource: chartData,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            markerSettings:
                const MarkerSettings(isVisible: true, height: 4, width: 4),
            color: CustomColors.appbarColor,
            animationDuration: 1000,
          ),
        ],
      ),
    );
  }

  // Giao diện Bảng
  Widget _buildHistoryTableView(List<HistoricalData> data) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width - 24),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(CustomColors.appbarColor),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          columnSpacing: 24,
          columns: const [
            DataColumn(
                label: Text('Thời gian',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Giá trị',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold))),
          ],
          rows: data
              .map((e) => DataRow(cells: [
                    DataCell(Text(_formatTimestamp(e.timestamp))),
                    DataCell(Text((e.value ?? 'N/A').toString())),
                  ]))
              .toList(),
          showCheckboxColumn: false,
        ),
      ),
    );
  }

  // Hàm định dạng timestamp
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      // Định dạng chi tiết hơn cho All/Month/Week, ngắn hơn cho Today
      final format =
          _timeFilter == TimeFilter.today ? 'HH:mm:ss' : 'HH:mm dd/MM/yyyy';
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return timestamp;
    }
  }

  // --------------------------------------------------
  //          CÁC WIDGET THẺ CÀI ĐẶT
  // --------------------------------------------------

  Widget _cardInput({
    required String title,
    required TextEditingController controller,
    required String unit,
    required double min,
    required double max,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: _box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: unit,
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (txt) {
              final v = double.tryParse(txt ?? '') ?? 0;
              if (v < min || v > max) return 'Giá trị phải từ $min đến $max';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _cardSwitch({
    required String title,
    required bool value,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: _box,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Switch(
            value: value,
            onChanged: onToggle,
            activeColor: Colors.green,
            activeTrackColor: Colors.green.shade200,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _cardSwitchInput(
      {required String title,
      required bool enabled,
      required TextEditingController controller,
      required ValueChanged<bool> onToggle,
      required String unit,
      required double min,
      required double max}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: _box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeColor: Colors.green,
                activeTrackColor: Colors.green.shade200,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade400,
              ),
            ],
          ),
          if (enabled)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Giá trị',
                  suffixText: unit,
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey.shade600, width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (txt) {
                  final v = double.tryParse(txt ?? '') ?? 0;
                  if (v < min || v > max) {
                    return 'Giá trị phải từ $min đến $max';
                  }
                  return null;
                },
              ),
            ),
        ],
      ),
    );
  }

  BoxDecoration get _box => BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white);
}
