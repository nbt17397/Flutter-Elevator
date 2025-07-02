import 'dart:math';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'batch_detail_screen.dart';

class BatchListScreen extends StatefulWidget {
  const BatchListScreen({super.key});

  @override
  State<BatchListScreen> createState() => _BatchListScreenState();
}

class _BatchListScreenState extends State<BatchListScreen> {
  // -------------- dữ liệu giả --------------
  final List<Map<String, dynamic>> _batches = List.generate(20, (i) {
    final rnd = Random();
    final now = DateTime.now();
    return {
      'code': 'BN${100 + i}',
      'type': ['Heo', 'Gà', 'Tôm', 'Cá'][i % 4],
      'start': now.subtract(Duration(days: rnd.nextInt(180))),
      'status': ['Đang nuôi', 'Hoàn tất', 'Trễ tiến độ', 'Tạm dừng'][i % 4],
      'total': '1000',
    };
  });

  final DateFormat _fmt = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vụ nuôi'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Thêm vụ nuôi',
            onPressed: _showCreateDialog,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                headingRowColor:
                    MaterialStateColor.resolveWith((_) => Colors.black54),
                dataRowColor: MaterialStateProperty.resolveWith(
                    (_) => Colors.grey.shade300),
                columnSpacing: 24, // khoảng hở giữa cột
                columns: _buildColumns(),
                showCheckboxColumn: false,
                rows: _batches.map(_buildRow).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------- tạo cột ----------
  List<DataColumn> _buildColumns() {
    List<String> titles = [
      'Mã vụ',
      'Loại vật nuôi',
      'Ngày bắt đầu',
      'Trạng thái',
      'Số lượng thả'
    ];
    return titles
        .map(
          (t) => DataColumn(
            label: Center(
              child: Text(t, style: const TextStyle(color: Colors.white)),
            ),
          ),
        )
        .toList();
  }

  // ---------- tạo từng dòng ----------
  DataRow _buildRow(Map<String, dynamic> b) {
    DataCell _txt(String v) => DataCell(
          Center(
            child: Text(v,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black)),
          ),
        );

    return DataRow(
        selected: false,
        onSelectChanged: (_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BatchDetailScreen(),
            ),
          );
        },
        cells: [
          _txt(b['code']),
          _txt(b['type']),
          _txt(_fmt.format(b['start'])),
          DataCell(Center(child: _statusChip(b['status']))),
          _txt(b['total']),
        ]);
  }

  // ---------- chip trạng thái ----------
  Widget _statusChip(String status) {
    Color clr;
    switch (status) {
      case 'Đang nuôi':
        clr = Colors.greenAccent;
        break;
      case 'Hoàn tất':
        clr = Colors.blueAccent;
        break;
      case 'Trễ tiến độ':
        clr = Colors.redAccent;
        break;
      default:
        clr = Colors.orangeAccent; // Tạm dừng
    }
    return Chip(
      label: Text(status, style: const TextStyle(color: Colors.black)),
      backgroundColor: clr.withOpacity(.8),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showCreateDialog() {
    // ───── controllers & local state ─────
    final nameCtl = TextEditingController();
    final codeCtl = TextEditingController();
    final totalCtl = TextEditingController();

    String? animal;
    String? status;
    DateTime? startDate;
    DateTime? endDate;

    const animals = ['Heo', 'Gà', 'Tôm', 'Cá'];
    const statuses = ['Đang nuôi', 'Hoàn tất', 'Trễ tiến độ', 'Tạm dừng'];

    /// decoration chung (viền + font nhỏ)
    InputDecoration _dec(String lbl) => InputDecoration(
          labelText: lbl,
          labelStyle: const TextStyle(fontSize: 13),
          isDense: true,
          border: const OutlineInputBorder(),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
          ),
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
            if (endDate != null && endDate!.isBefore(startDate!))
              endDate = null;
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
        titleStyle: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: StatefulBuilder(
        builder: (ctx, setModal) => SingleChildScrollView(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .75,
            child: Column(
              children: [
                Divider(),
                TextField(controller: nameCtl, decoration: _dec('Tên vụ nuôi')),
                const SizedBox(height: 10),
                TextField(controller: codeCtl, decoration: _dec('Mã vụ nuôi')),
                const SizedBox(height: 10),

                // ---- Loại vật nuôi ----
                DropdownButtonFormField<String>(
                  value: animal,
                  decoration: _dec('Loại vật nuôi'),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: animals
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModal(() => animal = v),
                ),
                const SizedBox(height: 10),

                // ---- Ngày bắt đầu ----
                GestureDetector(
                  onTap: () => _pickDate(true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      startDate == null
                          ? 'Ngày bắt đầu'
                          : _fmt.format(startDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ---- Ngày kết thúc ----
                GestureDetector(
                  onTap: startDate == null ? null : () => _pickDate(false),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                      color: startDate == null ? Colors.grey.shade200 : null,
                    ),
                    child: Text(
                      endDate == null ? 'Ngày kết thúc' : _fmt.format(endDate!),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // ---- Trạng thái ----
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: _dec('Trạng thái'),
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: statuses
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setModal(() => status = v),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: totalCtl,
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
                'manager': totalCtl.text,
              });
            });
            Navigator.pop(context);
          },
          child: const Text("Lưu", style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }
}
