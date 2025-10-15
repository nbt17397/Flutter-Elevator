import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class EnergySettingsScreen extends StatefulWidget {
  const EnergySettingsScreen({super.key});

  @override
  State<EnergySettingsScreen> createState() => _EnergySettingsScreenState();
}

class _EnergySettingsScreenState extends State<EnergySettingsScreen> {
  /* --------- STATE --------- */
  bool _lowVoltEnabled = true;
  bool _highVoltEnabled = true;
  bool _phaseLossEnabled = true;

  final _lowVoltCtrl = TextEditingController(text: '180');
  final _highVoltCtrl = TextEditingController(text: '250');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _lowVoltCtrl.dispose();
    _highVoltCtrl.dispose();
    super.dispose();
  }

  /* --------- SAVE --------- */
  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Đã lưu:\n'
          '- Áp thấp: ${_lowVoltEnabled ? "${_lowVoltCtrl.text} V" : "OFF"}\n'
          '- Áp cao:  ${_highVoltEnabled ? "${_highVoltCtrl.text} V" : "OFF"}\n'
          '- Mất pha: ${_phaseLossEnabled ? "ON" : "OFF"}',
        ),
      ),
    );
  }

  /* --------- UI --------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cài đặt năng lượng'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _warningCard(
                  title: 'Cảnh báo áp thấp',
                  enabled: _lowVoltEnabled,
                  onToggle: (v) => setState(() => _lowVoltEnabled = v),
                  child: _lowVoltEnabled
                      ? _thresholdField(
                          controller: _lowVoltCtrl,
                          label: 'Ngưỡng tối thiểu (V)',
                          min: 100,
                          max: 230,
                        )
                      : null,
                ),
                _warningCard(
                  title: 'Cảnh báo áp cao',
                  enabled: _highVoltEnabled,
                  onToggle: (v) => setState(() => _highVoltEnabled = v),
                  child: _highVoltEnabled
                      ? _thresholdField(
                          controller: _highVoltCtrl,
                          label: 'Ngưỡng tối đa (V)',
                          min: 220,
                          max: 300,
                        )
                      : null,
                ),
                _warningCard(
                  title: 'Cảnh báo mất pha',
                  enabled: _phaseLossEnabled,
                  onToggle: (v) => setState(() => _phaseLossEnabled = v),
                ),

                const SizedBox(height: 80), // Chừa khoảng trống cho bottomSheet
              ],
            ),
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFF5FAFF), // xanh rất nhạt (gần trắng)
                Color(0xFFE8F1FC), // xanh nhạt hơn
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: ElevatedButton.icon(
            onPressed: _save,
            label: const Text(
              'Lưu',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: CustomColors.appbarColor,
            ),
          ),
        ),
      ),
    );
  }

  /* --------- WIDGET BUILDERS --------- */
  Widget _warningCard({
    required String title,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    Widget? child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: _box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hàng tiêu đề + switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              Switch(
                value: enabled, onChanged: onToggle,
                // MÀU KHI BẬT
                activeColor: Colors.green,
                activeTrackColor: Colors.green.shade200,

                // MÀU KHI TẮT
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade400,
              ),
            ],
          ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _thresholdField({
    required TextEditingController controller,
    required String label,
    required double min,
    required double max,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixText: 'V',
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
          final v = double.tryParse((txt ?? '').replaceAll(',', '.')) ?? 0;
          if (v < min || v > max) return 'Giá trị phải $min - $max V';
          return null;
        },
      ),
    );
  }

  /* --------- DECORATION --------- */
  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      );
}
