import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class HistoryEntry {
  final String time;
  final String action;
  final String user;
  HistoryEntry(this.time, this.action, this.user);
}

class DeviceDetailScreen extends StatefulWidget {
  final String deviceName;
  const DeviceDetailScreen({super.key, required this.deviceName});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  // -------------------------------- mock data -------------------------------
  late final List<HistoryEntry> _history;
  Duration _timeout = const Duration(seconds: 10);
  int _delay = 3;
  bool _mute = false;

  @override
  void initState() {
    super.initState();
    _history = List.generate(
      40,
      (i) => HistoryEntry(
        '10:${(59 - i).toString().padLeft(2, '0')} 03/07/2025',
        i.isEven ? 'BẬT' : 'TẮT',
        'User ${i % 3 + 1}',
      ),
    );
  }

  // --------------------------- Helpers nhập số ------------------------------
  Future<void> _editNumber({
    required String title,
    required int initial,
    required ValueChanged<int> onSave,
  }) async {
    final ctrl = TextEditingController(text: '$initial');
    final formKey = GlobalKey<FormState>();

    // style Input viền xám giống template
    InputDecoration _dec(String lbl) => InputDecoration(
          labelText: lbl,
          labelStyle: const TextStyle(fontSize: 13),
          isDense: true,
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );

    final ok = await Alert(
      context: context,
      title: title.toUpperCase(),
      style: AlertStyle(
        titleStyle: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          validator: (v) =>
              int.tryParse(v ?? '') == null ? 'Nhập số hợp lệ' : null,
          decoration: _dec('Giá trị (s)'),
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Huỷ", style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.blue.shade700,
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            onSave(int.parse(ctrl.text));
            Navigator.pop(context, true);
          },
          child: const Text("Lưu", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();

    // ok == true đã xử lý trong onSave; không cần gì thêm
  }

  // --------------------------------- UI -------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.deviceName),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ================= KHU CÀI ĐẶT (TRÊN) =================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _settingRow(
                    'Timeout: ${_timeout.inSeconds}s',
                    onTap: () => _editNumber(
                      title: 'Timeout (giây)',
                      initial: _timeout.inSeconds,
                      onSave: (v) =>
                          setState(() => _timeout = Duration(seconds: v)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _settingRow(
                    'Delay: $_delay s',
                    onTap: () => _editNumber(
                      title: 'Delay (giây)',
                      initial: _delay,
                      onSave: (v) => setState(() => _delay = v),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _settingRow(
                    _mute ? 'Đã tắt thông báo' : 'Đang bật thông báo',
                    trailing: Switch(
                      value: !_mute,
                      onChanged: (_) => setState(() => _mute = !_mute),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                    ),
                    onTap: () => setState(() => _mute = !_mute),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ================= LỊCH SỬ (DƯỚI – CÓ CUỘN) =================
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Colors.black),
                      dataRowColor:
                          MaterialStateProperty.all(Colors.grey.shade300),
                      columnSpacing: 32,
                      columns: const [
                        DataColumn(
                            label: Text('Thời gian',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Hành động',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Người dùng',
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: _history
                          .map((e) => DataRow(cells: [
                                DataCell(Text(e.time)),
                                DataCell(Text(e.action)),
                                DataCell(Text(e.user)),
                              ]))
                          .toList(),
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingRow(String label,
      {required VoidCallback onTap, Widget? trailing}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            )),
            trailing ?? const Icon(Icons.edit, size: 20, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
