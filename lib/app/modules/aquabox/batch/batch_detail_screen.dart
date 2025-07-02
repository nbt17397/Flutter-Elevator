import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:elevator/config/shared/colors.dart';

/* ------------ Giả lập model ------------ */
class Pond {
  final String code;
  final int stocking;
  final String name;
  Pond(this.code, this.name, this.stocking);
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
    _ponds = List.generate(
        4, (i) => Pond('P${i + 1}', 'Bể nuôi ${i + 1}', 800 + i * 50));
  }

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
            itemBuilder: (BuildContext bc) => [
              PopupMenuItem(
                  value: "edit",
                  child: Text('Chỉnh sửa', style: TextStyle(fontSize: 14))),
              PopupMenuItem(
                  value: "delete",
                  child: Text('Xóa', style: TextStyle(fontSize: 14))),
            ],
            onSelected: (route) {
              switch (route) {
                case 'edit':
                  {
                    break;
                  }
                default:
                  {
                    break;
                  }
              }
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
                      border: Border.all(color: Colors.grey)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
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
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Danh sách bể nuôi',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: CustomColors.appbarColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const SizedBox.shrink()
                ),
              ],
            ),
            const SizedBox(height: 6),
            Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith(
                      (_) => Colors.black), // header đen
                  dataRowColor: MaterialStateProperty.resolveWith(
                      (_) => Colors.grey.shade300), // body xám
                  columnSpacing: 32,
                  columns: const [
                    DataColumn(
                        label: Text('Mã bể nuôi',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Tên bể nuôi',
                            style: TextStyle(color: Colors.white))),
                    DataColumn(
                        label: Text('Số lượng thực tế',
                            style: TextStyle(color: Colors.white))),
                  ],
                  rows: _ponds
                      .map((p) => DataRow(cells: [
                            DataCell(Text(p.code)),
                            DataCell(Text(p.name)),
                            DataCell(
                                Center(child: Text(p.stocking.toString()))),
                          ]))
                      .toList(),
                  showCheckboxColumn: false,
                ),
              ),
            ),
            const SizedBox(height: 20),

            /* ==== MENU 1 × 4 ==== */
            GridView.count(
              crossAxisCount: 2, // 👉 1 hàng 4 ô
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

  /* ---- Helpers ---- */

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
        onTap: () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade100),
          ),
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
      );
}
