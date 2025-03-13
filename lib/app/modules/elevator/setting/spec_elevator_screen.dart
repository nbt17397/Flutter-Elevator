import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class SpecElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const SpecElevatorScreen({super.key, required this.board});

  @override
  State<SpecElevatorScreen> createState() => _SpecElevatorScreenState();
}

class _SpecElevatorScreenState extends State<SpecElevatorScreen> {
  final List<Map<String, String>> elevatorErrors = [
    {'code': 'TAG01', 'description': 'Lỗi cảm biến cửa', 'value': '1'},
    {'code': 'TAG02', 'description': 'Lỗi động cơ kéo', 'value': '0'},
    {'code': 'TAG03', 'description': 'Mất tín hiệu tầng', 'value': '1'},
    {'code': 'TAG04', 'description': 'Lỗi hệ thống phanh', 'value': '1'},
    {'code': 'TAG05', 'description': 'Quá tải trọng', 'value': '1'},
    {'code': 'TAG06', 'description': 'Lỗi mất điện đột ngột', 'value': '0'},
    {'code': 'TAG07', 'description': 'Chiều thang máy', 'value': '1'},
    {'code': 'TAG08', 'description': 'Tầng hiện tại', 'value': '1'},
    {'code': 'TAG09', 'description': 'Trạng thái đóng mở', 'value': '0'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông số kỹ thuật'),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black54),
                  columns: const [
                    DataColumn(
                      label: Text('Tín hiệu',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Mô Tả',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                    DataColumn(
                      label: Text('Giá Trị',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                  rows: elevatorErrors
                      .map(
                        (error) => DataRow(
                          color: MaterialStateColor.resolveWith((states) => Colors.black38),
                          cells: [
                            DataCell(Text(error['code']!, style: TextStyle(color: Colors.white))),
                            DataCell(Text(error['description']!, style: TextStyle(color: Colors.white))),
                             DataCell(Text(error['value']!, style: TextStyle(color: Colors.white))),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
