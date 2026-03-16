// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../components/app_background.dart';
// import '../../services/mqtt/mqtt_provider.dart';

// class SystemSettingsScreen extends StatefulWidget {
//   const SystemSettingsScreen({super.key});

//   @override
//   State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
// }

// class _SystemSettingsScreenState extends State<SystemSettingsScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final Color scadaBlue = const Color(0xFF1A237E);
//   final Map<String, Timer> _debounceTimers = {};

//   // Quản lý thiết bị cho Tab Lịch Trình
//   String _selectedDevicePrefix = 'blower';
//   final List<Map<String, String>> _devices = [
//     {'id': 'blower', 'name': 'Máy Thổi Khí'},
//     {'id': 'flow_fan_1', 'name': 'Quạt Đảo 1'},
//     {'id': 'flow_fan_2', 'name': 'Quạt Đảo 2'},
//     {'id': 'flow_fan_3', 'name': 'Quạt Đảo 3'},
//   ];

//   // Tổng hợp tất cả topic cần subscribe
//   List<String> get allTopics {
//     List<String> topics = [];
//     // Topics lịch trình cho cả 4 thiết bị
//     for (var dev in _devices) {
//       String p = dev['id']!;
//       topics.addAll([
//         'controller_3/${p}_ena_1/state',
//         'controller_3/${p}_runtime_1_h/state',
//         'controller_3/${p}_runtime_1_m/state',
//         'controller_3/${p}_stoptime_1_h/state',
//         'controller_3/${p}_stoptime_1_m/state',
//         'controller_3/${p}_ena_2/state',
//         'controller_3/${p}_runtime_2_h/state',
//         'controller_3/${p}_runtime_2_m/state',
//         'controller_3/${p}_runtime_2_d/state',
//         'controller_3/${p}_runtime_2_mth/state',
//         'controller_3/${p}_stoptime_2_h/state',
//         'controller_3/${p}_stoptime_2_m/state',
//         'controller_3/${p}_stoptime_2_d/state',
//         'controller_3/${p}_stoptime_2_mth/state',
//       ]);
//     }
//     // Topics thông số hệ thống & Tần số
//     topics.addAll([
//       'controller_3/blower_set/state',
//       'controller_3/flow_fan_1_set/state',
//       'controller_3/flow_fan_2_set/state',
//       'controller_3/flow_fan_3_set/state',
//       'controller_3/do_h/state',
//       'controller_3/do_l/state',
//       'controller_3/do_level_h/state',
//       'controller_3/do_level_l/state',
//       'controller_3/temp_h/state',
//       'controller_3/temp_l/state',
//       'controller_3/ph_h/state',
//       'controller_3/ph_l/state',
//     ]);
//     return topics;
//   }

//   late MqttProvider _mqttProvider;

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Lấy provider tại đây là an toàn nhất vì context vẫn ổn định
//     _mqttProvider = Provider.of<MqttProvider>(context, listen: false);
//   }

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final mqtt = Provider.of<MqttProvider>(context, listen: false);
//       for (var topic in allTopics) {
//         mqtt.subscribeTopic(topic);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     for (var topic in allTopics) {
//       _mqttProvider.unsubscribeTopic(topic);
//     }

//     for (var timer in _debounceTimers.values) {
//       timer.cancel();
//     }
//     _tabController.dispose();

//     super.dispose();
//   }

//   void _onTextFieldChanged(MqttProvider mqtt, String topicSet, String val) {
//     _debounceTimers[topicSet]?.cancel();
//     _debounceTimers[topicSet] = Timer(const Duration(milliseconds: 800), () {
//       final double? status = double.tryParse(val);
//       if (status != null) {
//         mqtt.publishMessage(topicSet, jsonEncode({"status": status}));
//       }
//     });
//   }

//   String _getV(MqttProvider mqtt, String topic) => mqtt.messages[topic] ?? "";

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: AppBackground(
//         child: Consumer<MqttProvider>(
//           builder: (context, mqtt, child) {
//             return Scaffold(
//               backgroundColor: Colors.transparent,
//               resizeToAvoidBottomInset: true,
//               appBar: AppBar(
//                 backgroundColor: Colors.white.withOpacity(0.9),
//                 elevation: 0,
//                 title: Text("CẤU HÌNH HỆ THỐNG",
//                     style: TextStyle(
//                         color: scadaBlue,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 18)),
//                 bottom: TabBar(
//                   controller: _tabController,
//                   labelColor: scadaBlue,
//                   indicatorColor: scadaBlue,
//                   tabs: const [Tab(text: "LỊCH TRÌNH"), Tab(text: "THÔNG SỐ")],
//                 ),
//               ),
//               body: TabBarView(
//                 controller: _tabController,
//                 children: [
//                   _buildScheduleTab(mqtt),
//                   _buildSystemTab(mqtt),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   // --- TAB 1: LỊCH TRÌNH ---
//   Widget _buildScheduleTab(MqttProvider mqtt) {
//     String p = _selectedDevicePrefix;
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//       children: [
//         _buildDeviceSelector(),
//         const SizedBox(height: 16),
//         _buildGroupPanel(
//             title: "CHẠY THEO CHU KỲ (MODE 1)",
//             icon: Icons.loop_rounded,
//             child: Column(children: [
//               _buildSwitchRow(
//                   mqtt,
//                   "Kích hoạt chu kỳ",
//                   'controller_3/${p}_ena_1/state',
//                   'controller_3/${p}_ena_1/set'),
//               _buildDualInput(
//                   mqtt,
//                   "Chạy (Giờ/Phút)",
//                   'controller_3/${p}_runtime_1_h/state',
//                   'controller_3/${p}_runtime_1_h/set',
//                   'controller_3/${p}_runtime_1_m/state',
//                   'controller_3/${p}_runtime_1_m/set'),
//               _buildDualInput(
//                   mqtt,
//                   "Dừng (Giờ/Phút)",
//                   'controller_3/${p}_stoptime_1_h/state',
//                   'controller_3/${p}_stoptime_1_h/set',
//                   'controller_3/${p}_stoptime_1_m/state',
//                   'controller_3/${p}_stoptime_1_m/set'),
//             ])),
//         const SizedBox(height: 16),
//         _buildGroupPanel(
//             title: "CHẠY THEO LỊCH (MODE 2)",
//             icon: Icons.calendar_today_rounded,
//             child: Column(children: [
//               _buildSwitchRow(
//                   mqtt,
//                   "Kích hoạt lịch trình",
//                   'controller_3/${p}_ena_2/state',
//                   'controller_3/${p}_ena_2/set'),
//               _buildDualInput(
//                   mqtt,
//                   "Bật: Giờ/Phút",
//                   'controller_3/${p}_runtime_2_h/state',
//                   'controller_3/${p}_runtime_2_h/set',
//                   'controller_3/${p}_runtime_2_m/state',
//                   'controller_3/${p}_runtime_2_m/set'),
//               _buildDualInput(
//                   mqtt,
//                   "Bật: Ngày/Tháng",
//                   'controller_3/${p}_runtime_2_d/state',
//                   'controller_3/${p}_runtime_2_d/set',
//                   'controller_3/${p}_runtime_2_mth/state',
//                   'controller_3/${p}_runtime_2_mth/set'),
//               const Divider(height: 30),
//               _buildDualInput(
//                   mqtt,
//                   "Tắt: Giờ/Phút",
//                   'controller_3/${p}_stoptime_2_h/state',
//                   'controller_3/${p}_stoptime_2_h/set',
//                   'controller_3/${p}_stoptime_2_m/state',
//                   'controller_3/${p}_stoptime_2_m/set'),
//               _buildDualInput(
//                   mqtt,
//                   "Tắt: Ngày/Tháng",
//                   'controller_3/${p}_stoptime_2_d/state',
//                   'controller_3/${p}_stoptime_2_d/set',
//                   'controller_3/${p}_stoptime_2_mth/state',
//                   'controller_3/${p}_stoptime_2_mth/set'),
//             ])),
//       ],
//     );
//   }

//   // --- TAB 2: THÔNG SỐ (FIXED) ---
//   Widget _buildSystemTab(MqttProvider mqtt) {
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
//       children: [
//         _buildGroupPanel(
//             title: "NGƯỠNG CẢM BIẾN (MIN - MAX)",
//             icon: Icons.analytics_outlined,
//             child: Column(children: [
//               _buildRangeInput(
//                   mqtt,
//                   "DO (mg/l)",
//                   Colors.blue,
//                   'controller_3/do_l/state', 'controller_3/do_l/set',
//                   'controller_3/do_h/state', 'controller_3/do_h/set'),
//               _buildRangeInput(
//                   mqtt,
//                   "DO (%)",
//                   Colors.cyan,
//                   'controller_3/do_level_l/state', 'controller_3/do_level_l/set',
//                   'controller_3/do_level_h/state', 'controller_3/do_level_h/set'),
//               _buildRangeInput(
//                   mqtt,
//                   "Độ pH",
//                   Colors.green,
//                   'controller_3/ph_l/state', 'controller_3/ph_l/set',
//                   'controller_3/ph_h/state', 'controller_3/ph_h/set'),
//               _buildRangeInput(
//                   mqtt,
//                   "Nhiệt độ",
//                   Colors.orange,
//                   'controller_3/temp_l/state', 'controller_3/temp_l/set',
//                   'controller_3/temp_h/state', 'controller_3/temp_h/set'),
//             ])),
//         const SizedBox(height: 16),
//         _buildGroupPanel(
//             title: "TẦN SỐ THIẾT BỊ (Hz)",
//             icon: Icons.settings_input_component,
//             child: Column(children: [
//               _buildFreqInput(mqtt, "Máy thổi khí", 'controller_3/blower_set/state', 'controller_3/blower_set/set'),
//               _buildFreqInput(mqtt, "Quạt đảo 1", 'controller_3/flow_fan_1_set/state', 'controller_3/flow_fan_1_set/set'),
//               _buildFreqInput(mqtt, "Quạt đảo 2", 'controller_3/flow_fan_2_set/state', 'controller_3/flow_fan_2_set/set'),
//               _buildFreqInput(mqtt, "Quạt đảo 3", 'controller_3/flow_fan_3_set/state', 'controller_3/flow_fan_3_set/set'),
//             ])),
//       ],
//     );
//   }

//   // Cập nhật Helper Widget để hiển thị chữ Min/Max
//   Widget _buildRangeInput(MqttProvider mqtt, String label, Color color,
//       String sl, String tl, String sh, String th) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Row(
//         children: [
//           Container(
//             width: 4,
//             height: 24,
//             decoration: BoxDecoration(
//                 color: color, borderRadius: BorderRadius.circular(2)),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(label,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold, fontSize: 13)),
//           ),
//           // Cột Min
//           Column(
//             children: [
//               const Text("Min", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               _mqttTextField(mqtt, tl, _getV(mqtt, sl), width: 70),
//             ],
//           ),
//           const SizedBox(width: 12),
//           // Cột Max
//           Column(
//             children: [
//               const Text("Max", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 4),
//               _mqttTextField(mqtt, th, _getV(mqtt, sh), width: 70),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // --- REUSABLE COMPONENTS ---

//   Widget _buildDeviceSelector() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: scadaBlue.withOpacity(0.3))),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: _selectedDevicePrefix,
//           isExpanded: true,
//           onChanged: (val) => setState(() => _selectedDevicePrefix = val!),
//           items: _devices
//               .map((d) => DropdownMenuItem(
//                   value: d['id'],
//                   child: Text(d['name']!,
//                       style: TextStyle(
//                           color: scadaBlue, fontWeight: FontWeight.bold))))
//               .toList(),
//         ),
//       ),
//     );
//   }

//   Widget _mqttTextField(MqttProvider mqtt, String topicSet, String currentVal,
//       {double width = 80}) {
//     return SizedBox(
//       width: width,
//       height: 38,
//       child: TextField(
//         key: ValueKey(topicSet), // Đảm bảo không bị mất focus khi dữ liệu về
//         textAlign: TextAlign.center,
//         keyboardType: const TextInputType.numberWithOptions(decimal: true),
//         controller: TextEditingController(text: currentVal)
//           ..selection = TextSelection.collapsed(offset: currentVal.length),
//         onChanged: (val) => _onTextFieldChanged(mqtt, topicSet, val),
//         style: const TextStyle(
//             fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: Colors.grey[100],
//           contentPadding: EdgeInsets.zero,
//           border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8),
//               borderSide: BorderSide.none),
//         ),
//       ),
//     );
//   }

//   Widget _buildGroupPanel(
//       {required String title, required IconData icon, required Widget child}) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.9),
//           borderRadius: BorderRadius.circular(12),
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
//           ]),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Row(children: [
//           Icon(icon, color: scadaBlue, size: 20),
//           const SizedBox(width: 8),
//           Text(title,
//               style: TextStyle(
//                   color: scadaBlue, fontWeight: FontWeight.w900, fontSize: 13))
//         ]),
//         const Divider(height: 24),
//         child,
//       ]),
//     );
//   }

//   Widget _buildSwitchRow(
//       MqttProvider mqtt, String title, String sT, String setT) {
//     bool isEnabled = _getV(mqtt, sT) == '1';
//     return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//       Text(title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//       Switch.adaptive(
//           value: isEnabled,
//           activeColor: scadaBlue,
//           activeTrackColor: scadaBlue.withOpacity(0.5),
//           inactiveThumbColor: Colors.redAccent,
//           inactiveTrackColor: Colors.redAccent.withOpacity(0.2),
//           onChanged: (v) =>
//               mqtt.publishMessage(setT, jsonEncode({"status": v ? 1 : 0}))),
//     ]);
//   }

//   Widget _buildDualInput(MqttProvider mqtt, String label, String s1, String t1,
//           String s2, String t2) =>
//       Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           child: Row(children: [
//             Expanded(
//                 child: Text(label,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.bold, fontSize: 13))),
//             _mqttTextField(mqtt, t1, _getV(mqtt, s1), width: 65),
//             const SizedBox(width: 8),
//             _mqttTextField(mqtt, t2, _getV(mqtt, s2), width: 65)
//           ]));

//   Widget _buildFreqInput(
//           MqttProvider mqtt, String label, String sT, String setT) =>
//       Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6),
//           child:
//               Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text(label,
//                 style:
//                     const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
//             _mqttTextField(mqtt, setT, _getV(mqtt, sT), width: 90)
//           ]));
// }

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

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final Color scadaBlue = const Color(0xFF1A237E);
  final Map<String, Timer> _debounceTimers = {};
  late MqttProvider _mqttProvider;

  // Danh sách các topic Thông số cần quản lý
  final List<String> _systemTopics = [
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _mqttProvider = Provider.of<MqttProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var topic in _systemTopics) {
        _mqttProvider.subscribeTopic(topic);
      }
      // Tự động refresh dữ liệu khi vừa vào màn hình
      _refreshData(_mqttProvider);
    });
  }

  @override
  void dispose() {
    for (var topic in _systemTopics) {
      _mqttProvider.unsubscribeTopic(topic);
    }
    for (var timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  // Hàm Refresh dữ liệu
  void _refreshData(MqttProvider mqtt) {
    mqtt.publishMessage('controller_3/retain/set', jsonEncode({"status": 1}));
  }

  void _onTextFieldChanged(MqttProvider mqtt, String topicSet, String val) {
    _debounceTimers[topicSet]?.cancel();
    _debounceTimers[topicSet] = Timer(const Duration(milliseconds: 800), () {
      final double? status = double.tryParse(val);
      if (status != null) {
        mqtt.publishMessage(topicSet, jsonEncode({"status": status}));
      }
    });
  }

  String _getV(MqttProvider mqtt, String topic) => mqtt.messages[topic] ?? "";

  @override
  Widget build(BuildContext context) {
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
                title: Text(
                  "THÔNG SỐ HỆ THỐNG",
                  style: TextStyle(
                    color: scadaBlue,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh_rounded, color: scadaBlue),
                    tooltip: "Lấy dữ liệu mới",
                    onPressed: () => _refreshData(mqtt),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                children: [
                  _buildGroupPanel(
                    title: "NGƯỠNG CẢM BIẾN (MIN - MAX)",
                    icon: Icons.analytics_outlined,
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGroupPanel(
                    title: "TẦN SỐ THIẾT BỊ (Hz)",
                    icon: Icons.settings_input_component,
                    child: Column(
                      children: [
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
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- COMPONENT WIDGETS ---

  Widget _buildGroupPanel(
      {required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: scadaBlue, size: 20),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: scadaBlue, fontWeight: FontWeight.w900, fontSize: 13))
        ]),
        const Divider(height: 24),
        child,
      ]),
    );
  }

  Widget _buildRangeInput(MqttProvider mqtt, String label, Color color,
      String sl, String tl, String sh, String th) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          Column(
            children: [
              const Text("Min",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _mqttTextField(mqtt, tl, _getV(mqtt, sl), width: 70),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              const Text("Max",
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              _mqttTextField(mqtt, th, _getV(mqtt, sh), width: 70),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFreqInput(
      MqttProvider mqtt, String label, String sT, String setT) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          _mqttTextField(mqtt, setT, _getV(mqtt, sT), width: 90)
        ],
      ),
    );
  }

  Widget _mqttTextField(MqttProvider mqtt, String topicSet, String currentVal,
      {double width = 80}) {
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        key: ValueKey(topicSet),
        textAlign: TextAlign.center,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: TextEditingController(text: currentVal)
          ..selection = TextSelection.collapsed(offset: currentVal.length),
        onChanged: (val) => _onTextFieldChanged(mqtt, topicSet, val),
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
