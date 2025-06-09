import 'dart:convert';

import 'package:elevator/app/data/response/data_response.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/elevator/setting/spec_detail_screen.dart';
import 'package:elevator/app/modules/motor/control/bloc/control_bloc.dart';
import 'package:elevator/app/modules/motor/control/detail_device_screen.dart';
import 'package:elevator/app/modules/motor/energy_report/energy_report_screen.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class DeviceScreen extends StatefulWidget {
  final BoardDB board;
  const DeviceScreen({super.key, required this.board});

  @override
  State<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  BoardDB get board => widget.board;
  String get topic => "from-client/${board.deviceId}";
  MqttProvider? mqttProvider;
  DataResponse? _resp;
  int? selectedGroupId;
  late ControlBloc controlBloc;

  @override
  void initState() {
    super.initState();
    controlBloc = ControlBloc();
    if (board.groups != null && board.groups!.isNotEmpty) {
      selectedGroupId = board.groups!.first.id;
      controlBloc.add(FetchRegisters(selectedGroupId!));
    }
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
                Navigator.push(context,
                    CupertinoPageRoute(builder: (_) => SpecDetailScreen()));
              },
              icon: Icon(Icons.add_to_photos_outlined))
        ],
      ),
      body: Consumer<MqttProvider>(builder: (context, mqttProvider, child) {
        String? message = mqttProvider.messages[topic];

        if (message != null && message.isNotEmpty) {
          try {
            Map<String, dynamic> jsonMap = json.decode(message);
            _resp = DataResponse.fromJson(jsonMap);
          } catch (e) {
            print("Lỗi khi decode JSON: $e");
          }
        } else {
          print("Chưa có dữ liệu cho topic này");
        }

        return Container(
          padding: const EdgeInsets.all(8),
          width: double.infinity,
          height: double.infinity,
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
                                selectedGroupId = isSelected ? null : group.id;
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
                        child: Icon(Icons.more_horiz,
                            size: 20, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
              Divider(),
              BlocBuilder<ControlBloc, ControlState>(
                bloc: controlBloc,
                builder: (context, state) {
                  if (state is GetRegisterEmpty) {
                    return Expanded(
                      child: const Center(
                        child: Text(
                          "Không có thiết bị nào trong nhóm này.",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  if (state is GetRegisterLoading) {
                    return const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  } else if (state is GetRegisterLoaded) {
                    final registers = state.registers;

                    return Expanded(
                      child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          physics: const BouncingScrollPhysics(),
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

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                        builder: (_) =>
                                            DeviceDetailScreen(register: r)));
                              },
                              child: Container(
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
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: GridTile(
                                    footer: GridTileBar(
                                      backgroundColor:
                                          Colors.black.withOpacity(0.5),
                                      title: Text(
                                        r.name ?? "Không tên",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
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
                              ),
                            );
                          }),
                    );
                  } else if (state is GetRegisterError) {
                    return Center(child: Text("Lỗi: ${state.message}"));
                  }

                  return const SizedBox();
                },
              )
            ],
          ),
        );
      }),
    );
  }
}
