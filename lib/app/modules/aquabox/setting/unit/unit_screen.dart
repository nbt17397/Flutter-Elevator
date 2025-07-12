import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// ----------------- MODEL -----------------
class Unit {
  String name;
  Unit(this.name);
}

/// ----------------- MÀN HÌNH ĐƠN VỊ -----------------
class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  /* --------- STATE --------- */
  final List<Unit> _units = [
    Unit('kg'),
    Unit('g'),
    Unit('tấn'),
    Unit('bộ'),
  ];

  /* --------- BORDER STYLE --------- */
  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),color: Colors.white
      );

  /* --------- HỘP THOẠI THÊM / SỬA --------- */
  Future<void> _showUnitDialog({Unit? unit}) async {
    final ctrl = TextEditingController(text: unit?.name ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: unit == null ? 'THÊM ĐƠN VỊ' : 'SỬA ĐƠN VỊ',
      style: AlertStyle(
        titleStyle: TextStyle(
          color: Colors.blue.shade700,
          fontWeight: FontWeight.bold,
        ),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: ctrl,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Không được để trống' : null,
          decoration: InputDecoration(
            labelText: 'Tên đơn vị',
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
          ),
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
              if (unit == null) {
                _units.add(Unit(ctrl.text.trim()));
              } else {
                unit.name = ctrl.text.trim();
              }
            });
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* --------- XÁC NHẬN XOÁ --------- */
  void _confirmDelete(Unit unit) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ ĐƠN VỊ',
      desc: 'Bạn có chắc muốn xoá "${unit.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            setState(() => _units.remove(unit));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* --------- UI --------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Đơn vị'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              onPressed: () => _showUnitDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm đơn vị',
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: _units.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) {
              final u = _units[i];
              return Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: _box,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(u.name, style: const TextStyle(fontSize: 15)),
                    ),
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showUnitDialog(unit: u);
                        } else if (value == 'delete') {
                          _confirmDelete(u);
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
