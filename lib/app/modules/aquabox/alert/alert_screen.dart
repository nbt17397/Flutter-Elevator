import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ======== MODEL (fake) ========
class TaskAlert {
  final String code; // Mã CV
  final String title; // Nội dung
  final DateTime date;
  final String level; // Cao | Trung bình | Thấp
  TaskAlert(this.code, this.title, this.date, this.level);
}

class DeviceAlert {
  final String devCode; // Mã TB
  final String name; // Tên thiết bị
  final String fault; // Lỗi
  final DateTime date;
  final String level;
  DeviceAlert(this.devCode, this.name, this.fault, this.date, this.level);
}

/// ======== SCREEN ========
class AlertScreen extends StatelessWidget {
  AlertScreen({super.key}) {
    _fakeData();
  }

  /* ---- fake lists ---- */
  final List<TaskAlert> _taskAlerts = [];
  final List<DeviceAlert> _deviceAlerts = [];
  final _rng = Random();
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  void _fakeData() {
    const levels = ['Cao', 'Trung bình', 'Thấp'];
    for (int i = 0; i < 15; i++) {
      _taskAlerts.add(TaskAlert(
        'CV${1000 + i}',
        'Chậm thời hạn công việc $i',
        DateTime.now().subtract(Duration(hours: 2 + i)),
        levels[_rng.nextInt(3)],
      ));
    }
    for (int i = 0; i < 12; i++) {
      _deviceAlerts.add(DeviceAlert(
        'TB${200 + i}',
        'Máy sục khí $i',
        'Quá nhiệt',
        DateTime.now().subtract(Duration(hours: i)),
        levels[_rng.nextInt(3)],
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cảnh báo'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              tooltip: 'Lịch sử cảnh báo',
              icon: const Icon(Icons.history), // hoặc Icons.access_time
              onPressed: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (_) => const AlertHistoryScreen()),
                // );
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(46),
            child: Container(
              color: Colors.white, // 👉 nền riêng cho TabBar
              child: TabBar(
                labelColor: CustomColors.appbarColor, // chữ tab đang chọn
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: CustomColors.appbarColor,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Công việc'),
                  Tab(text: 'Thiết bị'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _taskTab(context),
            _deviceTab(context),
          ],
        ),
      ),
    );
  }

  /* ---- Tab 1: Công việc ---- */
  Widget _taskTab(BuildContext ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _scrollable(DataTable(
          headingRowColor:
              MaterialStateProperty.resolveWith((_) => Colors.black),
          dataRowColor:
              MaterialStateProperty.resolveWith((_) => Colors.grey.shade300),
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('Mã', style: _head)),
            DataColumn(label: Text('Nội dung', style: _head)),
            DataColumn(label: Text('Thời gian', style: _head)),
            DataColumn(label: Text('Mức độ', style: _head)),
          ],
          rows: _taskAlerts
              .map((a) => DataRow(cells: [
                    DataCell(Text(a.code)),
                    DataCell(Text(a.title)),
                    DataCell(Text(_fmt.format(a.date))),
                    DataCell(Text(a.level)),
                  ]))
              .toList(),
          showCheckboxColumn: false,
        )),
      );

  /* ---- Tab 2: Thiết bị ---- */
  Widget _deviceTab(BuildContext ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: _scrollable(DataTable(
          headingRowColor:
              MaterialStateProperty.resolveWith((_) => Colors.black),
          dataRowColor:
              MaterialStateProperty.resolveWith((_) => Colors.grey.shade300),
          columnSpacing: 28,
          columns: const [
            DataColumn(label: Text('Mã TB', style: _head)),
            DataColumn(label: Text('Tên thiết bị', style: _head)),
            DataColumn(label: Text('Lỗi', style: _head)),
            DataColumn(label: Text('Thời gian', style: _head)),
            DataColumn(label: Text('Mức độ', style: _head)),
          ],
          rows: _deviceAlerts
              .map((d) => DataRow(cells: [
                    DataCell(Text(d.devCode)),
                    DataCell(Text(d.name)),
                    DataCell(Text(d.fault)),
                    DataCell(Text(_fmt.format(d.date))),
                    DataCell(Text(d.level)),
                  ]))
              .toList(),
          showCheckboxColumn: false,
        )),
      );

  /* ---- helper: scroll 2 chiều ---- */
  Widget _scrollable(Widget child) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: child,
        ),
      );
}

const _head = TextStyle(color: Colors.white);
