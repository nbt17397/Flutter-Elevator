import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// ======== MODEL (fake) ========
class TaskAlert {
  final String code;
  final String title;
  final DateTime date;
  final String level;
  bool processed;
  TaskAlert(this.code, this.title, this.date, this.level,
      {this.processed = false});
}

class DeviceAlert {
  final String devCode;
  final String name;
  final String fault;
  final DateTime date;
  final String level;
  DeviceAlert(this.devCode, this.name, this.fault, this.date, this.level);
}

/// ======== SCREEN (stateful) ========
class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});
  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with SingleTickerProviderStateMixin {
  final List<TaskAlert> _taskAlerts = [];
  final List<DeviceAlert> _deviceAlerts = [];
  final _rng = Random();
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  static const int _pageSize = 10;
  static const int _maxItems = 100;

  bool _loadingTask = false;
  bool _loadingDevice = false;

  int _taskFilter = 0;

  final ScrollController _taskCtrl = ScrollController();
  final ScrollController _deviceCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _generateFakeData(isTask: true, count: _pageSize);
    _generateFakeData(isTask: false, count: _pageSize);
    _taskCtrl.addListener(() => _onScroll(true));
    _deviceCtrl.addListener(() => _onScroll(false));
  }

  @override
  void dispose() {
    _taskCtrl.dispose();
    _deviceCtrl.dispose();
    super.dispose();
  }

  void _onScroll(bool isTask) {
    final ctrl = isTask ? _taskCtrl : _deviceCtrl;
    final listLen = isTask ? _taskAlerts.length : _deviceAlerts.length;
    final loading = isTask ? _loadingTask : _loadingDevice;

    if (ctrl.position.pixels >= ctrl.position.maxScrollExtent - 200 &&
        !loading &&
        listLen < _maxItems) {
      _loadMore(isTask);
    }
  }

  void _loadMore(bool isTask) {
    setState(() {
      if (isTask) {
        _loadingTask = true;
      } else {
        _loadingDevice = true;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      final remain =
          _maxItems - (isTask ? _taskAlerts.length : _deviceAlerts.length);
      final count = remain < _pageSize ? remain : _pageSize;
      _generateFakeData(isTask: isTask, count: count);
      setState(() {
        if (isTask) {
          _loadingTask = false;
        } else {
          _loadingDevice = false;
        }
      });
    });
  }

  void _generateFakeData({required bool isTask, required int count}) {
    const levels = ['Cao', 'Trung bình', 'Thấp'];
    final now = DateTime.now();

    for (int i = 0; i < count; i++) {
      final id = (isTask ? _taskAlerts.length : _deviceAlerts.length) + i;
      final lv = levels[_rng.nextInt(3)];

      if (isTask) {
        _taskAlerts.add(TaskAlert(
          'CV${1000 + id}',
          'Chậm thời hạn công việc $id',
          now.subtract(Duration(hours: 2 + id)),
          lv,
          processed: _rng.nextBool(),
        ));
      } else {
        _deviceAlerts.add(DeviceAlert(
          'TB${200 + id}',
          'Máy sục khí $id',
          'Quá nhiệt',
          now.subtract(Duration(hours: id)),
          lv,
        ));
      }
    }
  }

  Color _colorFor(String lv) => switch (lv) {
        'Cao' => Colors.red.shade600,
        'Trung bình' => Colors.orange.shade700,
        _ => Colors.green.shade600,
      };

  IconData _iconFor(String lv) => switch (lv) {
        'Cao' => Icons.warning,
        'Trung bình' => Icons.report_problem,
        _ => Icons.info,
      };

  void _showConfirmDialog(TaskAlert alert) {
    final isProcessed = alert.processed;
    final msg = isProcessed
        ? 'Bạn có muốn xác nhận hoàn thành?'
        : 'Bạn có muốn xác nhận hoàn thành?';

    Alert(
      context: context,
      type: AlertType.warning,
      title: "Xác nhận",
      desc: msg,
      buttons: [
        DialogButton(
          child: const Text("Hủy", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
        DialogButton(
          child: Text(
            "Hoàn thành",
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            setState(() {
              alert.processed = !alert.processed;
            });
            Navigator.pop(context);
          },
          color: Colors.blueAccent,
        )
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Cảnh báo'),
            centerTitle: true,
            backgroundColor: CustomColors.appbarColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Lịch sử đã hoàn thành',
                onPressed: () {},
              ),
            ],
          ),
          body: TabBarView(
            children: [
              _taskTab(),
              _deviceTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _taskTab() {
    final list = _taskAlerts
        .where((a) => _taskFilter == 0 ? !a.processed : a.processed)
        .toList();

    return Column(
      children: [
        const SizedBox(height: 8),
        _TaskSegment(
          selected: _taskFilter,
          onChanged: (i) => setState(() => _taskFilter = i),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _alertList(
            isTask: true,
            controller: _taskCtrl,
            dataLen: list.length,
            loading: _loadingTask,
            itemBuilder: (i) {
              final a = list[i];
              return _alertCard(
                leading: a.code,
                title: a.title,
                subtitle: _fmt.format(a.date),
                level: a.level,
                onTap: () => _showConfirmDialog(a),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _deviceTab() => _alertList(
        isTask: false,
        controller: _deviceCtrl,
        dataLen: _deviceAlerts.length,
        loading: _loadingDevice,
        itemBuilder: (i) {
          final d = _deviceAlerts[i];
          return _alertCard(
            leading: d.devCode,
            title: '${d.name} – ${d.fault}',
            subtitle: _fmt.format(d.date),
            level: d.level,
          );
        },
      );

  Widget _alertList({
    required bool isTask,
    required ScrollController controller,
    required int dataLen,
    required bool loading,
    required Widget Function(int) itemBuilder,
  }) =>
      RefreshIndicator(
        onRefresh: () async {
          setState(() {
            if (isTask) {
              _taskAlerts.clear();
              _loadingTask = false;
              _generateFakeData(isTask: true, count: _pageSize);
            } else {
              _deviceAlerts.clear();
              _loadingDevice = false;
              _generateFakeData(isTask: false, count: _pageSize);
            }
          });
        },
        child: ListView.separated(
          controller: controller,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: dataLen + (loading ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, idx) {
            if (idx >= dataLen) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return itemBuilder(idx);
          },
        ),
      );

  Widget _alertCard({
    required String leading,
    required String title,
    required String subtitle,
    required String level,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _colorFor(level).withOpacity(.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_iconFor(level), color: _colorFor(level)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorFor(level).withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(level,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _colorFor(level))),
              ),
            ],
          ),
        ),
      );
}

/// ======== Segment Widget ========
class _TaskSegment extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TaskSegment({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _segBtn('Công việc', 0),
          _segBtn('Thiết bị', 1),
        ],
      ),
    );
  }

  Expanded _segBtn(String text, int idx) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.horizontal(
            left: idx == 0 ? const Radius.circular(8) : Radius.zero,
            right: idx == 1 ? const Radius.circular(8) : Radius.zero,
          ),
          onTap: () => onChanged(idx),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected == idx
                  ? const Color(0xFFDDE1EA)
                  : Colors.transparent,
              borderRadius: BorderRadius.horizontal(
                left: idx == 0 ? const Radius.circular(8) : Radius.zero,
                right: idx == 1 ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
}
