import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/elevator/report/elevator_button_press_chart.dart';
import 'package:elevator/app/modules/elevator/report/elevator_distance_chart.dart';
import 'package:elevator/app/modules/elevator/report/elevator_door_open_chart.dart';
import 'package:elevator/app/modules/elevator/report/elevator_usage_floor_chart.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuReportScreen extends StatefulWidget {
  final BoardDB board;
  const MenuReportScreen({super.key, required this.board});

  @override
  State<MenuReportScreen> createState() => _MenuReportScreenState();
}

class _MenuReportScreenState extends State<MenuReportScreen> {
  final List<Map<String, dynamic>> reportOptions = [
    {'title': 'Số lần đóng mở cửa thang máy', 'icon': Icons.elevator},
    {'title': 'Số lần đóng mở cửa tầng', 'icon': Icons.door_front_door},
    {'title': 'Tổng quãng đường di chuyển', 'icon': Icons.timeline},
    {'title': 'Số lần nhấn phím của từng phím', 'icon': Icons.touch_app},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tra cứu dữ liệu'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn loại báo cáo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reportOptions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListTile(
                      leading: Icon(
                        reportOptions[index]['icon'],
                        color: Colors.white,
                      ),
                      title: Text(
                        reportOptions[index]['title'],
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Colors.white, size: 14),
                      onTap: () {
                        switch (index) {
                          case 0:
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) =>
                                    ElevatorDoorOpenChart(board: widget.board),
                              ),
                            );
                            break;
                          case 1:
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => ElevatorUsageFloorChart(
                                    board: widget.board),
                              ),
                            );
                            break;
                          case 2:
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) =>
                                    ElevatorDistanceChart(board: widget.board),
                              ),
                            );
                            break;
                          case 3:
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) =>
                                    ElevatorButtonPressChart(board: widget.board),
                              ),
                            );
                            break;
                          default:
                            break;
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
