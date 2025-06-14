import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

import '../../../data/response/register_response.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final RegisterDB register;
  const DeviceSettingsScreen({super.key, required this.register});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  double flowRate = 30; // Lưu lượng nước L/phút
  double pressure = 1.2; // Áp suất bar
  bool autoMode = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt - ${widget.register.name}'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSliderCard(
              label: 'Lưu lượng nước (L/phút)',
              value: flowRate,
              min: 10,
              max: 100,
              onChanged: (v) => setState(() => flowRate = v),
            ),
            const SizedBox(height: 16),
            _buildSliderCard(
              label: 'Áp suất (bar)',
              value: pressure,
              min: 0.5,
              max: 5.0,
              onChanged: (v) => setState(() => pressure = double.parse(v.toStringAsFixed(1))),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withOpacity(0.7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: SwitchListTile(
                title: const Text('Chế độ tự động'),
                value: autoMode,
                onChanged: (value) => setState(() => autoMode = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
