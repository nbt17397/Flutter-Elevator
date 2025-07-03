import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class FeedIngredient {
  String name;
  int percent;
  FeedIngredient(this.name, this.percent);
}

class FeedFormula {
  String title;
  final List<FeedIngredient> ingredients;
  FeedFormula(this.title, this.ingredients);
}

class FeedFormulaScreen extends StatefulWidget {
  const FeedFormulaScreen({super.key});
  @override
  State<FeedFormulaScreen> createState() => _FeedFormulaScreenState();
}

class _FeedFormulaScreenState extends State<FeedFormulaScreen> {
  final List<FeedFormula> _formulas = [
    FeedFormula('Grower 32%', [
      FeedIngredient('Cám nổi 3mm', 60),
      FeedIngredient('Cám chìm 2mm', 30),
      FeedIngredient('Bột cá 45%', 10),
    ]),
    FeedFormula('Công thức tôm', [
      FeedIngredient('Cám chìm 1mm', 70),
      FeedIngredient('Khoáng bổ sung', 20),
      FeedIngredient('Vitamin', 10),
    ]),
  ];

  BoxDecoration get _box => BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      );

  void _showFormulaDialog({FeedFormula? formula}) {
    final titleCtl = TextEditingController(text: formula?.title ?? '');
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: formula == null ? 'THÊM CÔNG THỨC' : 'SỬA CÔNG THỨC',
      style: _style,
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: titleCtl,
          decoration: _dec('Tên công thức'),
          validator: (v) => v == null || v.isEmpty ? 'Không để trống' : null,
        ),
      ),
      buttons: [
        _btn('Huỷ', Colors.grey, () => Navigator.pop(context)),
        _btn('Lưu', Colors.blue, () {
          if (!(formKey.currentState?.validate() ?? false)) return;
          setState(() {
            if (formula == null) {
              _formulas.add(FeedFormula(titleCtl.text.trim(), []));
            } else {
              formula.title = titleCtl.text.trim();
            }
          });
          Navigator.pop(context);
        }),
      ],
    ).show();
  }

  void _showIngredientDialog(FeedFormula f) {
    final nameCtl = TextEditingController();
    final percentCtl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    Alert(
      context: context,
      title: 'THÊM THỨC ĂN',
      style: _style,
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: nameCtl,
              decoration: _dec('Tên thức ăn'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Không để trống' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: percentCtl,
              decoration: _dec('% khối lượng'),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  int.tryParse(v ?? '') == null ? 'Nhập số' : null,
            ),
          ],
        ),
      ),
      buttons: [
        _btn('Huỷ', Colors.grey, () => Navigator.pop(context)),
        _btn('Lưu', Colors.blue, () {
          if (!(formKey.currentState?.validate() ?? false)) return;
          setState(() {
            f.ingredients.add(FeedIngredient(
              nameCtl.text.trim(),
              int.parse(percentCtl.text),
            ));
          });
          Navigator.pop(context);
        }),
      ],
    ).show();
  }

  void _confirmDeleteFormula(FeedFormula f) {
    Alert(
      context: context,
      title: 'XOÁ CÔNG THỨC',
      desc: 'Xác nhận xoá "${f.title}"?',
      style: _style,
      buttons: [
        _btn('Huỷ', Colors.grey, () => Navigator.pop(context)),
        _btn('Xoá', Colors.red, () {
          setState(() => _formulas.remove(f));
          Navigator.pop(context);
        }),
      ],
    ).show();
  }

  void _confirmDeleteIng(FeedFormula f, FeedIngredient i) {
    Alert(
      context: context,
      title: 'XOÁ THÀNH PHẦN',
      desc: 'Xoá "${i.name}" khỏi "${f.title}"?',
      style: _style,
      buttons: [
        _btn('Huỷ', Colors.grey, () => Navigator.pop(context)),
        _btn('Xoá', Colors.red, () {
          setState(() => f.ingredients.remove(i));
          Navigator.pop(context);
        }),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu thức ăn'),
        backgroundColor: CustomColors.appbarColor,centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showFormulaDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: _formulas.length,
          itemBuilder: (_, i) {
            final f = _formulas[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent, // khi nhấn
                  highlightColor: Colors.transparent, // ripple highlight
                  hoverColor: Colors.transparent, // khi rê chuột (Web/Desktop)
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.only(left: 12, bottom: 8),
                  title: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    decoration: _box,
                    child: Row(
                      children: [
                        Expanded(child: Text(f.title)),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') _showFormulaDialog(formula: f);
                            if (v == 'del') _confirmDeleteFormula(f);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Sửa')),
                            PopupMenuItem(value: 'del', child: Text('Xoá')),
                          ],
                        )
                      ],
                    ),
                  ),
                  children: [
                    ...f.ingredients.map((ing) => Container(
                          margin: const EdgeInsets.only(bottom: 6, right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: _box,
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text('${ing.name} (${ing.percent}%)')),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () => _confirmDeleteIng(f, ing),
                              ),
                            ],
                          ),
                        )),
                    TextButton.icon(
                      onPressed: () => _showIngredientDialog(f),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Thêm thức ăn'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _dec(String lbl) => InputDecoration(
        labelText: lbl,
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );

  AlertStyle get _style => AlertStyle(
        titleStyle: const TextStyle(fontWeight: FontWeight.bold),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      );

  DialogButton _btn(String txt, Color c, VoidCallback onTap) => DialogButton(
        onPressed: onTap,
        color: c,
        child: Text(txt, style: const TextStyle(color: Colors.white)),
      );
}
