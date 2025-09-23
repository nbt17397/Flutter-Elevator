import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/shared/colors.dart';
import '../../../../components/app_background.dart';
import '../../../../data/json_annotation/unit_db.dart';
import '../../../../services/reporitories/unit_repo.dart';
import 'bloc/unit_bloc.dart';

/// ----------------- MÀN HÌNH ĐƠN VỊ -----------------
class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  late final UnitBloc _unitBloc;

  @override
  void initState() {
    super.initState();
    _unitBloc = UnitBloc(UnitRepo()); // Khởi tạo Bloc
    _unitBloc.add(LoadUnits()); // Gửi sự kiện ban đầu để tải dữ liệu
  }

  @override
  void dispose() {
    _unitBloc.close(); // Đóng Bloc khi không còn sử dụng
    super.dispose();
  }

  /* --------- BORDER STYLE --------- */
  BoxDecoration get _box => BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white);

  /* --------- HỘP THOẠI THÊM / SỬA --------- */
  Future<void> _showUnitDialog({UnitDB? unit}) async {
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
            final newUnit = UnitDB(
              id: unit?.id ?? 0, // id tạm thời, sẽ được API trả về
              type: 'mass', // Giả định
              name: ctrl.text.trim(),
              createdAt: DateTime.now(),
              location: 1, // Giả định
            );
            if (unit == null) {
              _unitBloc.add(AddUnit(newUnit));
            } else {
              _unitBloc.add(UpdateUnit(unit.id, newUnit));
            }
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* --------- XÁC NHẬN XOÁ --------- */
  void _confirmDelete(UnitDB unit) {
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
            _unitBloc.add(DeleteUnit(unit.id));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* --------- HIỆU ỨNG LOADING SHIMMER --------- */
  Widget _buildShimmerEffect() {
    return ListView.separated(
      itemCount: 5, // Số lượng hiệu ứng giả
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
          child: BlocProvider(
            create: (context) => _unitBloc,
            child: BlocBuilder<UnitBloc, UnitState>(
              builder: (context, state) {
                if (state is UnitLoading) {
                  return _buildShimmerEffect();
                } else if (state is UnitLoaded) {
                  return ListView.separated(
                    itemCount: state.units.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final u = state.units[i];
                      return Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _box,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(u.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
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
                } else if (state is UnitError) {
                  return Center(
                    child: Text(state.message,
                        style: const TextStyle(color: Colors.red, fontSize: 16)),
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