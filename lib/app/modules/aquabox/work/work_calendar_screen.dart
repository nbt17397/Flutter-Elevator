import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

/* ---------- Screen ---------- */
class WorkCalendarScreen extends StatefulWidget {
  const WorkCalendarScreen({super.key});

  @override
  State<WorkCalendarScreen> createState() => _WorkCalendarScreenState();
}

class _WorkCalendarScreenState extends State<WorkCalendarScreen> {
  final CalendarController _controller = CalendarController();

  @override
  void initState() {
    super.initState();
    _controller.view = CalendarView.day; // mặc định Tháng
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /* ---------- Dữ liệu giả ---------- */
  List<Appointment> _getDataSource() {
    final List<Appointment> list = [];
    final base = DateTime(DateTime.now().year, 5, 15, 8); // Thả giống

    // Thả giống & Thu hoạch
    list
      ..add(_appt(base, 'Thả giống'))
      ..add(_appt(DateTime(base.year, 7, 30), 'Thu hoạch'));

    for (int d = 0; d <= 135; d++) {
      final day = base.add(Duration(days: d));

      // Cho ăn sáng/chiều
      list
        ..add(_appt(day.add(const Duration(hours: -1)), 'Cho ăn sáng'))
        ..add(_appt(day.add(const Duration(hours: 8)), 'Cho ăn chiều'));

      if (d % 7 == 0)
        list.add(_appt(day.add(const Duration(hours: 2)), 'Kiểm tra nước'));
      if (d % 14 == 0)
        list.add(_appt(day.add(const Duration(hours: 3)), 'Đo mật độ'));
      if (d % 21 == 0)
        list.add(_appt(day.add(const Duration(hours: 4)), 'Kiểm tra sức khỏe'));
    }
    return list;
  }

  Appointment _appt(DateTime start, String title) => Appointment(
        startTime: start,
        endTime: start.add(const Duration(hours: 1)),
        subject: title,
      );

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    final isMonth = _controller.view == CalendarView.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch công việc'),
        centerTitle: true,
        backgroundColor: CustomColors.appbarColor,
        actions: [
          IconButton(
            tooltip: isMonth ? 'Xem theo ngày' : 'Xem theo tháng',
            icon: Icon(isMonth ? Icons.view_day : Icons.calendar_month),
            onPressed: () => setState(() {
              _controller.view =
                  isMonth ? CalendarView.day : CalendarView.month;
            }),
          ),
        ],
      ),
      body: SfCalendar(
        controller: _controller,
        dataSource: _CalendarDS(_getDataSource()),

        // Nhấn vào ô ngày (Month) → Day view
        onTap: (d) {
          if (_controller.view == CalendarView.month &&
              d.targetElement == CalendarElement.calendarCell &&
              d.date != null) {
            setState(() {
              _controller.selectedDate = d.date;
              _controller.view = CalendarView.day;
            });
          }
        },

        todayHighlightColor: Colors.red,
        headerStyle: const CalendarHeaderStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        monthViewSettings: const MonthViewSettings(
          appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
        ),
        timeSlotViewSettings: const TimeSlotViewSettings(
          minimumAppointmentDuration: Duration(minutes: 30),
        ),
        appointmentTextStyle:
            const TextStyle(color: Colors.white, fontSize: 10),

        /* ----- Tô màu theo trạng thái ----- */
        appointmentBuilder: (_, details) {
          final Appointment app = details.appointments.first;
          final now = DateTime.now();
          final start = app.startTime;
          final end = app.endTime;

          late final Color bg;
          if (end.isBefore(now)) {
            final diffH = now.difference(end).inHours;
            bg = diffH > 24 ? Colors.red : Colors.green; // trễ / hoàn thành
          } else if (start.isBefore(now)) {
            bg = Colors.orange.shade700; // đang diễn ra
          } else {
            bg = Colors.blueGrey; // tương lai
          }

          return Container(
            decoration: BoxDecoration(
                color: bg, borderRadius: BorderRadius.circular(4)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.centerLeft,
            child: Text(
              '${DateFormat.Hm().format(start)}  ${app.subject}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: CustomColors.appbarColor,
        onPressed: _showCreateDialog, // ⬅️ hàm tạo công việc
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateDialog() {
    // controllers
    final workerCtl = TextEditingController();
    final descCtl = TextEditingController();
    DateTime? startDT;
    DateTime? endDT;
    final _fmt = DateFormat('dd/MM/yyyy – HH:mm');

    InputDecoration _dec(String lbl) => InputDecoration(
          labelText: lbl,
          labelStyle: const TextStyle(fontSize: 13),
          isDense: true,
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue.shade700, width: 2)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );

    Future<void> _pickDT(bool isStart) async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (date == null) return;
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time == null) return;
      final dt =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
      setState(() {
        if (isStart) {
          startDT = dt;
          if (endDT != null && endDT!.isBefore(startDT!)) endDT = null;
        } else {
          endDT = dt;
        }
      });
    }

    Alert(
      context: context,
      title: "TẠO CÔNG VIỆC",
      style: AlertStyle(
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        titleStyle:
            TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
        isCloseButton: false,
      ),
      content: StatefulBuilder(
        builder: (ctx, setModal) => SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Column(
              children: [
                TextField(
                    controller: workerCtl, decoration: _dec('Người thực hiện')),
                const SizedBox(height: 10),
                TextField(
                    controller: descCtl, decoration: _dec('Mô tả chi tiết')),
                const SizedBox(height: 10),

                /* ---- Thời gian bắt đầu ---- */
                GestureDetector(
                  onTap: () => _pickDT(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      startDT == null
                          ? 'Thời gian bắt đầu'
                          : _fmt.format(startDT!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                /* ---- Thời gian kết thúc ---- */
                GestureDetector(
                  onTap: startDT == null ? null : () => _pickDT(false),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: startDT == null ? Colors.grey.shade200 : null,
                    ),
                    child: Text(
                      endDT == null
                          ? 'Thời gian kết thúc'
                          : _fmt.format(endDT!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text("Huỷ", style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.blue.shade700,
          onPressed: () {
            if (workerCtl.text.isEmpty ||
                descCtl.text.isEmpty ||
                startDT == null ||
                endDT == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
              );
              return;
            }

            // Thêm Appointment mới
            // setState(() {
            //   final ds = _controller.dataSource as _CalendarDS;
            //   ds.appointments!.add(Appointment(
            //     startTime: startDT!,
            //     endTime: endDT!,
            //     subject: descCtl.text,
            //     notes: workerCtl.text,             // có thể lưu worker ở notes
            //   ));
            //   _controller.notifyListeners(CalendarDataSourceAction.add, []);
            // });

            Navigator.pop(context);
          },
          child: const Text("Lưu", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }
}

/* ---------- DataSource ---------- */
class _CalendarDS extends CalendarDataSource {
  _CalendarDS(List<Appointment> src) {
    appointments = src;
  }
}
