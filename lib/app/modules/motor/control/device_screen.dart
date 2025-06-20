import 'dart:convert';

import 'package:elevator/app/data/response/data_response.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/motor/control/bloc/control_bloc.dart';
import 'package:elevator/app/modules/motor/control/detail_device_screen.dart';
import 'package:elevator/app/modules/motor/energy_report/energy_report_screen.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../parameter_report/parameter_report_screen.dart';

class DeviceScreen extends StatefulWidget {
  final BoardDB board;
  const DeviceScreen({super.key, required this.board});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BoardDB get board => widget.board;
  late MqttProvider mqttProvider;
  int? selectedGroupId;
  late ControlBloc controlBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      mqttProvider = Provider.of<MqttProvider>(context, listen: false);
    });
    controlBloc = ControlBloc();
    if (board.groups != null && board.groups!.isNotEmpty) {
      selectedGroupId = board.groups!.first.id;
      controlBloc.add(FetchRegisters(selectedGroupId!));
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(board.name.toString()),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (_) => EnergyReportScreen()));
              },
              icon: Icon(Icons.electric_bolt_rounded)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (_) => ParameterReportScreen()));
              },
              icon: Icon(Icons.data_thresholding_outlined))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  child: Row(
                    children: (board.groups ?? []).map((group) {
                      final isSelected = group.id == selectedGroupId;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(group.name ?? "Không tên"),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedGroupId = group.id;
                            });
                            controlBloc.add(FetchRegisters(selectedGroupId!));
                          },
                          selectedColor: Colors.greenAccent,
                          backgroundColor: CustomColors.appbarColor,
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: const Center(
                      child:
                          Icon(Icons.more_horiz, size: 20, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            Divider(),
            BlocListener<ControlBloc, ControlState>(
              bloc: controlBloc,
              listener: (context, state) {
                if (state is GetRegisterLoaded) {
                  for (var element in state.registers) {
                    mqttProvider.subscribeTopic('${element.topic}state');
                  }
                }
              },
              child: BlocBuilder<ControlBloc, ControlState>(
                bloc: controlBloc,
                builder: (context, state) {
                  if (state is GetRegisterEmpty) {
                    return Expanded(
                      child: Center(
                        child: Text(
                          "Không có thiết bị nào trong nhóm này.",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (state is GetRegisterLoading) {
                    return Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (state is GetRegisterLoaded) {
                    final registers = state.registers;

                    return Consumer<MqttProvider>(
                        builder: (context, mqttProvider, child) {
                      return Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.95,
                          ),
                          itemCount: registers.length,
                          itemBuilder: (context, index) {
                            final r = registers[index];
                            final topicKey = '${r.topic}state';
                            final rawMessage = mqttProvider.messages[topicKey];

                            print("===========");
                            print(topicKey);
                            print(rawMessage);

                            bool isOn = false;
                            bool isConnect = false;
                            if (rawMessage != null && rawMessage.isNotEmpty) {
                              try {
                                final data = json.decode(rawMessage);
                                final int? status = data['status'];
                                isOn = status == 1;
                                isConnect = true;
                              } catch (e) {
                                print("❌ JSON decode error: $e");
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) =>
                                        DeviceDetailScreen(register: r),
                                  ),
                                );
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                decoration: BoxDecoration(
                                  color: Colors.white38,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: GridTile(
                                        footer: GridTileBar(
                                          backgroundColor: isConnect
                                              ? Colors.black.withOpacity(0.6)
                                              : Colors.red[300],
                                          title: Text(
                                            r.name ?? "Không tên",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            r.type == 'fan'
                                                ? 30
                                                : r.type == 'motor'
                                                    ? 40
                                                    : r.type == 'feeder'
                                                        ? 0
                                                        : 50,
                                          ),
                                          child: Hero(
                                            tag: 'device-${r.id}',
                                            child: Image.asset(
                                              'assets/images/${r.type}.png',
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Switch(
                                        value: isOn,
                                        onChanged: (value) {
                                          if (!isConnect) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Thiết bị hiện đang mất kết nối!",
                                                ),
                                                backgroundColor:
                                                    Colors.redAccent,
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                            return;
                                          }

                                          final newStatus = value ? 1 : 0;
                                          mqttProvider.publishMessage(
                                            '${r.topic}set',
                                            json.encode({"status": newStatus}),
                                          );
                                        },
                                        activeColor: Colors.greenAccent,
                                        inactiveThumbColor: Colors.redAccent,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    });
                  }
                  if (state is GetRegisterError) {
                    return Center(child: Text("Lỗi: ${state.message}"));
                  }

                  return SizedBox();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
