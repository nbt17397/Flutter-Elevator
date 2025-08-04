import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String deviceName;
  const DeviceDetailScreen({super.key, required this.deviceName});

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
  late final List<Map<String, String>> _history;
  bool _showHistory = false;

  @override
  void initState() {
    super.initState();
    _history = List.generate(
      40,
      (i) => {
        'time': '10:${(59 - i).toString().padLeft(2, '0')} 03/07/2025',
        'action': i.isEven ? 'BẬT' : 'TẮT',
        'user': 'User ${i % 3 + 1}',
      },
    );
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
      SnackBar(content: Text('Đã lưu cài đặt')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.deviceName),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () => setState(() => _showHistory = !_showHistory),
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

  Widget _buildHistoryView() {
    return SingleChildScrollView(
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.black),
        dataRowColor: WidgetStateProperty.all(Colors.white),
        columnSpacing: 24,
        columns: const [
          DataColumn(
              label: Text('Thời gian', style: TextStyle(color: Colors.white))),
          DataColumn(
              label: Text('Hành động', style: TextStyle(color: Colors.white))),
          DataColumn(
              label: Text('Người dùng', style: TextStyle(color: Colors.white))),
        ],
        rows: _history
            .map((e) => DataRow(cells: [
                  DataCell(Text(e['time']!)),
                  DataCell(Text(e['action']!)),
                  DataCell(Text(e['user']!)),
                ]))
            .toList(),
        showCheckboxColumn: false,
      ),
    );
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
