// lib/screens/maintenance_screen.dart

import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

/// Model cho mỗi thiết bị bảo trì
class MaintenanceItem {
  final String name;
  final Duration interval;
  DateTime lastReset;

  MaintenanceItem({
    required this.name,
    this.interval = const Duration(hours: 72),
    DateTime? lastReset,
  }) : lastReset = lastReset ??
            DateTime.now().subtract(
              // random demo: đã chạy ngẫu nhiên từ 0 → 1.5×interval
              Duration(
                hours: Random().nextInt((interval.inHours * 3) ~/ 2),
              ),
            );

  Duration get operatingTime => DateTime.now().difference(lastReset);
  Duration get timeRemaining => interval - operatingTime;
}

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  // Fake data (không truyền từ ngoài)
  final List<MaintenanceItem> _items = [
    MaintenanceItem(name: 'Bơm nước 1'),
    MaintenanceItem(name: 'Van UV 1'),
    MaintenanceItem(name: 'Van xả 1'),
    MaintenanceItem(name: 'Máy cho ăn tự động 1'),
    MaintenanceItem(name: 'Máy cho ăn tự động 2'),
    MaintenanceItem(name: 'Bơm nước 2'),
    MaintenanceItem(name: 'Van UV 2'),
    MaintenanceItem(name: 'Van xả 2'),
    MaintenanceItem(name: 'Máy cho ăn tự động 3'),
    MaintenanceItem(name: 'Máy cho ăn tự động 4'),
    MaintenanceItem(name: 'Trạm bơm chính'),
    MaintenanceItem(name: 'Bể nuôi 1'),
    MaintenanceItem(name: 'Bể nuôi 2'),
    MaintenanceItem(name: 'Blower chính'),
    MaintenanceItem(name: 'Oxygen hệ khí'),
  ];

  String _fmtHours(Duration d) => (d.inMinutes / 60.0).toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Lịch bảo trì'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
        ),
        body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = _items[index];
            final rem = item.timeRemaining;
            final overdue = rem.isNegative;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              decoration: BoxDecoration(
                color:
                    overdue ? Colors.redAccent.withOpacity(0.15) : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Icon cảnh báo / cập nhật
                  Icon(
                    overdue ? Icons.warning_amber_rounded : Icons.update,
                    size: 28,
                    color: overdue ? Colors.redAccent : Colors.blueGrey,
                  ),

                  const SizedBox(width: 14),

                  // Thông tin thiết bị
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Hoạt động: ${_fmtHours(item.operatingTime)} h',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          overdue
                              ? 'Quá hạn: ${_fmtHours(rem.abs())} h'
                              : 'Còn lại: ${_fmtHours(rem)} h',
                          style: TextStyle(
                            fontSize: 14,
                            color: overdue ? Colors.redAccent : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Nút Reset
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          overdue ? Colors.redAccent : CustomColors.appbarColor,
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        item.lastReset = DateTime.now();
                      });
                    },
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
