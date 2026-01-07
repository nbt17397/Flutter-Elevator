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

class AquaboxDeviceControlScreen extends StatefulWidget {
  final String label;
  final int groupId;
  final String topic;
  const AquaboxDeviceControlScreen({
    super.key,
    required this.label,
    required this.groupId,
    required this.topic,
  });

  @override
  State<AquaboxDeviceControlScreen> createState() =>
      _AquaboxDeviceControlScreenState();
}

class _AquaboxDeviceControlScreenState
    extends State<AquaboxDeviceControlScreen> {
  bool _showMinorSignals = false;
  late MqttProvider _mqtt;
  late ControlBloc _bloc;

  Map<int, String> _groupDataMap = {};
  String _lastRawMsg = "";

  @override
  void initState() {
    super.initState();
    _mqtt = Provider.of<MqttProvider>(context, listen: false);
    _bloc = ControlBloc()..add(FetchRegisters(widget.groupId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.topic.isNotEmpty) {
        _mqtt.subscribeTopic('${widget.topic}/get');
      }
    });
  }

  @override
  void dispose() {
    _bloc.close();
    if (widget.topic.isNotEmpty) {
      _mqtt.unsubscribeTopic('${widget.topic}/get');
    }
    super.dispose();
  }

  String _generateBitPayload(
      List<RegisterDB> sortedRegs, int targetId, bool newValue) {
    List<String> hexClusters = [];

    for (var reg in sortedRegs) {
      bool status = false;
      if (reg.id == targetId) {
        status = newValue;
      } else {
        final String? jsonStr = _groupDataMap[reg.id];
        if (jsonStr != null) {
          try {
            status = (json.decode(jsonStr)['status'] == 1 ||
                json.decode(jsonStr)['status'] == true);
          } catch (_) {}
        }
      }
      hexClusters.add(status ? "0001" : "0000");
    }

    return hexClusters.join(" ");
  }

  // --- Widget điều khiển ---
  Widget _buildControlWidget(RegisterDB dev, MqttProvider mqtt, bool isConnect,
      bool isOn, List<RegisterDB> allRegs, dynamic value) {

    if (dev.type == 'param') {
      String? raw = _groupDataMap[dev.id];
      String displayVal = 'N/A';
      if (raw != null) {
        try {
          displayVal = json.decode(raw)['status'].toString();
        } catch (_) {}
      }
      return Text('$displayVal ${dev.unit}',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isConnect ? Colors.blue : Colors.red));
    }

    if (dev.readOnly == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: isOn
              ? Colors.green.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isOn ? Colors.green : Colors.grey.shade400),
        ),
        child: Text(isOn ? "ON" : "OFF",
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isOn ? Colors.green : Colors.grey.shade600)),
      );
    }

    return Transform.scale(
      scale: 0.8,
      child: Switch(
        value: isOn,
        onChanged: (isConnect)
            ? (v) {
                List<RegisterDB> sortedRegsForPayload = List.from(allRegs);
                sortedRegsForPayload.sort((a, b) {
                  int cmp = (a.kind ?? 0).compareTo(b.kind ?? 0);
                  if (cmp != 0) return cmp;
                  return (a.index ?? 0).compareTo(b.index ?? 0);
                });

                String bitPayload =
                    _generateBitPayload(sortedRegsForPayload, dev.id!, v);
                mqtt.publishMessage(widget.topic, bitPayload);
              }
            : null,
        activeColor: !isConnect ? Colors.red : Colors.green,
        inactiveThumbColor: Colors.grey.shade700,
        inactiveTrackColor: Colors.grey.shade300,
      ),
    );
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
                pinned: true,
                backgroundColor: CustomColors.appbarColor,
                actions: [
                  IconButton(
                    icon: Icon(
                        _showMinorSignals
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white),
                    onPressed: () =>
                        setState(() => _showMinorSignals = !_showMinorSignals),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                      tag: widget.label,
                      child: Image.asset(widget.label, fit: BoxFit.fitHeight)),
                ),
              ),
              BlocBuilder<ControlBloc, ControlState>(
                builder: (context, state) {
                  if (state is GetRegisterLoading) {
                    return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()));
                  }

                  if (state is GetRegisterLoaded) {
                    final allRegs = state.registers;

                    return Consumer<MqttProvider>(
                      builder: (context, mqtt, _) {
                        // MQTT Update Logic
                        String? msg = mqtt.messages['${widget.topic}/get'];
                        if (msg != null &&
                            msg.isNotEmpty &&
                            msg != _lastRawMsg) {
                          _lastRawMsg = msg;
                          try {
                            final List<dynamic> res = json.decode(msg);
                            _groupDataMap.clear();
                            for (var item in res) {
                              final id =
                                  int.tryParse(item['device_id'].toString());
                              if (id != null) {
                                _groupDataMap[id] =
                                    json.encode({'status': item['value']});
                              }
                            }
                          } catch (_) {}
                        }

                        // BỔ SUNG LOGIC HIỂN THỊ THEO YÊU CẦU
                        final filteredRegs = allRegs.where((r) {
                          if (_showMinorSignals) return true;
                          
                          // Lấy giá trị hiện tại từ map để check value == 1
                          bool isActive = false;
                          final String? jsonStr = _groupDataMap[r.id];
                          if (jsonStr != null) {
                            try {
                              var status = json.decode(jsonStr)['status'];
                              isActive = (status == 1 || status == true);
                            } catch (_) {}
                          }

                          // Hiển thị nếu KHÔNG PHẢI minor HOẶC đang bật (value=1)
                          return r.isMinorSignal != true || isActive;
                        }).toList();

                        // Nhóm thiết bị theo Kind (giữ nguyên logic gốc)
                        final Map<int, List<RegisterDB>> groupedByKind = {};
                        for (var reg in filteredRegs) {
                          final kindKey = reg.kind ?? 0;
                          groupedByKind.putIfAbsent(kindKey, () => []).add(reg);
                        }
                        final sortedIndexes = groupedByKind.keys.toList()..sort();

                        return SliverPadding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 80),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, i) {
                                final idx = sortedIndexes[i];
                                final items = groupedByKind[idx]!;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.1),
                                        width: 1),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white.withOpacity(0.05),
                                  ),
                                  child: Column(
                                    children: items.map((dev) {
                                      String? raw = _groupDataMap[dev.id] ??
                                          mqtt.messages['${dev.topic}state'];
                                      bool isOn = false, isConnect = false;
                                      dynamic val = 0;
                                      if (raw != null && raw.isNotEmpty) {
                                        try {
                                          final d = json.decode(raw);
                                          val = d['status'];
                                          isOn = (val == 1 || val == true);
                                          isConnect = true;
                                        } catch (_) {}
                                      }
                                      return _buildRowItem(dev, mqtt, isConnect,
                                          isOn, allRegs, val, raw);
                                    }).toList(),
                                  ),
                                );
                              },
                              childCount: sortedIndexes.length,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowItem(RegisterDB dev, MqttProvider mqtt, bool isConnect,
      bool isOn, List<RegisterDB> allRegs, dynamic val, String? raw) {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.blueGrey),
          const SizedBox(width: 10),
          Expanded(
            child: Text(dev.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 13,
                    color: (val == 3 || val == 4)
                        ? Colors.red
                        : Colors.black87)),
          ),
          _buildControlWidget(dev, mqtt, isConnect, isOn, allRegs, val),
        ],
      ),
    );
  }
}