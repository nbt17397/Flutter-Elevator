import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../components/app_background.dart';
import '../../services/mqtt/mqtt_provider.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Color scadaBlue = const Color(0xFF1A237E);
  final Map<String, Timer> _debounceTimers = {};

  final List<String> topics = [
    'controller_3/blower_ena_1/state',
    'controller_3/blower_runtime_1_h/state',
    'controller_3/blower_runtime_1_m/state',
    'controller_3/blower_stoptime_1_h/state',
    'controller_3/blower_stoptime_1_m/state',
    'controller_3/blower_ena_2/state',
    'controller_3/blower_runtime_2_h/state',
    'controller_3/blower_runtime_2_m/state',
    'controller_3/blower_runtime_2_d/state',
    'controller_3/blower_runtime_2_mth/state',
    'controller_3/blower_stoptime_2_h/state',
    'controller_3/blower_stoptime_2_m/state',
    'controller_3/blower_stoptime_2_d/state',
    'controller_3/blower_stoptime_2_mth/state',
    'controller_3/blower_set/state',
    'controller_3/flow_fan_1_set/state',
    'controller_3/flow_fan_2_set/state',
    'controller_3/flow_fan_3_set/state',
    'controller_3/do_h/state',
    'controller_3/do_l/state',
    'controller_3/do_level_h/state',
    'controller_3/do_level_l/state',
    'controller_3/temp_h/state',
    'controller_3/temp_l/state',
    'controller_3/ph_h/state',
    'controller_3/ph_l/state',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mqtt = Provider.of<MqttProvider>(context, listen: false);
      for (var topic in topics) mqtt.subscribeTopic(topic);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var timer in _debounceTimers.values) timer.cancel();
    super.dispose();
  }

  void _onTextFieldChanged(MqttProvider mqtt, String topicSet, String val) {
    if (_debounceTimers[topicSet]?.isActive ?? false)
      _debounceTimers[topicSet]?.cancel();
    _debounceTimers[topicSet] = Timer(const Duration(milliseconds: 800), () {
      if (val.isNotEmpty) {
        final double? status = double.tryParse(val);
        if (status != null) {
          mqtt.publishMessage(topicSet, jsonEncode({"status": status}));
        }
      }
    });
  }

  String _getV(MqttProvider mqtt, String topic) => mqtt.messages[topic] ?? "";

  @override
  Widget build(BuildContext context) {
    // GestureDetector bọc ngoài cùng để xử lý click ra ngoài
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppBackground(
        child: Consumer<MqttProvider>(
          builder: (context, mqtt, child) {
            return Scaffold(
              backgroundColor: Colors.transparent,
              resizeToAvoidBottomInset: true,
              appBar: AppBar(
                backgroundColor: Colors.white.withOpacity(0.9),
                elevation: 0,
                title: Text("CẤU HÌNH HỆ THỐNG",
                    style: TextStyle(
                        color: scadaBlue,
                        fontWeight: FontWeight.w900,
                        fontSize: 18)),
                centerTitle: true,
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: scadaBlue,
                  unselectedLabelColor: Colors.black38,
                  indicatorWeight: 4,
                  indicatorColor: scadaBlue,
                  tabs: const [Tab(text: "LỊCH TRÌNH"), Tab(text: "THÔNG SỐ")],
                ),
              ),
              body: SafeArea(
                bottom: true,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildScheduleTab(mqtt),
                    _buildSystemTab(mqtt),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _mqttTextField(MqttProvider mqtt, String topicSet, String currentVal,
      {double width = 80}) {
    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12)),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: currentVal)
          ..selection = TextSelection.collapsed(offset: currentVal.length),
        onChanged: (val) => _onTextFieldChanged(mqtt, topicSet, val),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(bottom: 12),
          prefixStyle: TextStyle(
              color: scadaBlue, fontSize: 11, fontWeight: FontWeight.bold),
          suffixStyle: const TextStyle(color: Colors.black54, fontSize: 11),
        ),
      ),
    );
  }

  // --- CÁC HÀM BUILD TAB (GIỮ NGUYÊN) ---

  Widget _buildScheduleTab(MqttProvider mqtt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGroupPanel(
            title: "CHẠY THEO CHU KỲ (MODE 1)",
            icon: Icons.loop_rounded,
            child: Column(children: [
              _buildSwitchRow(
                  mqtt,
                  "Kích hoạt chu kỳ",
                  'controller_3/blower_ena_1/state',
                  'controller_3/blower_ena_1/set'),
              _buildDualInput(
                  mqtt,
                  "Thời gian Chạy (Giờ/Phút)",
                  'controller_3/blower_runtime_1_h/state',
                  'controller_3/blower_runtime_1_h/set',
                  'controller_3/blower_runtime_1_m/state',
                  'controller_3/blower_runtime_1_m/set'),
              _buildDualInput(
                  mqtt,
                  "Thời gian Dừng (Giờ/Phút)",
                  'controller_3/blower_stoptime_1_h/state',
                  'controller_3/blower_stoptime_1_h/set',
                  'controller_3/blower_stoptime_1_m/state',
                  'controller_3/blower_stoptime_1_m/set'),
            ])),
        const SizedBox(height: 16),
        _buildGroupPanel(
            title: "CHẠY THEO LỊCH (MODE 2)",
            icon: Icons.calendar_today_rounded,
            child: Column(children: [
              _buildSwitchRow(
                  mqtt,
                  "Kích hoạt lịch trình",
                  'controller_3/blower_ena_2/state',
                  'controller_3/blower_ena_2/set'),
              _buildDualInput(
                  mqtt,
                  "Bật: Giờ / Phút",
                  'controller_3/blower_runtime_2_h/state',
                  'controller_3/blower_runtime_2_h/set',
                  'controller_3/blower_runtime_2_m/state',
                  'controller_3/blower_runtime_2_m/set'),
              _buildDualInput(
                  mqtt,
                  "Bật: Ngày / Tháng",
                  'controller_3/blower_runtime_2_d/state',
                  'controller_3/blower_runtime_2_d/set',
                  'controller_3/blower_runtime_2_mth/state',
                  'controller_3/blower_runtime_2_mth/set'),
              const Divider(height: 30, color: Colors.black12),
              _buildDualInput(
                  mqtt,
                  "Tắt: Giờ / Phút",
                  'controller_3/blower_stoptime_2_h/state',
                  'controller_3/blower_stoptime_2_h/set',
                  'controller_3/blower_stoptime_2_m/state',
                  'controller_3/blower_stoptime_2_m/set'),
              _buildDualInput(
                  mqtt,
                  "Tắt: Ngày / Tháng",
                  'controller_3/blower_stoptime_2_d/state',
                  'controller_3/blower_stoptime_2_d/set',
                  'controller_3/blower_stoptime_2_mth/state',
                  'controller_3/blower_stoptime_2_mth/set'),
            ])),
      ],
    );
  }

  Widget _buildSystemTab(MqttProvider mqtt) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGroupPanel(
            title: "NGƯỠNG CẢM BIẾN",
            icon: Icons.analytics_outlined,
            child: Column(children: [
              _buildRangeInput(
                  mqtt,
                  "DO (mg/l)",
                  Colors.blue,
                  'controller_3/do_l/state',
                  'controller_3/do_l/set',
                  'controller_3/do_h/state',
                  'controller_3/do_h/set'),
              _buildRangeInput(
                  mqtt,
                  "DO (%)",
                  Colors.cyan,
                  'controller_3/do_level_l/state',
                  'controller_3/do_level_l/set',
                  'controller_3/do_level_h/state',
                  'controller_3/do_level_h/set'),
              _buildRangeInput(
                  mqtt,
                  "Độ pH",
                  Colors.green,
                  'controller_3/ph_l/state',
                  'controller_3/ph_l/set',
                  'controller_3/ph_h/state',
                  'controller_3/ph_h/set'),
              _buildRangeInput(
                  mqtt,
                  "Nhiệt độ",
                  Colors.orange,
                  'controller_3/temp_l/state',
                  'controller_3/temp_l/set',
                  'controller_3/temp_h/state',
                  'controller_3/temp_h/set'),
            ])),
        const SizedBox(height: 16),
        _buildGroupPanel(
            title: "TẦN SỐ THIẾT BỊ",
            icon: Icons.settings_input_component,
            child: Column(children: [
              _buildFreqInput(
                  mqtt,
                  "Máy thổi khí",
                  'controller_3/blower_set/state',
                  'controller_3/blower_set/set'),
              _buildFreqInput(
                  mqtt,
                  "Quạt đảo 1",
                  'controller_3/flow_fan_1_set/state',
                  'controller_3/flow_fan_1_set/set'),
              _buildFreqInput(
                  mqtt,
                  "Quạt đảo 2",
                  'controller_3/flow_fan_2_set/state',
                  'controller_3/flow_fan_2_set/set'),
              _buildFreqInput(
                  mqtt,
                  "Quạt đảo 3",
                  'controller_3/flow_fan_3_set/state',
                  'controller_3/flow_fan_3_set/set'),
            ])),
      ],
    );
  }

  Widget _buildGroupPanel(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: scadaBlue, size: 20),
          const SizedBox(width: 10),
          Text(title,
              style: TextStyle(
                  color: scadaBlue, fontWeight: FontWeight.w900, fontSize: 13))
        ]),
        const Divider(height: 24, color: Colors.black12),
        child,
      ]),
    );
  }

  Widget _buildDualInput(MqttProvider mqtt, String label, String s1, String t1,
          String s2, String t2) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13))),
            _mqttTextField(mqtt, t1, _getV(mqtt, s1), width: 70),
            const SizedBox(width: 10),
            _mqttTextField(mqtt, t2, _getV(mqtt, s2), width: 70)
          ]));

  Widget _buildRangeInput(MqttProvider mqtt, String label, Color color,
          String sl, String tl, String sh, String th) =>
      Padding(
        
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13))),
            _mqttTextField(mqtt, tl, _getV(mqtt, sl)),
            const SizedBox(width: 8),
            _mqttTextField(mqtt, th, _getV(mqtt, sh))
          ]));

  Widget _buildFreqInput(
          MqttProvider mqtt, String label, String stateT, String setT) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            _mqttTextField(mqtt, setT, _getV(mqtt, stateT), width: 90)
          ]));

  Widget _buildSwitchRow(
      MqttProvider mqtt, String title, String stateTopic, String setTopic) {
    bool isEnabled = _getV(mqtt, stateTopic) == '1';
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      Switch.adaptive(
          value: isEnabled,
          activeColor: scadaBlue,
          inactiveThumbColor: Colors.grey[400], // Nút tròn màu xám khi OFF
          inactiveTrackColor: Colors.grey[300],
          onChanged: (v) =>
              mqtt.publishMessage(setTopic, jsonEncode({"status": v ? 1 : 0}))),
    ]);
  }
}
