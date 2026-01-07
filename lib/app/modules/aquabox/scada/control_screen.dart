import 'dart:convert';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/modules/aquabox/scada/device_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:provider/provider.dart';
import 'bloc/control_bloc.dart';

class DeviceControlScreen extends StatefulWidget {
  final String label;
  final int groupId;
  final String topic;
  const DeviceControlScreen(
      {super.key,
      required this.label,
      required this.groupId,
      required this.topic});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  bool _autoMode = false;
  late MqttProvider _mqtt;
  late ControlBloc _bloc;
  Map<String, String> _groupDataMap = {};

  @override
  void initState() {
    super.initState();
    // Giả định bạn có định nghĩa cho ControlBloc và FetchRegisters
    _mqtt = Provider.of<MqttProvider>(context, listen: false);
    _bloc = ControlBloc()..add(FetchRegisters(widget.groupId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.topic != '') {
        _mqtt.subscribeTopic('${widget.topic}get');
        _mqtt.publishMessage('${widget.topic}state', '{}');
      }
    });
  }

  @override
  void dispose() {
    _bloc.close();
    if (widget.topic != '') {
      _mqtt.unsubscribeTopic('${widget.topic}get');
    }

    super.dispose();
  }

  // Hàm hiển thị dialog cho phép chỉnh sửa giá trị thông số
  Future<void> _showEditParamDialog(
      BuildContext context, RegisterDB dev, MqttProvider mqtt) async {
    TextEditingController _controller = TextEditingController();

    // Thử lấy giá trị hiện tại để điền vào TextField
    String? raw =
        _groupDataMap[dev.topic] ?? mqtt.messages['${dev.topic}state'];
    String currentValue = 'N/A';
    if (raw != null && raw.isNotEmpty) {
      try {
        final d = json.decode(raw);
        currentValue = d['status']?.toString() ?? 'N/A';
      } catch (_) {
        currentValue = raw;
      }
    }

    // Điền giá trị hiện tại vào controller
    _controller.text = currentValue != 'N/A' ? currentValue : '';

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), // Độ bo góc
          ),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number, // Giả định là số
            decoration: InputDecoration(
              labelText: 'Giá trị mới',
              hintText: 'Nhập giá trị mới',
              suffixText: dev.unit,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(
                  color: Colors.grey.shade400, // Màu viền khi không focus
                  width: 1.0,
                ),
              ),

              // 3. VIỀN KHI FOCUS (focusedBorder)
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(
                  color: Colors.blue, // Màu viền khi được chọn (nên khác biệt)
                  width: 2.0,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Gửi'),
              onPressed: () {
                final String newValue = _controller.text.trim();
                if (newValue.isNotEmpty && newValue != currentValue) {
                  final payload = json.encode(
                      {'status': double.tryParse(newValue) ?? newValue});
                  mqtt.publishMessage('${dev.topic}/set', payload);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Hàm xây dựng Widget điều khiển/thông số
  Widget _buildControlOrParamWidget(
      RegisterDB dev, MqttProvider mqtt, bool isConnect, bool isOn,
      {String? paramValue, String? rawMessage}) {
    // 💡 LOGIC CẦN THAY ĐỔI: Kiểm tra dev.type
    if (dev.type == 'param') {
      // Nếu là thông số (param) thì hiển thị Text (giá trị hiện tại)
      // String currentValue = mqtt.messages['${dev.topic}state'] ?? 'N/A';
      String currentValue = paramValue ?? 'N/A';
      try {
        // Cố gắng parse JSON để lấy giá trị nếu là định dạng JSON
        final d = json.decode(currentValue);
        // Giả định giá trị thông số nằm trong trường 'value'
        currentValue = d['status']?.toString() ?? 'N/A';
      } catch (_) {
        // Nếu không phải JSON, giữ nguyên raw string
        currentValue = currentValue.isEmpty ? 'N/A' : currentValue;
      }
      return GestureDetector(
        onTap: () {
          // Chỉ cho phép chỉnh sửa nếu thiết bị đang kết nối và KHÔNG phải là chỉ đọc
          if (isConnect && !dev.readOnly! && !dev.readOnly!) {
            _showEditParamDialog(context, dev, mqtt);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Thông số này không được phép chỉnh sửa'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        child: Text(
          '$currentValue ${dev.unit}', // Hiển thị giá trị thông số
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isConnect ? Colors.blue : Colors.red,
          ),
        ),
      );
    } else {
      // Nếu không phải 'param' (ví dụ: 'control') thì hiển thị Switch
      return Switch(
        value: isOn,
        onChanged: (v) {
          if (!_autoMode && isConnect && !dev.readOnly!) {
            mqtt.publishMessage(
                '${dev.topic}/set', json.encode({'status': v ? 1 : 0}));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                duration: Duration(seconds: 1),
                content: Text('Không được điều khiển'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        activeColor: Colors.green,
        activeTrackColor: Colors.green.shade200,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade400,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (widget.topic != '') {
              _mqtt.publishMessage('${widget.topic}state', '{}');
            } else {
              _mqtt.publishMessage(
                  'controller_2/restart/set', json.encode({'status': 0}));
              _mqtt.publishMessage(
                  'controller_2/restart/set', json.encode({'status': 1}));
            }
          },
          backgroundColor:
              CustomColors.appbarColor, // Sử dụng màu bạn đã định nghĩa
          child: const Icon(Icons.refresh, color: Colors.white), // Icon Refresh
        ),
        body: BlocProvider<ControlBloc>.value(
          value: _bloc,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                collapsedHeight: kToolbarHeight,
                pinned: true,
                backgroundColor: CustomColors.appbarColor,
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Hero(
                    tag: widget.label,
                    transitionOnUserGestures: true,
                    child: Image.asset(widget.label, fit: BoxFit.fitHeight),
                  ),
                ),
              ),
              BlocListener<ControlBloc, ControlState>(
                listener: (context, state) {
                  if (state is GetRegisterLoaded) {
                    // Đảm bảo RegisterModel có thuộc tính `topic`
                    for (var reg in state.registers) {
                      if (widget.topic == '') {
                        _mqtt.subscribeTopic('${reg.topic}state');
                      }
                    }
                  }
                },
                child: BlocBuilder<ControlBloc, ControlState>(
                  builder: (context, state) {
                    if (state is GetRegisterLoading) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (state is GetRegisterEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'Không có thiết bị trong nhóm này.',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    if (state is GetRegisterLoaded) {
                      final regs = state.registers;
                      return Consumer<MqttProvider>(
                        builder: (context, mqtt, _) {
                          String? msg = mqtt.messages['${widget.topic}get'];
                          // 💡 PHẦN TODO ĐÃ ĐƯỢC THỰC HIỆN TẠI ĐÂY
                          if (widget.topic != '' &&
                              msg != null &&
                              msg.isNotEmpty) {
                            try {
                              final List<dynamic> responseArray =
                                  json.decode(msg);
                              if (msg != _groupDataMap['__last_raw_msg__']) {
                                _groupDataMap.clear();
                                _groupDataMap['__last_raw_msg__'] =
                                    msg; // Lưu tin nhắn thô để so sánh lần sau

                                for (var item in responseArray) {
                                  if (item is Map<String, dynamic> &&
                                      item.containsKey('addr') &&
                                      item.containsKey('value')) {
                                    final String addr = item['addr'] as String;
                                    final dynamic value = item['value'];

                                    // 2. Chuẩn hóa và gán: Key = dev.topic, Value = JSON String chuẩn {"status": value}
                                    _groupDataMap[addr] =
                                        json.encode({'status': value});
                                  }
                                }
                              }
                            } catch (e) {
                              print(
                                  'Lỗi phân tích JSON Array trên ${widget.topic}get: $e');
                              _groupDataMap.clear();
                            }
                          }
                          return SliverPadding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final dev = regs[index];
                                  // final raw =
                                  // mqtt.messages['${dev.topic}state'];

                                  String? raw = _groupDataMap[dev.topic];

                                  // Nếu không tìm thấy trong map nhóm, quay về cách đọc topic đơn lẻ (raw gốc)
                                  if (raw == null || raw.isEmpty) {
                                    raw = mqtt.messages['${dev.topic}state'];
                                  }

                                  bool isOn = false, isConnect = false;
                                  dynamic value = 0;

                                  // Xử lý trạng thái kết nối và bật/tắt (cho thiết bị điều khiển)
                                  if (raw?.isNotEmpty == true) {
                                    try {
                                      final d = json.decode(raw!);
                                      // Giả định trạng thái bật/tắt nằm trong trường 'status'
                                      isOn = d['status'] == 1;
                                      value = d['status'];
                                      isConnect = true;
                                    } catch (_) {
                                      // Trường hợp không decode được JSON, coi như không có kết nối hoặc dữ liệu lỗi
                                    }
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    child: GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (_) =>
                                              DeviceDetailScreen(register: dev),
                                        ),
                                      ),
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: Colors.grey.shade300),
                                        ),
                                        child: Row(
                                          children: [
                                            // Biểu tượng (giữ nguyên)
                                            const Icon(Icons.play_arrow,
                                                size: 20),
                                            const SizedBox(width: 8),
                                            // Tên thiết bị
                                            Expanded(
                                              child: Text(
                                                dev.name!,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isConnect
                                                      ? Colors.black
                                                      : Colors.red[300],
                                                ),
                                              ),
                                            ),
                                            // 💡 Đổi phần này để gọi hàm tùy chỉnh
                                            _buildControlOrParamWidget(
                                                dev, mqtt, isConnect, isOn,
                                                paramValue: value.toString()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                childCount: regs.length,
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
