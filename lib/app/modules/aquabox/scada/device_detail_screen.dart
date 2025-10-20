import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

// Thêm các import cần thiết
import 'package:elevator/app/data/response/historical_data_response.dart'; // Giả sử HistoricalData nằm ở đây

import '../../../services/reporitories/historical_data_repo.dart'; // Giả sử HistoricalDataRepo nằm ở đây
// Bạn cần đảm bảo các đường dẫn import này là chính xác trong project của bạn.

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
  // Thay thế List<Map<String, String>> bằng List<HistoricalData>
  List<HistoricalData> _historicalData = [];
  bool _isLoadingHistory = true; // Biến trạng thái tải
  bool _hasErrorHistory = false; // Biến trạng thái lỗi
  bool _showHistory = false;

  // Khởi tạo Repository
  late final HistoricalDataRepo _historicalDataRepo;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Repository
    _historicalDataRepo = HistoricalDataRepo();
    
    // Xóa code tạo dữ liệu giả
    // _history = List.generate(...); 
    
    // Tải dữ liệu lịch sử
    _fetchHistoricalData();
  }
  
  // Phương thức gọi API
  Future<void> _fetchHistoricalData() async {
    // Chỉ tải nếu chưa tải hoặc tải thất bại (hoặc khi người dùng muốn refresh)
    if (!_isLoadingHistory) {
      setState(() {
        _isLoadingHistory = true;
        _hasErrorHistory = false;
      });
    }

    try {
      final data = await _historicalDataRepo.getHistoricalDataByRegisterID(
        id: widget.register.id!, // Truyền register ID. Giả sử id không null.
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
      // Hiển thị thông báo lỗi cho người dùng nếu cần
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Không thể tải lịch sử: $e')),
      // );
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

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã lưu cài đặt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.register.name.toString()),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              // Khi chuyển sang xem lịch sử, nếu chưa tải hoặc lỗi thì tải lại
              onPressed: () {
                setState(() => _showHistory = !_showHistory);
                if (_showHistory && (_historicalData.isEmpty || _hasErrorHistory)) {
                  _fetchHistoricalData();
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: _showHistory ? _buildHistoryView() : _buildSettingsView(),
        ),
        bottomSheet: !_showHistory
            ? Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF5FAFF), Color(0xFFE8F1FC)],
                  ),
                ),
                child: ElevatedButton.icon(
                  onPressed: _save,
                  label: const Text('Lưu', style: TextStyle(fontSize: 14,color: Colors.white)),
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

  // ... Các widget _buildSettingsView, _cardInput, _cardSwitch, _cardSwitchInput ...

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

  // Cập nhật _buildHistoryView để sử dụng dữ liệu thực tế
  Widget _buildHistoryView() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasErrorHistory) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Không thể tải dữ liệu lịch sử. Vui lòng thử lại.'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _fetchHistoricalData,
              child: const Text('Tải lại'),
            ),
          ],
        ),
      );
    }

    if (_historicalData.isEmpty) {
      return const Center(child: Text('Không có dữ liệu lịch sử.'));
    }

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 24), 
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.black),
          dataRowColor: WidgetStateProperty.all(Colors.white),
          columnSpacing: 24,
          columns: const [
            DataColumn(
                label: Text('Thời gian', style: TextStyle(color: Colors.white))),
            DataColumn(
                label: Text('Giá trị', style: TextStyle(color: Colors.white))),
          ],
          // Ánh xạ từ List<HistoricalData> sang List<DataRow>
          rows: _historicalData
              .map((e) => DataRow(cells: [
                    DataCell(Text(_formatTimestamp(e.timestamp))), // Định dạng thời gian
                    DataCell(Text((e.value ?? 'N/A').toString())),
                  ]))
              .toList(),
          showCheckboxColumn: false,
        ),
      ),
    );
  }

  // Hàm định dạng timestamp (tùy chọn)
  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return 'N/A';
    // Giả sử timestamp là chuỗi ISO 8601, bạn có thể format lại cho đẹp hơn
    try {
      final dateTime = DateTime.parse(timestamp).toLocal();
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
    } catch (e) {
      return timestamp; // Trả về nguyên gốc nếu lỗi format
    }
  }

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

  Widget _cardSwitchInput({
    required String title,
    required bool enabled,
    required TextEditingController controller,
    required ValueChanged<bool> onToggle,
    required String unit,
    required double min,
    required double max
  }) {
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
      );
}