// lib/screens/batch_list_screen.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../../config/shared/colors.dart';
import '../../../components/app_background.dart';
import 'batch_detail_screen.dart';

/* =============================================================== */
/*                          MAIN SCREEN                            */
/* =============================================================== */
class BatchListScreen extends StatefulWidget {
  const BatchListScreen({super.key});

  @override
  State<BatchListScreen> createState() => _BatchListScreenState();
}

class _BatchListScreenState extends State<BatchListScreen> {
  /* ---------- fake data ---------- */
  final List<Map<String, dynamic>> _batches = List.generate(20, (i) {
    final rnd = Random();
    final now = DateTime.now();
    return {
      'code': 'BN${100 + i}',
      'type': ['Heo', 'Gà', 'Tôm', 'Cá'][i % 4],
      'start': now.subtract(Duration(days: rnd.nextInt(180))),
      'status': ['Đang nuôi', 'Khởi tạo', 'Kết thúc'][i % 3],
      'total': '${800 + rnd.nextInt(600)}',
    };
  });

  final List<String> _tabs = ['Đang nuôi', 'Khởi tạo', 'Kết thúc'];
  int _selectedIdx = 0; // 0 → Đang nuôi
  String get _selectedStatus => _tabs[_selectedIdx];

  final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  /* ---------- helpers ---------- */
  Color _statusColor(String s) => switch (s) {
        'Khởi tạo' => Colors.grey,
        'Đang nuôi' => Colors.blue,
        'Kết thúc' => Colors.green,
        _ => Colors.amber,
      };

  int _countFor(String s) => _batches.where((b) => b['status'] == s).length;

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    final visible =
        _batches.where((b) => b['status'] == _selectedStatus).toList();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Vụ nuôi'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              tooltip: 'Thêm vụ nuôi',
              icon: const Icon(Icons.add),
              onPressed: _showCreateDialog,
            )
          ],
        ),

        /* ---------------- BODY ---------------- */
        body: Column(
          children: [
            const SizedBox(height: 12),

            /* -------- segmented buttons -------- */
            Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                // border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _segBtn('Đang nuôi', 0),
                  _segBtn('Khởi tạo', 1),
                  _segBtn('Kết thúc', 2),
                ],
              ),
            ),
            const SizedBox(height: 12),

            /* -------------- list --------------- */
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 24),
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final b = visible[index];
                  final clr = _statusColor(b['status']);
                  return _BatchTile(
                    b: b,
                    clr: clr,
                    fmt: _fmt,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const BatchDetailScreen()),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---------- segmented button ---------- */
  Expanded _segBtn(String text, int idx) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.horizontal(
            left: idx == 0 ? const Radius.circular(8) : Radius.zero,
            right: idx == 2 ? const Radius.circular(8) : Radius.zero,
          ),
          onTap: () => setState(() => _selectedIdx = idx),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _selectedIdx == idx
                  ? const Color(0xFFDDE1EA) // ô được chọn
                  : Colors.transparent,
              borderRadius: BorderRadius.horizontal(
                left: idx == 0 ? const Radius.circular(8) : Radius.zero,
                right: idx == 2 ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            child: Text(
              '$text (${_countFor(text)})',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );

  /* ---------- dialog thêm mới (giữ logic cũ) ---------- */
  void _showCreateDialog() {
    final nameCtl = TextEditingController();
    final codeCtl = TextEditingController();
    final totalCtl = TextEditingController();
    String? animal;
    String? status;
    DateTime? startDate, endDate;

    const animals = ['Heo', 'Gà', 'Tôm', 'Cá'];
    const statuses = ['Đang nuôi', 'Khởi tạo', 'Kết thúc'];

    InputDecoration _dec(String lbl) => InputDecoration(
          labelText: lbl,
          isDense: true,
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );

    Future<void> _pickDate(bool isStart) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          if (isStart) {
            startDate = picked;
            if (endDate != null && endDate!.isBefore(startDate!)) {
              endDate = null;
            }
          } else {
            endDate = picked;
          }
        });
      }
    }

    Alert(
      context: context,
      title: "THÊM VỤ NUÔI",
      style: AlertStyle(
        titleStyle: const TextStyle(
            color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: StatefulBuilder(
        builder: (ctx, setModal) => SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .8,
            child: Column(
              children: [
                const Divider(),
                TextField(controller: nameCtl, decoration: _dec('Tên vụ nuôi')),
                const SizedBox(height: 10),
                TextField(controller: codeCtl, decoration: _dec('Mã vụ nuôi')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: animal,
                  decoration: _dec('Loại vật nuôi'),
                  items: animals
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModal(() => animal = v),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _pickDate(true),
                  child: _dateField(
                      startDate == null
                          ? 'Ngày bắt đầu'
                          : _fmt.format(startDate!),
                      enabled: true),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: startDate == null ? null : () => _pickDate(false),
                  child: _dateField(
                    endDate == null ? 'Ngày kết thúc' : _fmt.format(endDate!),
                    enabled: startDate != null,
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: _dec('Trạng thái'),
                  items: statuses
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModal(() => status = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: totalCtl,
                  keyboardType: TextInputType.number,
                  decoration: _dec('Số lượng thả'),
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
            if (nameCtl.text.isEmpty ||
                codeCtl.text.isEmpty ||
                animal == null ||
                status == null ||
                startDate == null ||
                endDate == null ||
                totalCtl.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
              );
              return;
            }
            setState(() {
              _batches.add({
                'code': codeCtl.text,
                'type': animal!,
                'start': startDate!,
                'status': status!,
                'total': totalCtl.text,
              });
            });
            Navigator.pop(context);
          },
          child: const Text("Lưu", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  Widget _dateField(String text, {required bool enabled}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
          color: enabled ? null : Colors.grey.shade200,
        ),
        child: Text(text, style: const TextStyle(fontSize: 13)),
      );
}

/* =============================================================== */
/*                          TILE WIDGET                            */
/* =============================================================== */
class _BatchTile extends StatelessWidget {
  final Map<String, dynamic> b;
  final Color clr;
  final DateFormat fmt;
  final VoidCallback onTap;

  const _BatchTile({
    required this.b,
    required this.clr,
    required this.fmt,
    required this.onTap,
  });

  static const _leftIconSize = 60.0;
  static const _hPadding = 14.0;
  static const _gap = 12.0;
  static const _dotSize = 15.0;

  double get _dividerX => _hPadding + _leftIconSize + _gap / 2;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Container(
            padding: const EdgeInsets.all(_hPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Container(
                    width: _leftIconSize,
                    height: _leftIconSize,
                    decoration: BoxDecoration(
                      color: clr.withOpacity(.1),
                      borderRadius: BorderRadius.circular(8),
                      image: const DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/images/inventory.png'),
                      ),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: clr,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        b['status'],
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: _gap),
                  Container(
                      width: 1, height: double.infinity, color: Colors.black12),
                  const SizedBox(width: _gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['code'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Loại: ${b['type']}',
                            style: const TextStyle(fontSize: 13)),
                        Text('Ngày bắt đầu: ${fmt.format(b['start'])}',
                            style: const TextStyle(fontSize: 13)),
                        Text('Số lượng thả: ${b['total']}',
                            style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -_dotSize / 2,
            left: _dividerX,
            child: _dot(),
          ),
          Positioned(
            bottom: -_dotSize / 2,
            left: _dividerX,
            child: _dot(),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: _dotSize,
        height: _dotSize,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFF5FAFF), // màu nền AppBackground
        ),
      );
}
