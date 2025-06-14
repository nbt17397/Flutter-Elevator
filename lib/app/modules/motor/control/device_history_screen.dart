import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../config/shared/colors.dart';
import '../../../data/response/register_response.dart';

class DeviceHistoryScreen extends StatelessWidget {
  final RegisterDB register;
  const DeviceHistoryScreen({super.key, required this.register});

  final List<Map<String, dynamic>> mockHistory = const [
    {'status': true, 'timestamp': '2025-06-10 14:35:00'},
    {'status': false, 'timestamp': '2025-06-10 08:12:00'},
    {'status': true, 'timestamp': '2025-06-09 21:05:00'},
    {'status': false, 'timestamp': '2025-06-09 18:45:00'},
    {'status': true, 'timestamp': '2025-06-09 06:30:00'},
  ];

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('HH:mm:ss dd/MM/yyyy');

    final List<Map<String, String>> historyTable = mockHistory.map((item) {
      final DateTime time = DateTime.parse(item['timestamp']);
      return {
        'status': item['status'] ? 'Bật máy        ' : 'Tắt máy         ',
        'time': formatter.format(time),
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử - ${register.name}'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      headingRowColor:
                          MaterialStateColor.resolveWith((_) => Colors.black54),
                      columns: const [
                        DataColumn(
                          label: Text('Trạng thái',
                              style: TextStyle(color: Colors.white)),
                        ),
                        DataColumn(
                          label: Text('Thời gian',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                      rows: historyTable.map((entry) {
                        return DataRow(
                          cells: [
                            DataCell(Text(
                              entry['status']!,
                              style: TextStyle(
                                color: entry['status'] == 'Bật máy        '
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            )),
                            DataCell(Text(
                              entry['time']!,
                              style: const TextStyle(color: Colors.white),
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
