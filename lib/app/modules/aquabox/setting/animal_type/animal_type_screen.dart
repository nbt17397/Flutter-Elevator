import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/shared/colors.dart';
import '../../../../components/app_background.dart';
import '../../../../data/json_annotation/animal_type_db.dart';
import '../../../../services/reporitories/animal_type_repo.dart';
import 'bloc/animal_type_bloc.dart';

class AnimalTypeScreen extends StatefulWidget {
  const AnimalTypeScreen({super.key});

  @override
  State<AnimalTypeScreen> createState() => _AnimalTypeScreenState();
}

class _AnimalTypeScreenState extends State<AnimalTypeScreen> {
  late final AnimalTypeBloc _animalTypeBloc;

  @override
  void initState() {
    super.initState();
    _animalTypeBloc = AnimalTypeBloc(AnimalTypeRepo());
    _animalTypeBloc.add(LoadAnimalTypes());
  }

  @override
  void dispose() {
    _animalTypeBloc.close();
    super.dispose();
  }

  BoxDecoration get _box => BoxDecoration(
      borderRadius: BorderRadius.circular(8), color: Colors.white);

  Future<void> _showAnimalTypeDialog({AnimalTypeDB? animalType}) async {
    final nameCtrl = TextEditingController(text: animalType?.name ?? '');
    final descCtrl = TextEditingController(text: animalType?.description ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: animalType == null ? 'THÊM LOẠI ĐỘNG VẬT' : 'SỬA LOẠI ĐỘNG VẬT',
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
        child: Column(
          children: [
            TextFormField(
              controller: nameCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              decoration: InputDecoration(
                labelText: 'Tên loại',
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: descCtrl,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                isDense: true,
                border: const OutlineInputBorder(),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            final newAnimalType = AnimalTypeDB(
              id: animalType?.id ?? 0,
              name: nameCtrl.text.trim(),
              description: descCtrl.text.trim(),
              createdAt: DateTime.now(),
              location: 1, // Giả định
            );
            if (animalType == null) {
              _animalTypeBloc.add(AddAnimalType(newAnimalType));
            } else {
              _animalTypeBloc
                  .add(UpdateAnimalType(animalType.id, newAnimalType));
            }
            Navigator.pop(context);
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  void _confirmDelete(AnimalTypeDB animalType) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ LOẠI ĐỘNG VẬT',
      desc: 'Bạn có chắc muốn xoá "${animalType.name}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            _animalTypeBloc.add(DeleteAnimalType(animalType.id));
            Navigator.pop(context);
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

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

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Loại động vật'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            IconButton(
              onPressed: () => _showAnimalTypeDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm loại động vật',
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocProvider(
            create: (context) => _animalTypeBloc,
            child: BlocBuilder<AnimalTypeBloc, AnimalTypeState>(
              builder: (context, state) {
                if (state is AnimalTypeLoading) {
                  return _buildShimmerEffect();
                } else if (state is AnimalTypeLoaded) {
                  return ListView.separated(
                    itemCount: state.animalTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final a = state.animalTypes[i];
                      return Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: _box,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(a.name,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                            ),
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showAnimalTypeDialog(animalType: a);
                                } else if (value == 'delete') {
                                  _confirmDelete(a);
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
                } else if (state is AnimalTypeError) {
                  return Center(
                    child: Text(state.message,
                        style:
                            const TextStyle(color: Colors.red, fontSize: 16)),
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
