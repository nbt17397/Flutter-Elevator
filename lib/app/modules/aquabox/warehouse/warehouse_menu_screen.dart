import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

import 'inbound/inbound_screen.dart';
import 'inventory/inventory_screen.dart';
import 'outbound/outbound_screen.dart';
import 'report/warehouse_report_screen.dart';

class WarehouseMenuScreen extends StatelessWidget {
  const WarehouseMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý kho'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              _menuButton(
                context,
                asset: 'assets/images/inventory.png',
                label: 'Tồn kho',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => InventoryScreen())),
              ),
              _menuButton(
                context,
                asset: 'assets/images/inbound.png',
                label: 'Nhập kho',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => InboundScreen())),
              ),
              _menuButton(
                context,
                asset: 'assets/images/outbound.png',
                label: 'Xuất kho',
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => OutboundScreen())),
              ),
              _menuButton(
                context,
                asset: 'assets/images/checklist.png',
                label: 'Báo cáo',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => WarehouseReportScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuButton(BuildContext ctx,
      {required String asset,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              asset,
              width: 58,
              height: 58,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
