import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/modules/aquabox/setting/area/pond_screen.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

/// ---------------- MODEL ----------------
class SystemModel {
  String name;
  String desc;
  final List<PondModel> ponds;       // <── NEW
  SystemModel(this.name, this.desc, [List<PondModel>? initial])
      : ponds = initial ?? [];
}
/// ------------- MÀN HÌNH HỆ -------------
class AreaScreen extends StatefulWidget {
  const AreaScreen({super.key});

  @override
  State<AreaScreen> createState() => _AreaScreenState();
}

class _AreaScreenState extends State<AreaScreen> {
  /// ------ STATE ------
  final List<SystemModel> _systems = [
    SystemModel('Hệ 1', 'Mô tả hệ 1'),
    SystemModel('Hệ 2', 'Mô tả hệ 2'),
    SystemModel('Hệ 3', 'ABC…'),
  ];

  /// ------ STYLE DÙNG LẠI ------
  BoxDecoration get _box => BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /// ------ DIALOG THÊM / SỬA ------
  Future<void> _showSystemDialog({SystemModel? system}) async {
    final nameCtrl = TextEditingController(text: system?.name ?? '');
    final descCtrl = TextEditingController(text: system?.desc ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: system == null ? 'THÊM HỆ' : 'SỬA HỆ',
      style: AlertStyle(
        titleStyle: TextStyle(
            color: Colors.blue.shade700, fontWeight: FontWeight.bold),
        alertPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
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
                labelText: 'Tên hệ',
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
              if (system == null) {
                _systems.add(
                  SystemModel(nameCtrl.text.trim(), descCtrl.text.trim()),
                );
              } else {
                system
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

  /// ------ XÁC NHẬN XOÁ ------
  void _confirmDelete(SystemModel sys) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ HỆ',
      desc: 'Bạn có chắc muốn xoá "${sys.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            setState(() => _systems.remove(sys));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /// ------ UI CHÍNH ------
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Khu vực'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showSystemDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm hệ',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: ListView.separated(
            itemCount: _systems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final sys = _systems[i];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
            context, CupertinoPageRoute(builder: (_) => PondScreen(system:sys )));
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: _box,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Nội dung
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sys.name,
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(sys.desc, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      
                      /// Menu thao tác
                      PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showSystemDialog(system: sys);
                          } else if (value == 'delete') {
                            _confirmDelete(sys);
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
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
