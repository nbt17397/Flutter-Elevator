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
  const DeviceControlScreen(
      {Key? key, required this.label, required this.groupId})
      : super(key: key);

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  bool _autoMode = false;
  late MqttProvider _mqtt;
  late ControlBloc _bloc;

  @override
  void initState() {
    super.initState();
    // Giả định bạn có định nghĩa cho ControlBloc và FetchRegisters
    _mqtt = Provider.of<MqttProvider>(context, listen: false);
    _bloc = ControlBloc()..add(FetchRegisters(widget.groupId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _mqtt.subscribeTopic('controller_1/auto_mode/state');
      // Đảm bảo logic publish này là cần thiết (thường là restart/init)
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // Hàm xây dựng Widget điều khiển/thông số
  Widget _buildControlOrParamWidget(
      RegisterDB dev, MqttProvider mqtt, bool isConnect, bool isOn) {
    // 💡 LOGIC CẦN THAY ĐỔI: Kiểm tra dev.type
    if (dev.type == 'param') {
      // Nếu là thông số (param) thì hiển thị Text (giá trị hiện tại)
      String currentValue = mqtt.messages['${dev.topic}state'] ?? 'N/A';
      try {
        // Cố gắng parse JSON để lấy giá trị nếu là định dạng JSON
        final d = json.decode(currentValue);
        // Giả định giá trị thông số nằm trong trường 'value'
        currentValue = d['status']?.toString() ?? 'N/A';
      } catch (_) {
        // Nếu không phải JSON, giữ nguyên raw string
        currentValue = currentValue.isEmpty ? 'N/A' : currentValue;
      }
      return Text(
        '$currentValue ${dev.unit}', // Hiển thị giá trị thông số
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: isConnect ? Colors.blue : Colors.red,
        ),
      );
    } else {
      // Nếu không phải 'param' (ví dụ: 'control') thì hiển thị Switch
      return Switch(
        value: isOn,
        onChanged: (v) {
          if (!_autoMode && isConnect) {
            mqtt.publishMessage(
                '${dev.topic}set', json.encode({'status': v ? 1 : 0}));
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
            _mqtt.publishMessage(
                'controller_2/restart/set', json.encode({'status': 0}));
            _mqtt.publishMessage(
                'controller_2/restart/set', json.encode({'status': 1}));
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
                      _mqtt.subscribeTopic('${reg.topic}state');
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
                          return SliverPadding(
                            padding: const EdgeInsets.only(bottom: 80.0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final dev = regs[index];
                                  final raw = mqtt.messages['${dev.topic}state'];
                                  bool isOn = false, isConnect = false;
                            
                                  // Xử lý trạng thái kết nối và bật/tắt (cho thiết bị điều khiển)
                                  if (raw?.isNotEmpty == true) {
                                    try {
                                      final d = json.decode(raw!);
                                      // Giả định trạng thái bật/tắt nằm trong trường 'status'
                                      isOn = d['status'] == 1;
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
                                          builder: (_) => DeviceDetailScreen(
                                              deviceName: dev.name!),
                                        ),
                                      ),
                                      child: Container(
                                        height: 56,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
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
                                                dev, mqtt, isConnect, isOn),
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
