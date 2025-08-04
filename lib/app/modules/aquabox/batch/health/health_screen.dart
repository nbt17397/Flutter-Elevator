import 'dart:io';

import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _formKey = GlobalKey<FormState>();

  /* ----- Controllers & State ----- */
  final _lengthCtl = TextEditingController();
  final _widthCtl = TextEditingController();
  int _healthRating = 0; // -2 … 2
  int _fecesRating = 0; // -2 … 2
  bool _auto = false; // cập nhật tự động?
  File? _image; // ảnh mẫu nước
  final _picker = ImagePicker();

  @override
  void dispose() {
    _lengthCtl.dispose();
    _widthCtl.dispose();
    super.dispose();
  }

  /* ----- Border style ----- */
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
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

  /* ---- Chọn ảnh ---- */
  Future<void> _pickImage() async {
    final XFile? xfile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) setState(() => _image = File(xfile.path));
  }
  
  /* ----- Submit ----- */
  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu dữ liệu sức khỏe!')),
      );
      // TODO: gửi (_lengthCtl.text, _widthCtl.text, _healthRating, _fecesRating) lên backend
    }
  }

  /* ----- Slider khung + viền đen ----- */
  Widget _ratingBox({
    required String title,
    required int rating,
    required ValueChanged<double> onChanged,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title: $rating',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTickMarkColor: Colors.black,
                inactiveTickMarkColor: Colors.black26,
                activeTrackColor: CustomColors.appbarColor,
                tickMarkShape:
                    const RoundSliderTickMarkShape(tickMarkRadius: 2),
              ),
              child: Slider(
                value: rating.toDouble(),
                min: -2,
                max: 2,
                divisions: 4,
                label: rating.toString(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      );

  /* ----- UI ----- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Cập nhật sức khỏe'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
        ),
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
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    Switch(
                      value: _auto,
                      onChanged: (v) => setState(() => _auto = v),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey.shade400,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
      
                /* --- Chiều dài --- */
                TextFormField(
                  controller: _lengthCtl,
                  decoration: _dec('Chiều dài (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nhập chiều dài' : null,
                ),
                const SizedBox(height: 16),
      
                /* --- Chiều rộng --- */
                TextFormField(
                  controller: _widthCtl,
                  decoration: _dec('Chiều rộng (cm)'),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nhập chiều rộng' : null,
                ),
                const SizedBox(height: 24),
                /* --- Ảnh mẫu nước --- */
                const Text('Hình ảnh',
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                      image: _image != null
                          ? DecorationImage(
                              image: FileImage(_image!), fit: BoxFit.cover)
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: _image == null
                        ? const Icon(Icons.add_a_photo,
                            size: 40, color: Colors.black54)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                /* --- Rating tình trạng sức khỏe --- */
                _ratingBox(
                  title: 'Tình trạng sức khỏe',
                  rating: _healthRating,
                  onChanged: (v) => setState(() => _healthRating = v.round()),
                ),
                const SizedBox(height: 24),
      
                /* --- Rating tình trạng phân --- */
                _ratingBox(
                  title: 'Tình trạng phân',
                  rating: _fecesRating,
                  onChanged: (v) => setState(() => _fecesRating = v.round()),
                ),
              ],
            ),
          ),
        ),
      
        /* --- NÚT CẬP NHẬT (thủ công) --- */
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _auto ? null : _submit, // disable khi tự động
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: CustomColors.appbarColor,
              disabledBackgroundColor: Colors.grey,
            ),
            child: const Text('Cập nhật thủ công',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
        ),
      ),
    );
  }
}
