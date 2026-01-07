import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/aquabox/scada/control_aquabox_screen.dart';
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
        'groupId': 5,
        'topic': ''
      },
      {
        'label': 'Xử lý phân',
        'active': true,
        'image': 'assets/images/xu-ly-phan.jpg',
        'groupId': 6,
        'topic': ''
      },
      {
        'label': 'Chuồng nuôi 1',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 7,
        'topic': ''
      },
      {
        'label': 'Chuồng nuôi 2',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 8,
        'topic': ''
      },
      {
        'label': 'Chuồng nuôi 3',
        'active': true,
        'image': 'assets/images/chuong-nuoi.jpg',
        'groupId': 9,
        'topic': ''
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
        'groupId': 1,
        'topic': ''
      },
    ],
    'Nhà khí': [
      {
        'label': 'Hệ thống blower',
        'active': false,
        'image': 'assets/images/scada.png',
        'groupId': 1,
        'topic': ''
      },
      {
        'label': 'Hệ thống oxygen',
        'active': false,
        'image': 'assets/images/oxygen.png',
        'groupId': 1,
        'topic': ''
      },
    ],
  };

  static List<Map<String, dynamic>> _defaultItems() {
    return [
      {
        'label': 'Demo thủy sản',
        'active': true,
        'image': 'assets/images/demo.png',
        'groupId': 1,
        'topic': ''
      },
      {
        'label': 'Bể nuôi 1',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1,
        'topic': ''
      },
      {
        'label': 'Bể nuôi 2',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1,
        'topic': ''
      },
      {
        'label': 'Bể nuôi 3',
        'active': false,
        'image': 'assets/images/pond.png',
        'groupId': 1,
        'topic': ''
      },
      {
        'label': 'Oxygen',
        'active': false,
        'image': 'assets/images/oxygen.png',
        'groupId': 1,
        'topic': ''
      },
    ];
  }

  final _systems3 = <String, List<Map<String, dynamic>>>{
    'Khu vực 1': [
      {
        'label': 'Điện năng & công suất',
        'active': true,
        'image': 'assets/images/device.png',
        'groupId': 10,
        'topic': ''
      },
    ],
    'Khu vực 2': []
  };

  final _systems4 = <String, List<Map<String, dynamic>>>{
    'Trạm bơm': [
      {
        'label': 'Trạm bơm',
        'active': true,
        'image': 'assets/images/trambom.png',
        'groupId': 11,
        'topic': 'NinhThuan/Aquabox/trambom/fb/main'
      },
      {
        'label': 'Runtime',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 49,
        'topic': 'aquabox_new/'
      }
    ],
    'Hệ 1': [
      {
        'label': 'Main',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 50,
        'topic': 'NinhThuan/Aquabox/he1/fb/main'
      },
      {
        'label': 'Bể nuôi 1',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 52,
        'topic': 'NinhThuan/Aquabox/he1/fb/be1'
      },
      {
        'label': 'Bể nuôi 2',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 53,
        'topic': 'NinhThuan/Aquabox/he1/fb/be2'
      },
      {
        'label': 'Bể nuôi 3',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 54,
        'topic': 'NinhThuan/Aquabox/he1/fb/be3'
      },
      {
        'label': 'Bess',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 51,
        'topic': 'NinhThuan/Aquabox/he1/fb/bess'
      },
       {
        'label': 'Oxyss',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 58,
        'topic': 'NinhThuan/Aquabox/he1/fb/oxyss'
      },
      {
        'label': 'Setting 1',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 55,
        'topic': 'NinhThuan/Aquabox/he1/fb/setting1'
      },
      {
        'label': 'Setting 2',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 56,
        'topic': 'NinhThuan/Aquabox/he1/fb/setting2'
      },
      {
        'label': 'Runtime',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 57,
        'topic': 'NinhThuan/Aquabox/he1/fb/runtime'
      },
    ],
    'Hệ 2': [
      {
        'label': 'Main',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 59,
        'topic': 'NinhThuan/Aquabox/he2/fb/main'
      },
      {
        'label': 'Bể nuôi 1',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 61,
        'topic': 'NinhThuan/Aquabox/he2/fb/be1'
      },
      {
        'label': 'Bể nuôi 2',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 62,
        'topic': 'NinhThuan/Aquabox/he2/fb/be2'
      },
      {
        'label': 'Bể nuôi 3',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 63,
        'topic': 'NinhThuan/Aquabox/he2/fb/be3'
      },
      {
        'label': 'Bess',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 60,
        'topic': 'NinhThuan/Aquabox/he2/fb/bess'
      },
       {
        'label': 'Oxyss',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 67,
        'topic': 'NinhThuan/Aquabox/he2/fb/oxyss'
      },
      {
        'label': 'Setting 1',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 64,
        'topic': 'NinhThuan/Aquabox/he2/fb/setting1'
      },
      {
        'label': 'Setting 2',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 65,
        'topic': 'NinhThuan/Aquabox/he2/fb/setting2'
      },
      {
        'label': 'Runtime',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 66,
        'topic': 'NinhThuan/Aquabox/he2/fb/runtime'
      },
    ],
    'Hệ 3': [
      {
        'label': 'Main',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 68,
        'topic': 'NinhThuan/Aquabox/he3/fb/main'
      },
      {
        'label': 'Bể nuôi 1',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 70,
        'topic': 'NinhThuan/Aquabox/he3/fb/be1'
      },
      {
        'label': 'Bể nuôi 2',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 71,
        'topic': 'NinhThuan/Aquabox/he3/fb/be2'
      },
      {
        'label': 'Bể nuôi 3',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 72,
        'topic': 'NinhThuan/Aquabox/he3/fb/be3'
      },
      {
        'label': 'Bess',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 69,
        'topic': 'NinhThuan/Aquabox/he3/fb/bess'
      },
       {
        'label': 'Oxyss',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 76,
        'topic': 'NinhThuan/Aquabox/he3/fb/oxyss'
      },
      {
        'label': 'Setting 1',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 73,
        'topic': 'NinhThuan/Aquabox/he3/fb/setting1'
      },
      {
        'label': 'Setting 2',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 74,
        'topic': 'NinhThuan/Aquabox/he3/fb/setting2'
      },
      {
        'label': 'Runtime',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 75,
        'topic': 'NinhThuan/Aquabox/he3/fb/runtime'
      },
    ],
    'Hệ 3A': [
      {
        'label': 'Main',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 77,
        'topic': 'NinhThuan/Aquabox/he4/fb/main'
      },
      {
        'label': 'Bể nuôi 1',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 79,
        'topic': 'NinhThuan/Aquabox/he4/fb/be1'
      },
      {
        'label': 'Bể nuôi 2',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 80,
        'topic': 'NinhThuan/Aquabox/he4/fb/be2'
      },
      {
        'label': 'Bể nuôi 3',
        'active': true,
        'image': 'assets/images/pond.png',
        'groupId': 81,
        'topic': 'NinhThuan/Aquabox/he4/fb/be3'
      },
      {
        'label': 'Bess',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 78,
        'topic': 'NinhThuan/Aquabox/he4/fb/bess'
      },
       {
        'label': 'Oxyss',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 85,
        'topic': 'NinhThuan/Aquabox/he4/fb/oxyss'
      },
      {
        'label': 'Setting 1',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 82,
        'topic': 'NinhThuan/Aquabox/he4/fb/setting1'
      },
      {
        'label': 'Setting 2',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 83,
        'topic': 'NinhThuan/Aquabox/he4/fb/setting2'
      },
      {
        'label': 'Runtime',
        'active': true,
        'image': 'assets/images/scada.png',
        'groupId': 84,
        'topic': 'NinhThuan/Aquabox/he4/fb/runtime'
      },
    ],
  };

  late String _currentKey;

  @override
  void initState() {
    super.initState();
    _currentKey = locationId == 5
        ? _systems1.keys.first
        : locationId == 7
            ? _systems4.keys.first
            : locationId == 6
                ? _systems3.keys.first
                : _systems2.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final items = locationId == 5
        ? _systems1[_currentKey]!
        : locationId == 6
            ? _systems3[_currentKey]!
            : locationId == 7
                ? _systems4[_currentKey]!
                : _systems2[_currentKey]!;

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
                      : locationId == 7
                          ? _systems4.keys.map((key) {
                              final selected = key == _currentKey;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  onTap: () =>
                                      setState(() => _currentKey = key),
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
                          : locationId == 6
                              ? _systems3.keys.map((key) {
                                  final selected = key == _currentKey;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () =>
                                          setState(() => _currentKey = key),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(.15)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                      onTap: () =>
                                          setState(() => _currentKey = key),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? Theme.of(context)
                                                  .primaryColor
                                                  .withOpacity(.15)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                            builder: (_) => AquaboxDeviceControlScreen(
                                              label: image,
                                              groupId: item['groupId'],
                                              topic: item['topic'],
                                            ),
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
                                                  AquaboxDeviceControlScreen(
                                                      label: image,
                                                      groupId: item['groupId'],
                                                      topic: item['topic']),
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
