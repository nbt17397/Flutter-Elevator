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
  final int released;   // số lượng thả ban đầu
  final int remain;     // số lượng còn lại
  Pond(this.code, this.name, this.released, this.remain);
}

class BatchDetailScreen extends StatefulWidget {
  const BatchDetailScreen({super.key});
  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  late final Map<String, dynamic> _batch;
  late final List<Pond> _ponds;

  @override
  void initState() {
    super.initState();
    _batch = {
      'code': 'BN999',
      'name': 'Tôm Xuân 2025',
      'type': 'Tôm',
      'manager': 'Nguyễn Văn A',
      'start': DateTime(2025, 1, 15),
      'end': DateTime(2025, 5, 30),
      'total': 3500,
      'status': 'Đang nuôi',
    };

    // giả lập 4 bể: thả 800‑950 con, còn lại ±5%
    _ponds = List.generate(4, (i) {
      final released = 800 + i * 50;
      final remain = (released * .95).round(); // còn lại 95% (ví dụ)
      return Pond('P${i + 1}', 'Bể nuôi ${i + 1}', released, remain);
    });
  }

  /* ---------------- UI ---------------- */
  @override
  Widget build(BuildContext context) {
    final b = _batch;

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết ${b['code']}'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
        actions: [
          PopupMenuButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
            // ------- THÔNG TIN LÔ NUÔI -------
            Stack(
              children: [
                Positioned(
                  right: 4,
                  top: 0,
                  child: Chip(
                    label: Text(b['status'],
                        style: const TextStyle(color: Colors.black)),
                    backgroundColor: Colors.orange.shade200,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _info('Tên', b['name']),
                      const SizedBox(height: 4),
                      _info('Loại', b['type']),
                      _info('Quản lý', b['manager']),
                      const SizedBox(height: 4),
                      _info('Thời gian',
                          '${_fmt.format(b['start'])} → ${_fmt.format(b['end'])}'),
                      _info('Số lượng thả', b['total'].toString()),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ------- DANH SÁCH BỂ -------
            Row(
              children: [
                const Text('Danh sách bể nuôi',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {}, // TODO: thêm bể
                  style: TextButton.styleFrom(
                    backgroundColor: CustomColors.appbarColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const SizedBox.shrink(),
                ),
              ],
            ),
            const SizedBox(height: 6),

            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor:
                      MaterialStateProperty.all(Colors.black),          // header
                  dataRowColor: MaterialStateProperty.all(
                      Colors.grey.shade300),                            // body
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(
                        label: Text('Mã bể', style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Tên bể', style: TextStyle(color: Colors.white))),
                    DataColumn(
                        numeric: true,
                        label: Text('Số lượng thả',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        numeric: true,
                        label: Text('Thực tế',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: _ponds
                      .map((p) => DataRow(cells: [
                            DataCell(Text(p.code)),
                            DataCell(Text(p.name)),
                            DataCell(Center(child: Text(p.released.toString()))),
                            DataCell(Center(child: Text(p.remain.toString()))),
                          ]))
                      .toList(),
                  showCheckboxColumn: false,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ------- MENU CHỨC NĂNG -------
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.7,
              children: [
                _menu(Icons.bar_chart, 'Mật độ nuôi'),
                _menu(Icons.restaurant, 'Thức ăn'),
                _menu(Icons.water_drop, 'Chất lượng nước'),
                _menu(Icons.health_and_safety, 'Sức khoẻ'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /* ---------------- Widgets Helper ---------------- */
  Widget _info(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(
          children: [
            SizedBox(width: 110, child: Text('$k:')),
            Expanded(
                child: Text(v,
                    style: const TextStyle(fontWeight: FontWeight.w500))),
          ],
        ),
      );

  Widget _menu(IconData ico, String title) => InkWell(
        onTap: () {
          switch (title) {
            case "Mật độ nuôi":
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ReportDensityScreen()));
              break;
            case "Thức ăn":
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => FeedReportScreen()));
              break;
            case "Chất lượng nước":
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => WaterQualityReportScreen()));
              break;
            default:
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => HealthReportScreen()));
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
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
                    switch (title) {
                      case "Mật độ nuôi":
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DensityScreen()));
                        break;
                      case "Thức ăn":
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => FeedScreen()));
                        break;
                      case "Chất lượng nước":
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => WaterQualityScreen()));
                        break;
                      default:
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => HealthScreen()));
                    }
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: CustomColors.appbarColor,
                      shape: BoxShape.circle,
                    ),
                    child:
                        const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
