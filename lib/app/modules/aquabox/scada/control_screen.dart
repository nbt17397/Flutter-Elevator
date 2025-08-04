import 'dart:convert';
import 'package:elevator/app/components/app_background.dart';
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
  const DeviceControlScreen({Key? key, required this.label}) : super(key: key);

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  bool _autoMode = false;
  late MqttProvider _mqtt;
  late ControlBloc _bloc;
  final int _groupId = 1;

  @override
  void initState() {
    super.initState();
    _mqtt = Provider.of<MqttProvider>(context, listen: false);
    _bloc = ControlBloc()..add(FetchRegisters(_groupId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mqtt.subscribeTopic('controller_1/auto_mode/state');
      _mqtt.publishMessage(
          'controller_1/restart/set', json.encode({'status': 0}));
      _mqtt.publishMessage(
          'controller_1/restart/set', json.encode({'status': 1}));
    });
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                          return SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final dev = regs[index];
                                final raw = mqtt.messages['${dev.topic}state'];
                                bool isOn = false, isConnect = false;

                                if (raw?.isNotEmpty == true) {
                                  try {
                                    final d = json.decode(raw!);
                                    isOn = d['status'] == 1;
                                    isConnect = true;
                                  } catch (_) {}
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
                                          const Icon(Icons.play_arrow,
                                              size: 20),
                                          const SizedBox(width: 8),
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
                                          Switch(
                                            value: isOn,
                                            onChanged: (v) {
                                              if (!_autoMode && isConnect) {
                                                mqtt.publishMessage(
                                                    '${dev.topic}set',
                                                    json.encode(
                                                        {'status': v ? 1 : 0}));
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 1),
                                                    content: Text(
                                                        'Không được điều khiển'),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            },
                                            activeColor: Colors.green,
                                            activeTrackColor:
                                                Colors.green.shade200,
                                            inactiveThumbColor: Colors.white,
                                            inactiveTrackColor:
                                                Colors.grey.shade400,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: regs.length,
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
