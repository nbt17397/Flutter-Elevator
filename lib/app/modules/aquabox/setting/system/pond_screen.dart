import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/shared/colors.dart';
import '../../../../components/app_background.dart';
import '../../../../data/json_annotation/pond_db.dart';
import '../../../../services/reporitories/pond_repo.dart';
import 'bloc/pond_bloc.dart';

class PondScreen extends StatefulWidget {
  // Thay đổi từ SystemModel sang systemId
  final int systemId;
  const PondScreen({super.key, required this.systemId});

  @override
  State<PondScreen> createState() => _PondScreenState();
}

class _PondScreenState extends State<PondScreen> {
  late final PondBloc _pondBloc;

  @override
  void initState() {
    super.initState();
    _pondBloc = PondBloc(PondRepo());
    // Gửi sự kiện để tải dữ liệu bể ban đầu
    _pondBloc.add(LoadPonds(widget.systemId));
  }

  @override
  void dispose() {
    _pondBloc.close();
    super.dispose();
  }

  // Loại bỏ các trường cục bộ như `PondModel` và `_ponds`

  BoxDecoration get _box => BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /* ---------- DIALOG THÊM / SỬA ---------- */
  Future<void> _showPondDialog({PondDB? pond}) async {
    final nameCtrl = TextEditingController(text: pond?.name ?? '');
    final volumeCtrl =
        TextEditingController(text: pond?.volume.toString() ?? '');
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
              controller: volumeCtrl,
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              decoration: const InputDecoration(
                labelText: 'Thể tích (m³)',
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

            final newPond = PondDB(
              id: pond?.id ?? 0,
              name: nameCtrl.text.trim(),
              volume: double.tryParse(volumeCtrl.text.trim()) ?? 0.0,
              createdAt: DateTime.now(),
              system: widget.systemId,
            );

            if (pond == null) {
              _pondBloc.add(AddPond(widget.systemId, newPond));
            } else {
              _pondBloc.add(UpdatePond(widget.systemId, newPond.id, newPond));
            }
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- XOÁ ---------- */
  void _confirmDelete(PondDB pond) {
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
            _pondBloc.add(DeletePond(widget.systemId, pond.id));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- HIỆU ỨNG LOADING SHIMMER ---------- */
  Widget _buildShimmerEffect() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /* ---------- UI CHÍNH ---------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý Bể'),
          backgroundColor: CustomColors.appbarColor,
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
          child: BlocProvider.value(
            value: _pondBloc,
            child: BlocBuilder<PondBloc, PondState>(
              builder: (context, state) {
                if (state is PondLoading) {
                  return _buildShimmerEffect();
                } else if (state is PondLoaded) {
                  return ListView.separated(
                    itemCount: state.ponds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final p = state.ponds[i];
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
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Thể tích: ${p.volume} m³',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showPondDialog(pond: p);
                                } else if (value == 'delete') {
                                  _confirmDelete(p);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Sửa')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Xoá')),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is PondError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ),
      ),
    );
  }
}
