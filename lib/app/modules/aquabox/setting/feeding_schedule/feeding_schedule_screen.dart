import 'package:elevator/app/modules/aquabox/setting/feeding_schedule/feeding_schedule_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedingSchedule {
  String formula;
  DateTime start;
  DateTime end;
  List<String> ponds;
  List<TimeOfDay> times;
  FeedingSchedule(this.formula, this.start, this.end, this.ponds, this.times);
}

class FeedingScheduleScreen extends StatelessWidget {
  FeedingScheduleScreen({super.key});

  final _list = [
    FeedingSchedule('Grower 32%', DateTime(2025, 7, 1), DateTime(2025, 8, 15), [
      'Bể 1',
      'Bể 2'
    ], [
      const TimeOfDay(hour: 6, minute: 0),
      const TimeOfDay(hour: 17, minute: 0)
    ]),
    FeedingSchedule(
        'Shrimp Booster', DateTime(2025, 6, 20), DateTime(2025, 7, 20), [
      'Bể 3'
    ], [
      const TimeOfDay(hour: 7, minute: 30),
      const TimeOfDay(hour: 12, minute: 0)
    ]),
  ];

  BoxDecoration _box(BuildContext ctx) => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch cho ăn'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Thêm lịch',
            onPressed: () {},
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final s = _list[i];
          return ClipRRect(
            child: Banner(
              message: 'Active',
              location: BannerLocation.bottomEnd,
              color: Colors.green,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => FeedingScheduleDetailScreen()));
                },
                child: Container(
                  decoration: _box(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ===== Dải công thức nổi bật =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(.15), // nền nổi bật
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)), // bo góc trên
                        ),
                        child: Text(s.formula,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: primary)),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(12, 8, 12, 10), // gọn hơn
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thời gian
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 14),
                                const SizedBox(width: 4),
                                Text('${_d(s.start)}  →  ${_d(s.end)}',
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Bể áp dụng
                            Wrap(
                              spacing: 6,
                              runSpacing: -4,
                              children: s.ponds
                                  .map((p) => Chip(
                                        label: Text(p,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        shape: const StadiumBorder(
                                            side:
                                                BorderSide(color: Colors.grey)),
                                        backgroundColor: Colors.green,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 4),

                            // Giờ cho ăn
                            Wrap(
                              spacing: 6,
                              runSpacing: -4,
                              children: s.times
                                  .map((t) => Chip(
                                        label: Text(_t(t),
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        backgroundColor: primary,
                                        shape: const StadiumBorder(
                                            side: BorderSide.none),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 0),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _t(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
