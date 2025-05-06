import 'dart:convert';

import 'package:elevator/app/data/response/data_response.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/services/mqtt/mqtt_provider.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaintenanceElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const MaintenanceElevatorScreen({super.key, required this.board});

  @override
  State<MaintenanceElevatorScreen> createState() =>
      _MaintenanceElevatorScreenState();
}

class _MaintenanceElevatorScreenState extends State<MaintenanceElevatorScreen> {
  BoardDB get board => widget.board;
  String get topic => "from-client/${board.deviceId}";
  MqttProvider? mqttProvider;
  DataResponse? _resp;
  int tag053 = 0;
  int tag052 = 0;
  
  int? getValueByTagName(String tagName) {
    final tagData = _resp?.data?.firstWhere(
      (tag) => tag.name == tagName,
      orElse: () => TagData(),
    );

    if (tagData != null) {
      return tagData.value;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bảo trì'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Consumer<MqttProvider>(builder: (context, mqttProvider, child) {
        String? message = mqttProvider.messages[topic];

        if (message != null && message.isNotEmpty) {
          try {
            Map<String, dynamic> jsonMap = json.decode(message);
            _resp = DataResponse.fromJson(jsonMap);
            tag052 = getValueByTagName("TAG052")!;
            tag053 = getValueByTagName("TAG053")! * 10000 +
                getValueByTagName("TAG054")!;
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
                            label: Text('Giá trị',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                          DataColumn(
                            label: Text('Đơn vị',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                        rows: [
                          {
                            "name": "Thời gian chạy tích lũy",
                            "value": tag052,
                            "unit": "Giờ"
                          },
                          {
                            "name": "Số lần chạy tính lũy",
                            "value": tag053,
                            "unit": "Lần"
                          }
                        ].map((item) {
                       

                          return DataRow(
                            color: MaterialStateColor.resolveWith(
                                (states) => Colors.black38),
                            cells: [
                              DataCell(Text(
                                  item["name"].toString(),
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(item["value"].toString(),
                                  style: const TextStyle(color: Colors.white))),
                              DataCell(Text(item["unit"].toString(),
                                  style: const TextStyle(color: Colors.white))),
                            ],
                          );
                        }).toList(),
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
