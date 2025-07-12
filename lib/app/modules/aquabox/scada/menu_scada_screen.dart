// lib/screens/scada_menu_screen.dart

import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'control_screen.dart';
import 'maintenance_screen.dart';
// import 'control_screen.dart';

class ScadaMenuScreen extends StatefulWidget {
  const ScadaMenuScreen({super.key});

  @override
  State<ScadaMenuScreen> createState() => _ScadaMenuScreenState();
}

class _ScadaMenuScreenState extends State<ScadaMenuScreen> {
  // ----- Danh sách hệ + mục con -----
  final _systems = <String, List<String>>{
    'Hệ 1': [
      'Hệ thống lọc nước',
      'Bể nuôi 1',
      'Bể nuôi 2',
      'Bể nuôi 3',
      'Máy cho ăn tự động 1',
      'Máy cho ăn tự động 2',
    ],
    'Hệ 2': [
      'Hệ thống lọc nước',
      'Bể nuôi 1',
      'Bể nuôi 2',
      'Bể nuôi 3',
      'Máy cho ăn tự động 1',
      'Máy cho ăn tự động 2',
    ],
    'Hệ 3': [
      'Hệ thống lọc nước',
      'Bể nuôi 1',
      'Bể nuôi 2',
      'Bể nuôi 3',
      'Máy cho ăn tự động 1',
      'Máy cho ăn tự động 2',
    ],
    'Trạm bơm': ['Hệ thống lọc nước'],
    'Nhà khí': [
      'Hệ thống blower',
      'Hệ thống oxygen',
    ],
  };

  late String _currentKey;

  @override
  void initState() {
    super.initState();
    _currentKey = _systems.keys.first;
  }

  // ---- Gán icon gợi ý cho từng label ----
  IconData _iconFor(String label) {
    final l = label.toLowerCase();
    if (l.contains('lọc nước')) return Icons.water_drop;
    if (l.contains('bể nuôi')) return Icons.pool;
    if (l.contains('máy cho ăn')) return Icons.restaurant;
    if (l.contains('blower')) return Icons.air;
    if (l.contains('oxygen')) return Icons.bubble_chart;
    return Icons.devices;
  }

  @override
  Widget build(BuildContext context) {
    final items = _systems[_currentKey]!;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Khu vực'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // ===== Thanh chip =====
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _systems.keys.map((key) {
                    final selected = key == _currentKey;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => setState(() => _currentKey = key),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context)
                                    .primaryColor
                                    .withOpacity(.15)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            key,
                            style: TextStyle(
                              fontWeight:
                                  selected ? FontWeight.bold : FontWeight.w500,
                              color: selected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(),

              // ===== Danh sách mục =====
              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('Chưa có mục cấu hình'))
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final crossCount =
                              (constraints.maxWidth ~/ 180).clamp(2, 4);
                          return GridView.count(
                            crossAxisCount: crossCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.2,
                            children: items.map((label) {
                              return Stack(
                                children: [
                                  // Card thiết bị chính
                                  Positioned.fill(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => DeviceControlScreen(
                                                label: label),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Hero(
                                                    tag: label,
                                                    child: Image.asset(
                                                      'assets/images/scada.png',
                                                      fit: BoxFit.fitWidth,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                label,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Nút 3 chấm (PopupMenu)
                                  Positioned(
                                    top: -12,
                                    right: -16,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 20,
                                        color: Colors.black54,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'control') {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  DeviceControlScreen(
                                                      label: label),
                                            ),
                                          );
                                        } else if (value == 'maint') {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  MaintenanceScreen(),
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        const PopupMenuItem(
                                            value: 'control',
                                            child: Text('Điều khiển',
                                                style:
                                                    TextStyle(fontSize: 15))),
                                        const PopupMenuItem(
                                            value: 'maint',
                                            child: Text('Bảo trì',
                                                style:
                                                    TextStyle(fontSize: 15))),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          );
                        },
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
