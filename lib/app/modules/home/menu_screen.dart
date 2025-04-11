import 'dart:async';

import 'package:elevator/app/components/shimmer_loading.dart';
import 'package:elevator/app/modules/elevator/alarm/alarm_elevator_screen.dart';
import 'package:elevator/app/modules/home/home_screen.dart';
import 'package:elevator/app/modules/setting/setting_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _menuController = StreamController<int>();

  @override
  void initState() {
    _menuController.sink.add(0);
    super.initState();
  }

  @override
  void dispose() {
    _menuController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return StreamBuilder(
        stream: _menuController.stream,
        builder: (context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError || !snapshot.hasData) {
            return ShimmerLoadingWidget();
          }
          return Scaffold(
            backgroundColor: CustomColors.primaryColor,
            extendBody: true,
            body: snapshot.data == 0
                ? HomeScreen()
                : snapshot.data == 1
                    ? AlarmElevatorScreen(boardID: 1)
                    : SettingScreen(),
            bottomNavigationBar: ClipRRect(
              child: FloatingNavbar(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                onTap: (int val) => _menuController.sink.add(val),
                margin: EdgeInsets.only(bottom: 1),
                currentIndex: snapshot.data ?? 0,
                backgroundColor: CustomColors.appbarColor,
                items: [
                  FloatingNavbarItem(icon: Icons.home, title: 'Thang máy'),
                  FloatingNavbarItem(
                      icon: Icons.notifications_active_outlined,
                      title: 'Thông báo'),
                  FloatingNavbarItem(icon: Icons.settings, title: 'Cài đặt'),
                ],
              ),
            ),
          );
        });
  }
}
