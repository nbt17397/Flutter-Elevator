import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';


import '../../../../../config/shared/colors.dart';
import '../../../../components/app_background.dart';
import '../../../../data/json_annotation/system_db.dart';
import '../../../../services/reporitories/system_repo.dart';
import 'bloc/system_bloc.dart';
import 'pond_screen.dart';

/// ------------- MÀN HÌNH HỆ (ĐÃ TÍCH HỢP API VÀ BLOC) -------------
class SystemScreen extends StatefulWidget {
  const SystemScreen({super.key});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen> {
  /// ------ STATE BLOC ------
  late final SystemBloc _systemBloc;

  @override
  void initState() {
    super.initState();
    _systemBloc = SystemBloc(SystemRepo());
    _systemBloc.add(LoadSystems()); // Tải dữ liệu ban đầu
  }

  @override
  void dispose() {
    _systemBloc.close();
    super.dispose();
  }

  /// ------ STYLE DÙNG LẠI ------
  BoxDecoration get _box => BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /// ------ DIALOG THÊM / SỬA ------
  Future<void> _showSystemDialog({SystemDB? system}) async {
    final nameCtrl = TextEditingController(text: system?.name ?? '');
    final descCtrl = TextEditingController(text: system?.description ?? '');
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
            final newSystem = SystemDB(
              id: system?.id ?? 0, // id tạm thời cho tạo mới
              name: nameCtrl.text.trim(),
              description: descCtrl.text.trim(),
              createdAt: DateTime.now(),
              location: 1, // Giả định
            );
            if (system == null) {
              _systemBloc.add(AddSystem(newSystem));
            } else {
              _systemBloc.add(UpdateSystem(newSystem.id, newSystem));
            }
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /// ------ XÁC NHẬN XOÁ ------
  void _confirmDelete(SystemDB system) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ HỆ',
      desc: 'Bạn có chắc muốn xoá "${system.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            _systemBloc.add(DeleteSystem(system.id));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /// ------ HIỆU ỨNG LOADING SHIMMER ------
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
          child: BlocProvider(
            create: (context) => _systemBloc,
            child: BlocBuilder<SystemBloc, SystemState>(
              builder: (context, state) {
                if (state is SystemLoading) {
                  return _buildShimmerEffect();
                } else if (state is SystemLoaded) {
                  return ListView.separated(
                    itemCount: state.systems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final sys = state.systems[i];
                      return GestureDetector(
                        onTap: () {
                          // Chuyển sang màn hình PondScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PondScreen(systemId: sys.id),
                            ),
                          );
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
                                    Text(
                                      sys.name,
                                      style: const TextStyle(
                                          fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      sys.description ?? '', // Sử dụng ?? '' để tránh lỗi null
                                      style: const TextStyle(fontSize: 14),
                                    ),
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
                  );
                } else if (state is SystemError) {
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