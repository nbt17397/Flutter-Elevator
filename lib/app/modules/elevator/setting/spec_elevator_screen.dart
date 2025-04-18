import 'dart:convert';

import 'package:elevator/app/data/response/data_response.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SpecElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const SpecElevatorScreen({super.key, required this.board});

  @override
  State<SpecElevatorScreen> createState() => _SpecElevatorScreenState();
}

class _SpecElevatorScreenState extends State<SpecElevatorScreen> {
  BoardDB get board => widget.board;
  String get topic => "from-client/${board.deviceId}";
  MqttProvider? mqttProvider;
  DataResponse? _resp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông số kỹ thuật'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
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
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width),
                      child: DataTable(
                        columnSpacing: 24, // Khoảng cách giữa các cột
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black54),
                        columns: const [
                          DataColumn(
                            label: Text('Tín hiệu',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Mô Tả',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Giá Trị',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                        rows: (_resp?.data ?? []).map(
                          (item) {
                            final tagName = item.name;
                            final tagValue =
                                item.toJson().values.elementAt(1).toString();

                            return DataRow(
                              color: MaterialStateColor.resolveWith(
                                  (states) => Colors.black38),
                              cells: [
                                DataCell(Text(tagName.toString(),
                                    style:
                                        const TextStyle(color: Colors.white))),
                                const DataCell(Text('Unknown',
                                    style: TextStyle(color: Colors.white))),
                                DataCell(Text(tagValue,
                                    style:
                                        const TextStyle(color: Colors.white))),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
