import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'control_screen.dart';
import 'maintenance_screen.dart';

class ScadaMenuScreen extends StatefulWidget {
  final int locationId;
  const ScadaMenuScreen({super.key, required this.locationId});

  @override
  State<ScadaMenuScreen> createState() => _ScadaMenuScreenState();
}

class _ScadaMenuScreenState extends State<ScadaMenuScreen> {
  int get locationId => widget.locationId;
  // Mỗi item gồm label, active, image
  final _systems1 = <String, List<Map<String, dynamic>>>{
    'Hệ 1': [
      {
        'label': 'Cho ăn tự động',
        'active': true,
        'image': 'assets/images/cho-an-tu-dong.jpg',
        'groupId': 5
      },
      {
        'label': 'Xử lý phân',
        'active': true,
        'image': 'assets/images/xu-ly-phan.jpg',
        'groupId': 6
      },
      {
        'label': 'Chuồng nuôi 1',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 7
      },
      {
        'label': 'Chuồng nuôi 2',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 8
      },
      {
        'label': 'Chuồng nuôi 3',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 9
      },
    ],
    'Hệ 2': [],
    'Hệ 3': []
  };
  final _systems2 = <String, List<Map<String, dynamic>>>{
    'Hệ 1': _defaultItems(),
    'Hệ 2': _defaultItems(),
    'Hệ 3': _defaultItems(),
    'Trạm bơm': [
      {
        'label': 'Hệ thống lọc nước',
        'active': false,
        'image': 'assets/images/scada.png',
        'groupId': 1
      },
    ],
    'Nhà khí': [
      {
        'label': 'Hệ thống blower',
        'active': false,
        'image': 'assets/images/scada.png',
        'groupId': 1
      },
      {
        'label': 'Hệ thống oxygen',
        'active': false,
        'image': 'assets/images/oxygen.png',
        'groupId': 1
      },
    ],
  };

  static List<Map<String, dynamic>> _defaultItems() {
    return [
      {
        'label': 'Demo thủy sản',
        'active': true,
        'image': 'assets/images/demo.png',
        'groupId': 1
      },
      {
        'label': 'Bể nuôi 1',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1
      },
      {
        'label': 'Bể nuôi 2',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1
      },
      {
        'label': 'Bể nuôi 3',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1
      },
      {
        'label': 'Oxygen',
        'active': false,
        'image': 'assets/images/oxygen.png',
        'groupId': 1
      },
    ];
  }

  late String _currentKey;

  @override
  void initState() {
    super.initState();
    _currentKey = locationId == 5 ? _systems1.keys.first : _systems2.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final items =
        locationId == 5 ? _systems1[_currentKey]! : _systems2[_currentKey]!;

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
                  children: locationId == 5
                      ? _systems1.keys.map((key) {
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
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: selected
                                        ? Theme.of(context).primaryColor
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList()
                      : _systems2.keys.map((key) {
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
                                    fontWeight: selected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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
                            childAspectRatio: 1.4,
                            children: items.map((item) {
                              final label = item['label'] as String;
                              final active = item['active'] as bool;
                              final image = item['image'] as String;

                              return Stack(
                                children: [
                                  // Card thiết bị chính
                                  Positioned.fill(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        if (!active) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              duration: Duration(seconds: 1),
                                              content: Text(
                                                  '$label hiện chưa hoạt động.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (_) => DeviceControlScreen(
                                                label: image,
                                                groupId: item['groupId']),
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
                                                      const EdgeInsets.fromLTRB(
                                                          8, 8, 8, 0),
                                                  child: Hero(
                                                    tag: label,
                                                    child: Image.asset(
                                                      image,
                                                      fit: BoxFit.fitHeight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                label,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: active
                                                        ? Colors.black
                                                        : Colors.red),
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
                                      icon: const Icon(Icons.more_vert,
                                          size: 20, color: Colors.black54),
                                      onSelected: (value) {
                                        if (!active) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '$label hiện chưa hoạt động.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
                                        if (value == 'control') {
                                          Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (_) =>
                                                  DeviceControlScreen(
                                                      label: image,
                                                      groupId: item['groupId']),
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
                                          child: Text('Cảnh báo',
                                              style: TextStyle(fontSize: 15)),
                                        ),
                                        const PopupMenuItem(
                                          value: 'maint',
                                          child: Text('Bảo trì',
                                              style: TextStyle(fontSize: 15)),
                                        ),
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
