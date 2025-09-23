import 'dart:io';

import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WaterQualityScreen extends StatefulWidget {
  final bool isAquatic;
  const WaterQualityScreen({super.key, required this.isAquatic});

  @override
  State<WaterQualityScreen> createState() => _WaterQualityScreenState();
}

class _WaterQualityScreenState extends State<WaterQualityScreen> {
  final _formKey = GlobalKey<FormState>();

  /* ---- Controllers & State ---- */
  // Nước
  final _outflowCtl = TextEditingController(); // nước xả
  final _inflowCtl = TextEditingController(); // nước vào
  double _ph = 7.0; // 4 … 10
  double _oxy = 5.0; // 0 … 10 mg/L

  // Không khí
  final _co2Ctl = TextEditingController(); // nồng độ CO2
  final _airflowCtl = TextEditingController(); // lưu lượng gió
  int _airQualityRating = 0; // -2 ... 2

  // Chung
  int _rating = 0; // -2 … 2
  File? _image; // ảnh mẫu nước
  final _picker = ImagePicker();
  bool _auto = false; // cập nhật tự động?

  @override
  void dispose() {
    _outflowCtl.dispose();
    _inflowCtl.dispose();
    _co2Ctl.dispose();
    _airflowCtl.dispose();
    super.dispose();
  }

  /* ---- Border style đen ---- */
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

  /* ---- Submit ---- */
  void _submit() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu dữ liệu đánh giá!')),
      );
      // TODO: Gửi dữ liệu lên backend
      // Nếu là thủy sản: (_outflowCtl.text, _inflowCtl.text, _rating, _ph, _oxy, _image)
      // Nếu là động vật: (_co2Ctl.text, _airflowCtl.text, _airQualityRating)
    }
  }

  /* --- Helper: khung viền cho Slider --- */
  Widget _buildSliderContainer({required Widget child}) => Container(
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
            tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
          ),
          child: child,
        ),
      );

  /* ---- UI ---- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(widget.isAquatic ? 'Kiểm tra chất lượng nước' : 'Kiểm tra chất lượng không khí'),
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
                
                if (widget.isAquatic) ...[
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
                  const Text('Ảnh mẫu nước',
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

                  /* --- pH --- */
                  Text('pH: ${_ph.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSliderContainer(
                    child: Slider(
                      value: _ph,
                      min: 4,
                      max: 10,
                      divisions: 60, // bước 0.1
                      label: _ph.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _ph = v),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /* --- Oxy hoà tan --- */
                  Text('Oxy hoà tan (mg/L): ${_oxy.toStringAsFixed(1)}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSliderContainer(
                    child: Slider(
                      value: _oxy,
                      min: 0,
                      max: 10,
                      divisions: 100, // bước 0.1
                      label: _oxy.toStringAsFixed(1),
                      onChanged: (v) => setState(() => _oxy = v),
                    ),
                  ),
                  const SizedBox(height: 24),

                  /* --- ĐÁNH GIÁ CHẤT LƯỢNG NƯỚC (slider -2..2) --- */
                  Text('Đánh giá chất lượng nước: $_rating',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSliderContainer(
                    child: Slider(
                      value: _rating.toDouble(),
                      min: -2,
                      max: 2,
                      divisions: 4,
                      label: _rating.toString(),
                      onChanged: (v) => setState(() => _rating = v.round()),
                    ),
                  ),
                ]
                else ...[
                  /* --- Nồng độ CO2 --- */
                  TextFormField(
                    controller: _co2Ctl,
                    decoration: _dec('Nồng độ CO2 (ppm)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nhập nồng độ CO2' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  /* --- Lưu lượng gió --- */
                  TextFormField(
                    controller: _airflowCtl,
                    decoration: _dec('Lưu lượng gió (m³/h)'),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Nhập lưu lượng gió' : null,
                  ),
                  const SizedBox(height: 24),
                  
                  /* --- ĐÁNH GIÁ CHẤT LƯỢNG KHÔNG KHÍ (slider -2..2) --- */
                  Text('Đánh giá chất lượng không khí: $_airQualityRating',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildSliderContainer(
                    child: Slider(
                      value: _airQualityRating.toDouble(),
                      min: -2,
                      max: 2,
                      divisions: 4,
                      label: _airQualityRating.toString(),
                      onChanged: (v) => setState(() => _airQualityRating = v.round()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
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
      ),
    );
  }
}