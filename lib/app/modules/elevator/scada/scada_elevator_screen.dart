import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/elevator/alarm/alarm_elevator_screen.dart';
import 'package:elevator/app/modules/elevator/setting/setting_elevator_screen.dart';
import 'package:elevator/app/modules/elevator/setting/spec_elevator_screen.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../report/menu_report_screen.dart';

class ScadaElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const ScadaElevatorScreen({super.key, required this.board});

  @override
  State<ScadaElevatorScreen> createState() => _ScadaElevatorScreenState();
}

class _ScadaElevatorScreenState extends State<ScadaElevatorScreen> {
  BoardDB get board => widget.board;
  String get topic => "from-client/${board.deviceId}";
  // final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isStreaming = false;
  MqttProvider? mqttProvider;

  final List<Map<String, dynamic>> items = [
    {
      "icon": Icons.local_fire_department,
      "label": "Cảnh báo cháy",
      "color": Colors.red
    },
    {"icon": Icons.warning, "label": "Quá tải", "color": Colors.orange},
    {"icon": Icons.stop_circle, "label": "Dừng khẩn", "color": Colors.blue},
    {"icon": Icons.phone, "label": "Liên lạc", "color": Colors.green},
    {"icon": Icons.medical_services, "label": "Cứu hộ", "color": Colors.purple},
    {"icon": Icons.star, "label": "Trạng thái VIP", "color": Colors.yellow},
  ];

  @override
  void initState() {
    super.initState();
    // _localRenderer.initialize(); // Chỉ khởi tạo, chưa chạy stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mqttProvider = Provider.of<MqttProvider>(context, listen: false);
      mqttProvider?.subscribeTopic(topic);
    });
  }

  @override
  void dispose() {
    // _stopStream();
    // _localRenderer.dispose();
    mqttProvider?.unsubscribeTopic(topic);
    super.dispose();
  }

  // Future<void> _startStream() async {
  //   MediaStream stream = await navigator.mediaDevices.getUserMedia({
  //     'video': true,
  //     'audio': false,
  //   });

  //   setState(() {
  //     _localRenderer.srcObject = stream;
  //     _isStreaming = true;
  //   });
  // }

  // void _stopStream() {
  //   _localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
  //   _localRenderer.srcObject = null;
  // }

  // void _toggleStream() {
  //   setState(() {
  //     if (_isStreaming) {
  //       _stopStream();
  //     } else {
  //       _startStream();
  //     }
  //     _isStreaming = !_isStreaming;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Consumer<MqttProvider>(
          builder: (context, mqttProvider, child) {
            return Text(
              board.name!,
              style: TextStyle(
                color: mqttProvider.isConnected ? Colors.green : Colors.red,
              ),
            );
          },
        ),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            itemBuilder: (BuildContext bc) => [
              PopupMenuItem(
                  value: "error_code",
                  child:
                      Text('Mã lỗi hệ thống', style: TextStyle(fontSize: 14))),
              PopupMenuItem(
                  value: "parameters",
                  child: Text('Thông số kỹ thuật',
                      style: TextStyle(fontSize: 14))),
              PopupMenuItem(
                  value: "alarms",
                  child: Text('Cảnh báo', style: TextStyle(fontSize: 14))),
              PopupMenuItem(
                  value: "settings",
                  child:
                      Text('Cài đặt thông số', style: TextStyle(fontSize: 14))),
              PopupMenuItem(
                  value: "datas",
                  child:
                      Text('Tra cứu dữ liệu', style: TextStyle(fontSize: 14))),
            ],
            onSelected: (route) {
              switch (route) {
                case 'datas':
                  {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) =>
                                MenuReportScreen(board: widget.board)));
                    break;
                  }
                case 'settings':
                  {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) =>
                                SettingElevatorScreen(board: widget.board)));
                    break;
                  }
                case 'alarms':
                  {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) => AlarmElevatorScreen(
                                boardID: widget.board.id!)));
                    break;
                  }
                case 'parameters':
                  {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (_) =>
                                SpecElevatorScreen(board: widget.board)));
                    break;
                  }
                default:
                  {
                    break;
                  }
              }
            },
          ),
        ],
      ),
      body: Consumer<MqttProvider>(builder: (context, mqttProvider, child) {
        String message = mqttProvider.messages[topic] ?? "Chưa có dữ liệu";
        print(message);
        return Container(
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(
                      6, 6, 6, 0), // Tạo khoảng cách giữa khung và nội dung
                  decoration: BoxDecoration(
                    color: Colors.white, // Màu khung bên ngoài
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: size.height * .22,
                        width: size.width,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // RTCVideoView(
                            //   _localRenderer,
                            //   objectFit: RTCVideoViewObjectFit
                            //       .RTCVideoViewObjectFitCover,
                            // ),
                            Positioned(
                              child: GestureDetector(
                                // onTap: _toggleStream,
                                child: Icon(
                                  _isStreaming
                                      ? Icons.stop_circle
                                      : Icons.play_circle,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.notifications_active),
                                Text('Cảnh báo', style: TextStyle(fontSize: 9))
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.video_library),
                                Text('Xem lại', style: TextStyle(fontSize: 9))
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text(
                    'THÔNG SỐ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Container(
                  height: size.height * .2,
                  width: size.width,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          flex: 5,
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            color: Colors.black.withOpacity(0.3),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.green,
                                        child: Text(
                                          "Mở",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Lottie.asset(
                                                  'assets/jsons/arrow-up.json'),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.white)),
                                          child: Center(
                                              child: Text(
                                            '1',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          )),
                                        )),
                                        Expanded(
                                          child: Center(
                                            child: SizedBox(
                                              width: 40,
                                              height: 40,
                                              child: Lottie.asset(
                                                  'assets/jsons/arrow-down.json'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Colors.grey,
                                        child: Text(
                                          "Đóng",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    )),
                              ],
                            ),
                          )),
                      Expanded(
                        flex: 4,
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          color: Colors.black.withOpacity(0.3),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  enabled: false,
                                  initialValue: "4.5 m/s",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: "Tốc độ",
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    filled: false,
                                    fillColor: Colors.black.withOpacity(0.3),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              // Ô hiển thị Trọng tải
                              Expanded(
                                child: TextFormField(
                                  readOnly: true,
                                  enabled: false,
                                  initialValue: "200 kg",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    labelText:
                                        "Tải trọng", // Luôn hiển thị trên cùng
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    filled: false,
                                    fillColor: Colors.black.withOpacity(0.3),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6),
                                      borderSide:
                                          BorderSide(color: Colors.white60),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 15, bottom: 5),
                  child: Text(
                    'CẢNH BÁO',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                Container(
                  height: size.height * .22,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: items
                              .sublist(0, 3)
                              .map((item) => _buildGridItem(item))
                              .toList(),
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: items
                              .sublist(3, 6)
                              .map((item) => _buildGridItem(item))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildGridItem(Map<String, dynamic> item) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: item["color"].withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item["icon"], color: Colors.white, size: 30),
            SizedBox(height: 5),
            Text(
              item["label"],
              style: TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
