import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/setting/feeding_schedule/feeding_schedule_detail_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FeedingSchedule {
  String batch;
  String formula;
  DateTime start;
  DateTime end;
  List<String> ponds;
  List<TimeOfDay> times;
  FeedingSchedule(
      this.batch, this.formula, this.start, this.end, this.ponds, this.times);
}

class FeedingScheduleScreen extends StatelessWidget {
  FeedingScheduleScreen({super.key});

  final _list = [
    FeedingSchedule(
        'BN999',
        'Grower 32%',
        DateTime(2025, 7, 1),
        DateTime(2025, 8, 15),
        ['Bể 1', 'Bể 2'],
        [const TimeOfDay(hour: 6, minute: 0), const TimeOfDay(hour: 17, minute: 0)]),
    FeedingSchedule(
        'BN998',
        'Shrimp Booster',
        DateTime(2025, 6, 20),
        DateTime(2025, 7, 20),
        ['Bể 3'],
        [const TimeOfDay(hour: 7, minute: 30), const TimeOfDay(hour: 12, minute: 0)]),
  ];

  BoxDecoration _box(BuildContext ctx) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Lịch cho ăn'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add))
          ],
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final s = _list[i];
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (_) => FeedingScheduleDetailScreen())),
              child: Container(
                decoration: _box(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: CustomColors.appbarColor.withOpacity(.95),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(s.formula,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white))),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.blue.shade200)),
                            child: Text('Vụ ${s.batch}',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700)),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 14, color: Colors.black87),
                              const SizedBox(width: 4),
                              Text('${_d(s.start)}  →  ${_d(s.end)}',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            children: s.ponds
                                .map((p) => Chip(
                                      label: Text(p,
                                          style: const TextStyle(fontSize: 12)),
                                      backgroundColor: Colors.green,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 0),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: s.times
                                .map((t) => Chip(
                                      label: Text(_t(t),
                                          style: const TextStyle(fontSize: 12)),
                                      backgroundColor: primary,
                                      labelStyle:
                                          const TextStyle(color: Colors.white),
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
            );
          },
        ),
      ),
    );
  }

  String _d(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  String _t(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
