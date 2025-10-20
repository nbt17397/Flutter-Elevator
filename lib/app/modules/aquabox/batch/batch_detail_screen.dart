import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/batch/density/density_sceen.dart';
import 'package:elevator/app/modules/aquabox/batch/density/report_density_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/feed/feed_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/feed/report_feed_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/health/health_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/health/report_health_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/water_quality/water_quality_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/water_quality/report_water_quality_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* ------------ Giả lập model ------------ */
class Pond {
  final String code;
  final String name;
  final int released; // số lượng thả ban đầu
  final int remain; // số lượng còn lại
  final String type;

  Pond(this.code, this.name, this.released, this.remain, this.type);
}

// Chuyển sang StatelessWidget vì dữ liệu được truyền vào từ bên ngoài
class BatchDetailScreen extends StatelessWidget {
  final Map<String, dynamic> batch;
  final List<Pond> ponds;
  final bool isTest;

  BatchDetailScreen({
    super.key,
    required this.batch,required this.isTest,
  }) : ponds = List.generate(4, (i) {
          final released = 800 + i * 50;
          final remain = (released * .95).round();
          return Pond(
              'P${i + 1}',
              '${batch['type'] == 'Tôm' || batch['type'] == 'Cá' ? 'Bể nuôi' : 'Chuồng nuôi'} ${i + 1}',
              released,
              remain,
              batch['type']);
        });

  final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    final b = batch;
    final isAquatic = b['type'] == 'Tôm' || b['type'] == 'Cá';
    final pondName = isAquatic ? 'Bể nuôi' : 'Chuồng';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(b['code']),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            PopupMenuButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              itemBuilder: (bc) => const [
                PopupMenuItem(value: "edit", child: Text('Chỉnh sửa')),
                PopupMenuItem(value: "delete", child: Text('Xóa')),
              ],
              onSelected: (v) {
                // TODO: xử lý edit / delete
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _info('Tên', b['name']),
                        const SizedBox(height: 4),
                        _info('Loại', b['type']),
                        _info('Quản lý', b['manager'] ?? 'Chưa xác định'),
                        const SizedBox(height: 4),
                        _info('Thời gian',
                            '${_fmt.format(b['start'])} → ${_fmt.format(b['end'])}'),
                        _info('Số lượng thả', b['total'].toString()),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    child: Chip(
                      label: Text(b['status'],
                          style: const TextStyle(color: Colors.black)),
                      backgroundColor: Colors.orange.shade200,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Danh sách $pondName',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      backgroundColor: CustomColors.appbarColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: MediaQuery.of(context).size.width - 24,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.black),
                  dataRowColor: WidgetStateProperty.all(Colors.white),
                  columnSpacing: 32,
                  columns: [
                    DataColumn(
                        label: Text('Mã',
                            style: const TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Tên $pondName',
                            style: const TextStyle(color: Colors.white))),
                    DataColumn(
                        numeric: true,
                        label: const Text('SL',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        numeric: true,
                        label: const Text('Thực tế',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: ponds
                      .map((p) => DataRow(cells: [
                            DataCell(Text(p.code)),
                            DataCell(Text(p.name)),
                            DataCell(Text(p.released.toString())),
                            DataCell(Text(p.remain.toString())),
                          ]))
                      .toList(),
                  showCheckboxColumn: false,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.7,
                children: [
                  _menu(context, Icons.bar_chart, 'Mật độ nuôi', batch, ponds),
                  _menu(context, Icons.restaurant, 'Thức ăn', batch, ponds),
                  _menu(
                      context,
                      isAquatic ? Icons.water_drop : Icons.air,
                      isAquatic ? 'Chất lượng nước' : 'Chất lượng không khí',
                      batch,
                      ponds),
                  _menu(context, Icons.health_and_safety, 'Sức khoẻ', batch,
                      ponds),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /* ---------------- Widgets Helper ---------------- */
  Widget _info(String k, dynamic v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text('$k:')),
            Expanded(
                child: Text(v.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _menu(
    BuildContext context,
    IconData ico,
    String title,
    Map<String, dynamic> batch,
    List<Pond> ponds,
  ) {
    final isAquatic = batch['type'] == 'Tôm' || batch['type'] == 'Cá';

    // Determine the report/add screen to navigate to based on title
    Widget reportScreen;
    Widget addScreen;

    switch (title) {
      case "Mật độ nuôi":
        // Đúng: Sử dụng tên widget đã refactor
        reportScreen = ReportDensityScreen(isAquatic: isAquatic);
        addScreen = DensityScreen(isAquatic: isAquatic);
        break;
      case "Thức ăn":
        reportScreen = FeedReportScreen(isAquatic: isAquatic);
        addScreen = FeedScreen(isAquatic: isAquatic);
        break;
      case "Chất lượng nước":
        reportScreen = WaterQualityReportScreen(isAquatic: isAquatic, isTest: isTest);
        addScreen = WaterQualityScreen(isAquatic: isAquatic);
        break;
      case "Chất lượng không khí":
        reportScreen = WaterQualityReportScreen(isAquatic: isAquatic, isTest: isTest,);
        addScreen = WaterQualityScreen(isAquatic: isAquatic);
        break;
      case "Sức khoẻ":
        reportScreen = HealthReportScreen(isAquatic: isAquatic);
        addScreen = HealthScreen(isAquatic: isAquatic);
        break;
      default:
        return const SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => reportScreen));
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ico, size: 32, color: Colors.blue.shade700),
                  const SizedBox(height: 6),
                  Text(title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => addScreen));
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: CustomColors.appbarColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
