import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_background.dart';
import '../../services/mqtt/mqtt_provider.dart';

class HomeScadaScreen extends StatefulWidget {
  const HomeScadaScreen({super.key});

  @override
  State<HomeScadaScreen> createState() => _HomeScadaScreenState();
}

class _HomeScadaScreenState extends State<HomeScadaScreen> {
  final List<String> topics = [
    'controller_3/auto/state',
    'controller_3/blower_ctr/state',
    'controller_3/flow_fan_1_ctr/state',
    'controller_3/flow_fan_2_ctr/state',
    'controller_3/flow_fan_3_ctr/state',
    'controller_3/do/state',
    'controller_3/do_level/state',
    'controller_3/temp/state',
    'controller_3/ph/state',
  ];

  @override
  void initState() {
    super.initState();

    // Subscribe ngay khi vào screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqtt = Provider.of<MqttProvider>(context, listen: false);
      for (var topic in topics) {
        mqtt.subscribeTopic(topic);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttProvider>(
      builder: (context, mqtt, child) {
        return AppBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Column(
                children: [
                  _buildAppBar(mqtt),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: _buildPortrait(mqtt),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildAppBar(MqttProvider mqtt) {
    bool isAuto = mqtt.messages['controller_3/auto/state'] == '1';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.analytics_outlined,
              color: Color(0xFF1A237E), size: 24),
          const SizedBox(width: 10),
          const Text("AMVi",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF1A237E))),
          const Spacer(),
          _statusChip(isAuto ? "Tự động" : "Thủ công",
              isAuto ? Colors.blue : Colors.orange),
          const SizedBox(width: 10),
          _statusChip("Kết nối", mqtt.isConnected ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildPortrait(MqttProvider mqtt) {
    // Helper để lấy data từ map messages của Provider
    String getMsg(String topic) => mqtt.messages[topic] ?? "--";

    final List<Map<String, dynamic>> devices = [
      {
        'name': 'MÁY THỔI KHÍ',
        'hz': getMsg('controller_3/blower_ctr/state'),
        'topic': 'controller_3/blower_ctr/set',
        'icon': 'assets/images/blower.png'
      },
      {
        'name': 'QUẠT ĐẢO 1',
        'hz': getMsg('controller_3/flow_fan_1_ctr/state'),
        'topic': 'controller_3/flow_fan_1_ctr/set',
        'icon': 'assets/images/fan.png'
      },
      {
        'name': 'QUẠT ĐẢO 2',
        'hz': getMsg('controller_3/flow_fan_2_ctr/state'),
        'topic': 'controller_3/flow_fan_2_ctr/set',
        'icon': 'assets/images/fan.png'
      },
      {
        'name': 'QUẠT ĐẢO 3',
        'hz': getMsg('controller_3/flow_fan_3_ctr/state'),
        'topic': 'controller_3/flow_fan_3_ctr/set',
        'icon': 'assets/images/fan.png'
      },
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _sensorGroupContainer([
                _sensorRowItem(Icons.thermostat, "Nhiệt độ:",
                    getMsg('controller_3/temp/state')),
                const SizedBox(height: 8),
                _sensorRowItem(
                    Icons.water_drop, "pH:", getMsg('controller_3/ph/state')),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _sensorGroupContainer([
                _sensorRowItem(Icons.bubble_chart, "DO mg/l:",
                    getMsg('controller_3/do/state')),
                const SizedBox(height: 8),
                _sensorRowItem(Icons.percent, "DO %:",
                    getMsg('controller_3/do_level/state')),
              ]),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(" ĐIỀU KHIỂN THIẾT BỊ",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E))),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
            children:
                devices.map((dev) => _modernDeviceCard(dev, mqtt)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _modernDeviceCard(Map<String, dynamic> dev, MqttProvider mqtt) {
    double hzValue = double.tryParse(dev['hz']) ?? 0.0;
    bool isRunning = hzValue > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isRunning
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.2),
            width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            dev['icon'],
            width: 80,
            color: isRunning
                ? const Color.fromARGB(255, 18, 243, 70)
                : Colors.grey.withOpacity(0.5),
            colorBlendMode: BlendMode.modulate,
          ),
          Text(dev['name'],
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: Color(0xFF1A237E))),
          const SizedBox(height: 6),
          Text("${dev['hz']} Hz",
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _actionBtn(
                    Icons.play_arrow_rounded,
                    Colors.green,
                    isRunning
                        ? null
                        : () => mqtt.publishMessage(
                            dev['topic'], jsonEncode({"status": 1}))),
                const SizedBox(width: 8),
                _actionBtn(
                    Icons.stop_rounded,
                    Colors.red,
                    !isRunning
                        ? null
                        : () => mqtt.publishMessage(
                            dev['topic'], jsonEncode({"status": 0}))),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- RENDER HELPERS (Giữ nguyên style cũ của bạn) ---
  Widget _statusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5))),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _sensorGroupContainer(List<Widget> children) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFFA5D6F1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white, width: 2)),
        child: Column(children: children),
      );

  Widget _sensorRowItem(IconData icon, String label, String value) => Row(
        children: [
          Icon(icon, color: const Color(0xFF0D47A1), size: 18),
          const SizedBox(width: 4),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: Color(0xFF0D47A1)))),
          Container(
            width: 55,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.center,
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace')),
          ),
        ],
      );

  Widget _actionBtn(IconData icon, Color color, VoidCallback? onTap) =>
      Expanded(
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
                color: onTap == null
                    ? Colors.grey.withOpacity(0.1)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon,
                size: 22,
                color: onTap == null ? Colors.grey.withOpacity(0.3) : color),
          ),
        ),
      );
}
