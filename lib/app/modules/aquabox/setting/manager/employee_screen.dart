import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// --------------- MODEL ---------------
enum EmployeeLevel { manager, staff }

extension LevelName on EmployeeLevel {
  String get vi {
    switch (this) {
      case EmployeeLevel.manager:
        return 'Quản lý';
      case EmployeeLevel.staff:
        return 'Nhân viên';
    }
  }
}

class EmployeeModel {
  String name;
  EmployeeLevel level;
  EmployeeModel(this.name, this.level);
}

/// --------- MÀN HÌNH NHÂN VIÊN ---------
class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  State<EmployeeScreen> createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  /* ---------- STATE DUMMY ---------- */
  final List<EmployeeModel> _employees = [
    EmployeeModel('Nguyễn Văn A', EmployeeLevel.manager),
    EmployeeModel('Trần Thị B', EmployeeLevel.staff),
    EmployeeModel('Phạm Văn C', EmployeeLevel.staff),
  ];

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /* ---------- THÊM / SỬA ---------- */
  Future<void> _showEmployeeDialog({EmployeeModel? emp}) async {
    final nameCtrl = TextEditingController(text: emp?.name ?? '');
    EmployeeLevel level = emp?.level ?? EmployeeLevel.staff;
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: emp == null ? 'THÊM NHÂN VIÊN' : 'SỬA NHÂN VIÊN',
      style: AlertStyle(
        titleStyle:
            TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EmployeeLevel>(
              value: level,
              decoration: const InputDecoration(
                labelText: 'Cấp bậc',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: EmployeeLevel.values
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e.vi),
                      ))
                  .toList(),
              onChanged: (val) => level = val ?? EmployeeLevel.staff,
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.blue.shade700,
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;
            setState(() {
              if (emp == null) {
                _employees.add(EmployeeModel(nameCtrl.text.trim(), level));
              } else {
                emp
                  ..name = nameCtrl.text.trim()
                  ..level = level;
              }
            });
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- XOÁ ---------- */
  void _confirmDelete(EmployeeModel emp) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ NHÂN VIÊN',
      desc: 'Bạn có chắc muốn xoá "${emp.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            setState(() => _employees.remove(emp));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- UI CHÍNH ---------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Nhân viên'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showEmployeeDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm nhân viên',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: _employees.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final emp = _employees[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: _box,
                child: Row(
                  children: [
                    /* ------ THÔNG TIN ------ */
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(emp.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(emp.level.vi, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
      
                    /* ------ MENU ------ */
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEmployeeDialog(emp: emp);
                        } else if (value == 'delete') {
                          _confirmDelete(emp);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Sửa')),
                        PopupMenuItem(value: 'delete', child: Text('Xoá')),
                      ],
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
