import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* ---- Model ---- */
class Pond {
  final String code;
  final String name;
  Pond(this.code, this.name);
}

/* ---- Screen ---- */
class DensityScreen extends StatefulWidget {
  final bool isAquatic;
  const DensityScreen({super.key, required this.isAquatic});

  @override
  State<DensityScreen> createState() => _DensityScreenState();
}

class _DensityScreenState extends State<DensityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fmt = DateFormat('dd/MM/yyyy');

  /* ----- State ----- */
  bool _auto = false;
  late final List<Pond> _ponds; // 4 bể P1–P4
  Pond? _selectedPond;
  final _qtyCtl = TextEditingController();
  final _densityCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ponds = List.generate(
        4,
        (i) => Pond('P${i + 1}',
            widget.isAquatic ? 'Bể nuôi ${i + 1}' : 'Chuồng nuôi ${i + 1}'));
  }

  @override
  void dispose() {
    _qtyCtl.dispose();
    _densityCtl.dispose();
    super.dispose();
  }

  /* ---- Border style (đen) ---- */
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          // default
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26, width: 1),
        ),
      );

  /* ---- Submit ---- */
  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Gửi dữ liệu tới backend / provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thành công!')),
      );
    }
  }

  /* ---- UI ---- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cập nhật mật độ nuôi'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),

        /* --- FORM BODY --- */
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* --- AUTO SWITCH --- */
                Row(
                  children: [
                    const Expanded(
                        child: Text('Cập nhật tự động',
                            style: TextStyle(fontWeight: FontWeight.w600))),
                    Switch(
                      value: _auto,
                      onChanged: (v) => setState(() => _auto = v),

                      // MÀU KHI BẬT
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,

                      // MÀU KHI TẮT
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                    )
                  ],
                ),
                const SizedBox(height: 16),

                /* --- POND DROPDOWN --- */
                DropdownButtonFormField<Pond>(
                  decoration: _dec(
                      widget.isAquatic ? 'Chọn bể nuôi' : 'Chọn chuồng nuôi'),
                  items: _ponds
                      .map((p) => DropdownMenuItem(
                            value: p,
                            child: Text('${p.code} • ${p.name}'),
                          ))
                      .toList(),
                  validator: (v) => v == null ? 'Vui lòng chọn bể nuôi' : null,
                  onChanged: (p) => setState(() => _selectedPond = p),
                ),
                const SizedBox(height: 16),

                /* --- QUANTITY --- */
                TextFormField(
                  controller: _qtyCtl,
                  decoration: _dec('Số lượng con'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nhập số lượng' : null,
                ),
                const SizedBox(height: 16),

                /* --- DENSITY --- */
                TextFormField(
                  controller: _densityCtl,
                  decoration: _dec('Thể tích (m³)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nhập thể tích' : null,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),

        /* --- BOTTOM BUTTON (thủ công) --- */
        bottomNavigationBar: Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _auto ? null : _submit,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: CustomColors.appbarColor,
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                'Cập nhật thủ công',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            )),
      ),
    );
  }
}
