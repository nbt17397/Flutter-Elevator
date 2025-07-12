import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

/// ===============================================================
///  MODELS (fake data only – thay thế khi nối API thực)
/// ===============================================================
class Ingredient {
  final String name;
  final int percent; // % cố định trong công thức
  Ingredient(this.name, this.percent);
}

class FeedHistory {
  final DateTime time;
  final String pond; // bể đã cho ăn
  final double massKg; // khối lượng cho ăn (kg)
  FeedHistory(this.time, this.pond, this.massKg);
}

/// ===============================================================
///  SCREEN : Chi tiết lịch cho ăn
/// ===============================================================
class FeedingScheduleDetailScreen extends StatefulWidget {
  const FeedingScheduleDetailScreen({super.key});

  @override
  State<FeedingScheduleDetailScreen> createState() =>
      _FeedingScheduleDetailScreenState();
}

class _FeedingScheduleDetailScreenState
    extends State<FeedingScheduleDetailScreen> {
  // ── FAKE DATA ─────────────────────────────────────────────────
  final _formulaName = 'Grower 32 %';
  final _ingredients = [
    Ingredient('Cám nổi 3 mm', 60),
    Ingredient('Cám chìm 2 mm', 30),
    Ingredient('Khoáng bổ sung', 10),
  ];
  final _history = <FeedHistory>[
    FeedHistory(
        DateTime.now().subtract(const Duration(hours: 2)), 'Bể 1', 12.0),
    FeedHistory(DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        'Bể 2', 10.0),
  ];

  // ── STATE ────────────────────────────────────────────────────
  double _mass = 10; // khối lượng / lần (kg)

  // ── STYLE ────────────────────────────────────────────────────
  static const _headerStyle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.w600);

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      );

  // ── UI ───────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_formulaName),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 1) KHỐI LƯỢNG / LẦN
                Container(
                  decoration: _box,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      const Text('Khối lượng mỗi lần: ',
                          style: TextStyle(fontSize: 15)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(
                            () => _mass = (_mass - 1).clamp(1, 100).toDouble()),
                      ),
                      Text('${_mass.toStringAsFixed(0)} kg',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(
                            () => _mass = (_mass + 1).clamp(1, 100).toDouble()),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
      
                // 2) BẢNG CÔNG THỨC
                Container(
                  decoration: _box,
                  child: SizedBox(
                    width: size.width - 24,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(CustomColors.appbarColor),
                      dataRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(
                            label: Text('Thành phần', style: _headerStyle)),
                        DataColumn(
                            numeric: true, label: Text('%', style: _headerStyle)),
                        DataColumn(
                            numeric: true,
                            label: Text('Khối lượng (kg)', style: _headerStyle)),
                      ],
                      rows: _ingredients
                          .map((ing) => DataRow(cells: [
                                DataCell(Text(ing.name)),
                                DataCell(Text('${ing.percent}%')),
                                DataCell(Text((_mass * ing.percent / 100)
                                    .toStringAsFixed(2))),
                              ]))
                          .toList(),
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
      
                // 3) BẢNG LỊCH SỬ CHO ĂN
                Container(
                  decoration: _box,
                  child: SizedBox(
                    width: size.width - 24,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(CustomColors.appbarColor),
                      dataRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                      columnSpacing: 24,
                      columns: const [
                        DataColumn(label: Text('Thời gian', style: _headerStyle)),
                        DataColumn(label: Text('Bể', style: _headerStyle)),
                        DataColumn(
                            numeric: true,
                            label: Text('Khối lượng (kg)', style: _headerStyle)),
                      ],
                      rows: _history.reversed
                          .map((h) => DataRow(cells: [
                                DataCell(Text(_fmt(h.time))),
                                DataCell(Text(h.pond)),
                                DataCell(Text(h.massKg.toStringAsFixed(2))),
                              ]))
                          .toList(),
                      showCheckboxColumn: false,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────
  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}
