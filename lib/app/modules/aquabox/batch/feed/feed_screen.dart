import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* ---- Model ---- */
class FeedRecord {
  final String feedName;
  final DateTime time;
  final double weightKg;
  FeedRecord(this.feedName, this.time, this.weightKg);
}

/* ---- Screen ---- */
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _fmtTime = DateFormat('HH:mm dd/MM');
  final List<FeedRecord> _feeds = [
    FeedRecord(
        'Cám 1', DateTime.now().subtract(const Duration(hours: 6)), 12.5),
    FeedRecord(
        'Cám nổi', DateTime.now().subtract(const Duration(hours: 3)), 8.0),
    FeedRecord('Cám chìm', DateTime.now(), 10.0),
  ];

  final _formKey = GlobalKey<FormState>(); // (để đồng bộ với pattern cũ)
  bool _auto = false; // cập nhật tự động?

  /* ---- UI ---- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cập nhật thức ăn'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            // giữ cấu trúc
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* --- AUTO SWITCH --- */
                Row(
                  children: [
                    const Expanded(
                      child: Text('Cập nhật tự động',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: _auto,
                      onChanged: (v) => setState(() => _auto = v),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                /* --- NÚT MENU & IMPORT --- */
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: mở danh mục thức ăn
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: CustomColors.appbarColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.list_alt, size: 18),
                        label: const Text('Menu thức ăn',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () {
                          // TODO: import file excel / csv
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: CustomColors.appbarColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: const Text('Import thức ăn',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Danh sách thức ăn trong ngày',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
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

                /* --- DATATABLE --- */
                SizedBox(
                  width: MediaQuery.of(context).size.width - 24,
                  child: DataTable(
                    headingRowColor:
                        WidgetStateProperty.resolveWith((_) => Colors.black),
                    dataRowColor:
                        WidgetStateProperty.resolveWith((_) => Colors.white),
                    columnSpacing: 32,
                    columns: const [
                      DataColumn(
                          label: Text('Thức ăn',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          label: Text('Thời gian',
                              style: TextStyle(color: Colors.white))),
                      DataColumn(
                          numeric: true,
                          label: Text('Khối lượng (kg)',
                              style: TextStyle(color: Colors.white))),
                    ],
                    rows: _feeds
                        .map((f) => DataRow(cells: [
                              DataCell(Text(f.feedName)),
                              DataCell(Text(_fmtTime.format(f.time))),
                              DataCell(Center(child: Text(f.weightKg.toStringAsFixed(1)))),
                            ]))
                        .toList(),
                    showCheckboxColumn: false,
                  ),
                ),
              ],
            ),
          ),
        ),

        /* --- NÚT CẬP NHẬT THỦ CÔNG --- */
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _auto ? null : () {/* TODO: submit feed updates */},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: CustomColors.appbarColor,
              disabledBackgroundColor: Colors.grey,
            ),
            child: const Text('Cập nhật thủ công',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
