import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'area_screen.dart';


// ----------------- MODEL -----------------
class PondModel {
  String name;
  String desc;
  PondModel(this.name, this.desc);
}



class PondScreen extends StatefulWidget {
  final SystemModel system;
  const PondScreen({super.key, required this.system});

  @override
  State<PondScreen> createState() => _PondScreenState();
}

class _PondScreenState extends State<PondScreen> {
  List<PondModel> get _ponds => widget.system.ponds;

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /* ---------- THÊM / SỬA ---------- */
  Future<void> _showPondDialog({PondModel? pond}) async {
    final nameCtrl = TextEditingController(text: pond?.name ?? '');
    final descCtrl = TextEditingController(text: pond?.desc ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: pond == null ? 'THÊM BỂ' : 'SỬA BỂ',
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
                labelText: 'Tên bể',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descCtrl,
              minLines: 2,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(),
                isDense: true,
              ),
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
              if (pond == null) {
                _ponds.add(
                  PondModel(nameCtrl.text.trim(), descCtrl.text.trim()),
                );
              } else {
                pond
                  ..name = nameCtrl.text.trim()
                  ..desc = descCtrl.text.trim();
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
  void _confirmDelete(PondModel pond) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ BỂ',
      desc: 'Bạn có chắc muốn xoá "${pond.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            setState(() => _ponds.remove(pond));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- UI ---------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Bể của ${widget.system.name}'),backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showPondDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm bể',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: _ponds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final pond = _ponds[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: _box,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(pond.name,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(pond.desc, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showPondDialog(pond: pond);
                        } else if (value == 'delete') {
                          _confirmDelete(pond);
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
