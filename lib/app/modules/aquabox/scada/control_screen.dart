import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/scada/device_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Device {
  String name;
  bool isOn;
  Device(this.name, {this.isOn = false});
}

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
    Device('Bơm nước 1'),
    Device('Van UV 1', isOn: true),
    Device('Van xả 1'),
    Device('Máy cho ăn tự động 1'),
    Device('Máy cho ăn tự động 2', isOn: true),
    Device('Bơm nước 1'),
    Device('Van UV 1', isOn: true),
    Device('Van xả 1'),
    Device('Máy cho ăn tự động 1'),
    Device('Máy cho ăn tự động 2', isOn: true),
  ];

  bool _autoMode = false;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              collapsedHeight: kToolbarHeight,
              backgroundColor: CustomColors.appbarColor,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Hero(
                  tag: widget.label,
                  transitionOnUserGestures: true,
                  child: Image.asset(
                    'assets/images/scada.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              pinned: true,
            ),

            // ======= Chế độ điều khiển =======
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.settings_suggest_outlined, size: 20),
                      const SizedBox(width: 8),
                      const Text('Chế độ điều khiển'),
                      const Spacer(),
                      Text(
                        _autoMode ? 'AUTO' : 'MANUAL',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _autoMode ? Colors.green : Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Switch(
                        value: _autoMode,
                        onChanged: (val) => setState(() => _autoMode = val),
                        activeColor: Colors.green,
                        activeTrackColor: Colors.green.shade200,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (!_autoMode)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final dev = _devices[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  DeviceDetailScreen(deviceName: dev.name),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.play_arrow, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  dev.name,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              Switch(
                                value: dev.isOn,
                                onChanged: (val) =>
                                    setState(() => dev.isOn = val),
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
      ),
    );
  }
}
