import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class AlertSettingScreen extends StatefulWidget {
  const AlertSettingScreen({super.key});

  @override
  State<AlertSettingScreen> createState() => _AlertSettingScreenState();
}

class _AlertSettingScreenState extends State<AlertSettingScreen> {
  /* ---- STATE ---- */
  bool _deviceAlert   = true;
  bool _buzzerAlert   = false;
  bool _emailAlert    = true;

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),color: Colors.white
      );

  /* ---- UI ---- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Kích hoạt cảnh báo'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _switchTile(
                label: 'Cảnh báo thiết bị',
                value: _deviceAlert,
                onChanged: (v) => setState(() => _deviceAlert = v),
              ),
              const SizedBox(height: 10),
              _switchTile(
                label: 'Còi thông báo',
                value: _buzzerAlert,
                onChanged: (v) => setState(() => _buzzerAlert = v),
              ),
              const SizedBox(height: 10),
              _switchTile(
                label: 'Gửi email cảnh báo',
                value: _emailAlert,
                onChanged: (v) => setState(() => _emailAlert = v),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// widget dòng switch có border xám
  Widget _switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: _box,
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Switch(
            value: value,
            onChanged: onChanged,

            // màu theo template
            activeColor: Colors.green,
            activeTrackColor: Colors.green.shade200,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
