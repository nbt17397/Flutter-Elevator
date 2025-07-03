import 'package:elevator/app/modules/aquabox/setting/formula/formula_screen.dart';
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
  final VoidCallback onTap; // callback mở màn hình chi tiết

  const _MenuItem(this.title, this.icon, this.onTap);
}

/// Màn hình MENU CÀI ĐẶT TRANG TRẠI
class FarmSettingsMenuScreen extends StatelessWidget {
  const FarmSettingsMenuScreen({super.key});

  /* --------- UI --------- */
  @override
  Widget build(BuildContext context) {
    // Danh sách menu – gọi Navigator.push(...) trong onTap theo dự án của bạn
    final items = [
      _MenuItem(
        'Menu thức ăn',
        Icons.restaurant_menu,
        () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => FeedFormulaScreen()));
        },
      ),
      _MenuItem(
        'Lịch cho ăn',
        Icons.schedule,
        () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => FeedingScheduleScreen()));
        },
      ),
      _MenuItem(
        'Đơn vị',
        Icons.straighten,
        () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => UnitScreen()));
        },
      ),
      _MenuItem(
        'Kích hoạt cảnh báo',
        Icons.notifications_active,
        () {
          Navigator.push(
              context, CupertinoPageRoute(builder: (context) => AlertSettingScreen()));
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.separated(
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final item = items[i];
            return InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: item.onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: _box,
                child: Row(
                  children: [
                    Icon(item.icon,
                        size: 28, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /* --------- BORDER STYLE --------- */
  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      );
}
