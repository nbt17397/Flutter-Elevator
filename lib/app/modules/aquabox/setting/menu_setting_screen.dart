import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/setting/area/area_screen.dart';
import 'package:elevator/app/modules/aquabox/setting/formula/formula_screen.dart';
import 'package:elevator/app/modules/aquabox/setting/manager/employee_screen.dart';
import 'package:elevator/app/modules/aquabox/setting/unit/unit_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'alarm/alarm_setting_screen.dart';
import 'feeding_schedule/feeding_schedule_screen.dart';

/// Model đơn giản cho mỗi mục menu
class _MenuItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _MenuItem(this.title, this.icon, this.onTap);
}

/// Màn hình MENU CÀI ĐẶT TRANG TRẠI
class FarmSettingsMenuScreen extends StatelessWidget {
  const FarmSettingsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /* ===== Nhóm 1: Thức ăn ===== */
    final feedGroup = [
      _MenuItem(
        'Menu thức ăn',
        Icons.restaurant_menu,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => FeedFormulaScreen())),
      ),
      _MenuItem(
        'Lịch cho ăn',
        Icons.schedule,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => FeedingScheduleScreen())),
      ),
    ];

    /* ===== Nhóm 2: Hệ thống ===== */
    final systemGroup = [
       _MenuItem(
        'Khu vực',
        Icons.area_chart_sharp,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => AreaScreen())),
      ),
      _MenuItem(
        'Quản lý',
        Icons.person_3_outlined,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => EmployeeScreen())),
      ),
      _MenuItem(
        'Vật nuôi',
        Icons.feed,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => UnitScreen())),
      ),
      _MenuItem(
        'Đơn vị',
        Icons.straighten,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => UnitScreen())),
      ),
      _MenuItem(
        'Kích hoạt cảnh báo',
        Icons.notifications_active,
        () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => AlertSettingScreen())),
      ),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cài đặt'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _sectionTitle('Thức ăn'),
            ...feedGroup.map((e) => _menuTile(context, e)),
            const SizedBox(height: 20),
            _sectionTitle('Hệ thống'),
            ...systemGroup.map((e) => _menuTile(context, e)),
          ],
        ),
      ),
    );
  }

  /* ---- Widget tiêu đề nhóm ---- */
  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      );

  /* ---- Widget 1 ô menu ---- */
  Widget _menuTile(BuildContext ctx, _MenuItem item) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: item.onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16,horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 22, color: Theme.of(ctx).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      );
}
