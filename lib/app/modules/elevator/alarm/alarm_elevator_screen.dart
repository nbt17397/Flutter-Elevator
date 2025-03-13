import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class AlarmElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const AlarmElevatorScreen({super.key, required this.board});

  @override
  State<AlarmElevatorScreen> createState() => _AlarmElevatorScreenState();
}

class _AlarmElevatorScreenState extends State<AlarmElevatorScreen> {
  final List<Map<String, String>> alarmList = [
    {'code': 'E101', 'description': 'Lỗi cảm biến cửa', 'time': '10:23:45'},
    {'code': 'E202', 'description': 'Quá tải', 'time': '12:15:30'},
    {'code': 'E303', 'description': 'Mất tín hiệu tầng', 'time': '14:07:20'},
    {'code': 'E404', 'description': 'Lỗi hệ thống phanh', 'time': '16:45:10'},
    {'code': 'E405', 'description': 'Cảnh báo quá tải', 'time': '17:45:10'},
    {'code': 'E406', 'description': 'Mất kết nối', 'time': '19:45:10'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cảnh báo'),
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
              'Danh sách lỗi thang máy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: DataTable(
                  columns: const [
                    DataColumn(
                        label: Text('Mã lỗi',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Thời gian',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Mô tả',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: alarmList.map((alarm) {
                    return DataRow(cells: [
                      DataCell(Text(alarm['code']!,
                          style: TextStyle(color: Colors.white))),
                      DataCell(Text(alarm['time']!,
                          style: TextStyle(color: Colors.white))),
                      DataCell(Text(alarm['description']!,
                          style: TextStyle(color: Colors.white))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
