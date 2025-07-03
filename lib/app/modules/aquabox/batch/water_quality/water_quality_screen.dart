import 'dart:io';

import 'package:elevator/config/shared/colors.dart'; // nếu có
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WaterQualityScreen extends StatefulWidget {
  const WaterQualityScreen({super.key});

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  final _formKey = GlobalKey<FormState>();

  /* ---- Controllers & State ---- */
  final _outflowCtl = TextEditingController(); // nước xả
  final _inflowCtl = TextEditingController(); // nước vào
  int _rating = 0; // -2 … 2
  File? _image; // ảnh mẫu nước
  final _picker = ImagePicker();
  bool _auto = false; // cập nhật tự động?

  @override
  void dispose() {
    _outflowCtl.dispose();
    _inflowCtl.dispose();
    super.dispose();
  }

  /* ---- Border style đen ---- */
  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1),
        ),
      );

  /* ---- Chọn ảnh từ gallery/camera ---- */
  Future<void> _pickImage() async {
    final XFile? xfile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile != null) setState(() => _image = File(xfile.path));
  }

  /* ---- Submit ---- */
  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu đánh giá nước!')),
      );
      // TODO: gửi (_outflowCtl.text, _inflowCtl.text, _rating, _image) tới backend
    }
  }

  /* ---- UI ---- */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kiểm tra chất lượng nước'),
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

                    // màu khi ON
                    activeColor: Colors.green,
                    activeTrackColor: Colors.green.shade200,

                    // màu khi OFF
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              /* --- Khối lượng nước xả --- */
              TextFormField(
                controller: _outflowCtl,
                decoration: _dec('Khối lượng nước xả (m³)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập khối lượng xả' : null,
              ),
              const SizedBox(height: 16),

              /* --- Khối lượng nước vào --- */
              TextFormField(
                controller: _inflowCtl,
                decoration: _dec('Khối lượng nước vào (m³)'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập khối lượng vào' : null,
              ),
              const SizedBox(height: 16),

              /* --- Ảnh mẫu nước --- */
              Text('Ảnh mẫu nước',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
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

              /* --- ĐÁNH GIÁ CHẤT LƯỢNG NƯỚC --- */
              Text('Đánh giá chất lượng nước: $_rating',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),

// Khung viền + nhãn các nấc
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // viền đen
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
                    value: _rating.toDouble(),
                    min: -2,
                    max: 2,
                    divisions: 4, // tạo 5 nấc
                    label: _rating.toString(),
                    onChanged: (v) => setState(() => _rating = v.round()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      /* --- NÚT LƯU (thủ công) --- */
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _auto ? null : _submit,
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
    );
  }
}
