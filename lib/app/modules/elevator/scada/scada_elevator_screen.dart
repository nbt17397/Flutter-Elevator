import 'package:elevator/app/components/blinking_brid_item.dart';
import 'package:elevator/app/components/blinking_circle_button.dart';
import 'package:elevator/app/data/response/data_response.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/elevator/setting/setting_elevator_screen.dart';
import 'package:elevator/app/modules/elevator/setting/spec_elevator_screen.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

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
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  bool _isStreaming = false;
  MqttProvider? mqttProvider;
  DataResponse? _resp;
  TextEditingController _controller = TextEditingController(text: '0 m/s');
  final List<Map<String, dynamic>> items = [
    {
      "id": 3,
      "icon": Icons.local_fire_department,
      "label": "Cảnh báo cháy",
      "color": Colors.red
    },
    {
      "id": 8,
      "icon": Icons.lock,
      "label": "Khóa thang",
      "color": Colors.orange
    },
    {
      "id": 0,
      "icon": Icons.stop_circle,
      "label": "Dừng khẩn",
      "color": Colors.blue
    },
    {"id": 16, "icon": Icons.phone, "label": "Liên lạc", "color": Colors.green},
    {
      "id": 11,
      "icon": Icons.medical_services,
      "label": "Cứu hộ",
      "color": Colors.purple
    },
    {
      "id": 15,
      "icon": Icons.star,
      "label": "Trạng thái VIP",
      "color": Colors.yellow
    },
  ];

  @override
  void initState() {
    super.initState();
    _localRenderer.initialize(); // Chỉ khởi tạo, chưa chạy stream
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mqttProvider = Provider.of<MqttProvider>(context, listen: false);
      mqttProvider?.subscribeTopic(topic);
    });
  }

  @override
  void dispose() {
    _stopStream();
    _localRenderer.dispose();
    // mqttProvider?.unsubscribeTopic(topic);
    super.dispose();
  }

  Future<void> _startStream() async {
    MediaStream stream = await navigator.mediaDevices.getUserMedia({
      'video': {
        'facingMode': 'environment',
      },
      'audio': false,
    });

    setState(() {
      _localRenderer.srcObject = stream;
      _isStreaming = true;
    });
  }

  void _stopStream() {
    _localRenderer.srcObject?.getTracks().forEach((track) => track.stop());
    _localRenderer.srcObject = null;
  }

  void _toggleStream() {
    setState(() {
      if (_isStreaming) {
        _stopStream();
      } else {
        _startStream();
      }
      _isStreaming = !_isStreaming;
    });
  }

  int? getValueByTagName(String tagName) {
    final tagData = _resp?.data?.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => TagData(), // tránh crash nếu không tìm thấy
    );

    if (tagData != null) {
      // Trả về giá trị đầu tiên không null trong mảng values
      return tagData.value;
    }
    return null;
  }

  String getFloorNameFromTag005() {
    final tagValue = getValueByTagName("TAG005");

    switch (tagValue) {
      case 1:
        return "G"; // Tầng trệt
      case 2:
        return "1";
      case 3:
        return "2";
      // Thêm các tầng khác nếu cần
      default:
        return "N/A"; // Giá trị không hợp lệ hoặc chưa định nghĩa
    }
  }

  Map<String, dynamic> getStatusInfo(int? statusCode) {
    switch (statusCode) {
      case 0:
        return {'text': 'Trạng thái lỗi', 'color': Colors.red};
      case 1:
        return {'text': 'Trạng thái cháy', 'color': Colors.orange};
      case 2:
        return {'text': 'Không hoạt động', 'color': Colors.grey};
      case 3:
        return {'text': 'Trạng thái bình thường', 'color': Colors.green};
      case 4:
        return {'text': 'Trạng thái động đất', 'color': Colors.purple};
      default:
        return {'text': 'Không xác định', 'color': Colors.black};
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Consumer<MqttProvider>(
          builder: (context, mqttProvider, child) {
            int? statusCode = getValueByTagName("TAG001");
            final statusInfo = getStatusInfo(statusCode);
            return Text(
              statusInfo['text'],
              style: TextStyle(
                color: statusInfo['color'],
                fontWeight: FontWeight.bold,
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
        String? message = mqttProvider.messages[topic];

        if (message != null && message.isNotEmpty) {
          try {
            Map<String, dynamic> jsonMap = json.decode(message);
            _resp = DataResponse.fromJson(jsonMap);
            int? value = getValueByTagName("TAG050");
            _controller.text = "${value! / 1000} m/s";
            print(value);
          } catch (e) {
            print("Lỗi khi decode JSON: $e");
          }
        } else {
          print("Chưa có dữ liệu cho topic này");
        }

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
                  padding: EdgeInsets.fromLTRB(6, 6, 6, 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                            RTCVideoView(
                              _localRenderer,
                              objectFit: RTCVideoViewObjectFit
                                  .RTCVideoViewObjectFitCover,
                            ),
                            Positioned(
                              child: GestureDetector(
                                onTap: _toggleStream,
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
                  height: size.height * .22,
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
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            color: Colors.black.withOpacity(0.3),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: getValueByTagName("TAG003") == 1
                                          ? BlinkingCircleButton(
                                              title: 'Mở',
                                              backgroundColor: Colors.green,
                                              textColor: Colors.black)
                                          : CircleAvatar(
                                              radius: 28,
                                              backgroundColor:
                                                  getValueByTagName("TAG003") ==
                                                          2
                                                      ? Colors.green
                                                      : Colors.grey,
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
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Spacer(),
                                      Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Center(
                                                child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: getValueByTagName(
                                                              'TAG002') ==
                                                          1
                                                      ? Lottie.asset(
                                                          'assets/jsons/arrow-up.json')
                                                      : SizedBox(),
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
                                                getFloorNameFromTag005(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                            )),
                                            Expanded(
                                              child: Center(
                                                child: SizedBox(
                                                  width: 40,
                                                  height: 40,
                                                  child: getValueByTagName(
                                                              'TAG002') ==
                                                          2
                                                      ? Lottie.asset(
                                                          'assets/jsons/arrow-down.json')
                                                      : SizedBox(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Divider(thickness: 0.2),
                                      Container(
                                        margin: const EdgeInsets.fromLTRB(
                                            5, 5, 5, 0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            getValueByTagName('TAG047') ?? 0,
                                            (index) {
                                              int value =
                                                  getValueByTagName('TAG011') ??
                                                      0;
                                              bool isOn =
                                                  ((value >> index) & 1) == 1;

                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                width: 18,
                                                height: 18,
                                                decoration: BoxDecoration(
                                                  color: isOn
                                                      ? Colors.green
                                                      : Colors.transparent,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                      color: Colors.white),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    index == 0
                                                        ? 'G'
                                                        : index
                                                            .toString(), // Hiển thị 'G' nếu index = 0
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 2,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: getValueByTagName("TAG003") == 3
                                          ? BlinkingCircleButton(
                                              title: 'Đóng',
                                              backgroundColor: Colors.red,
                                              textColor: Colors.black)
                                          : CircleAvatar(
                                              radius: 28,
                                              backgroundColor:
                                                  getValueByTagName("TAG003") ==
                                                          4
                                                      ? Colors.green
                                                      : Colors.grey,
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
                                  controller: _controller,
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
                                  initialValue: "${board.capacity} kg",
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
                  height: size.height * .2,
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
    return BlinkingGridItem(
      item: item,
      currentValue: getValueByTagName("TAG049") ?? 7,
    );
  }
}
