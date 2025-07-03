import 'package:elevator/app/modules/aquabox/scada/device_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ----------------- MODEL -----------------
class Device {
  String name;
  bool isOn;
  Device(this.name, {this.isOn = false});
}

/// ----------------- MÀN HÌNH ĐIỀU KHIỂN -----------------
class DeviceControlScreen extends StatefulWidget {
  final String label;
  const DeviceControlScreen({super.key, required this.label});

  @override
  State<DeviceControlScreen> createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  final _devices = [
    Device('Bơm nước 1'),
    Device('Van UV 1', isOn: true),
    Device('Van xả 1'),
    Device('Máy cho ăn tự động 1'),
    Device('Máy cho ăn tự động 2', isOn: true),
    Device('Bơm nước 2'),
    Device('Van UV 2', isOn: true),
    Device('Van xả 2'),
    Device('Máy cho ăn tự động 3'),
    Device('Máy cho ăn tự động 4', isOn: true),
    Device('Máy cho ăn tự động 5'),
    Device('Máy cho ăn tự động 6', isOn: true),
    Device('Máy cho ăn tự động 7'),
    Device('Máy cho ăn tự động 8', isOn: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ---------- ẢNH MINH HỌA ----------
          SliverAppBar(
            expandedHeight: 220,
            collapsedHeight: kToolbarHeight,
            backgroundColor: CustomColors.appbarColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Hero(
                tag: widget.label,
                transitionOnUserGestures: true,
                flightShuttleBuilder: (ctx, anim, dir, from, to) {
                  final curved =
                      CurvedAnimation(parent: anim, curve: Curves.easeInOut);
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: dir == HeroFlightDirection.push ? 0.95 : 1.05,
                        end: 1.0,
                      ).animate(curved),
                      child: to.widget,
                    ),
                  );
                },
                child: Image.asset(
                  'assets/images/scada.png', // đổi ảnh của bạn
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // title: const Text('Hệ thống lọc nước'),
            pinned: true, // cuộn xuống sẽ ẩn hẳn ảnh
          ),

          // ---------- DANH SÁCH THIẾT BỊ ----------
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final dev = _devices[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  DeviceDetailScreen(deviceName: dev.name)));
                    },
                    child: Container(
                      height: 58, // chiều cao thấp hơn ListTile
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.play_arrow_rounded, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dev.name,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Switch(
                            value: dev.isOn,
                            onChanged: (val) => setState(() => dev.isOn = val),

                            // === MÀU THEO TEMPLATE ===
                            activeColor: Colors.green,
                            activeTrackColor: Colors.green.shade200,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: _devices.length,
            ),
          ),
        ],
      ),
    );
  }
}
