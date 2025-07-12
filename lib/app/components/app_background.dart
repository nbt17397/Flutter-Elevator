// lib/widgets/app_background.dart
import 'package:flutter/material.dart';

/// Widget bọc (wrapper) dùng chung cho toàn app.
/// - [child]     : nội dung chính của màn hình.
/// - [showTop]   : có vẽ hình trang trí bên trên không.
/// - [showBottom]: có vẽ thêm hình trang trí bên dưới không.
/// - [bottomImg] : đường dẫn asset hình trang trí dưới (tuỳ chọn).
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFF5FAFF), // xanh rất nhạt (gần trắng)
            Color(0xFFE8F1FC), // xanh nhạt hơn
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Image.asset(
              'assets/images/icon-bg.png',
              width: size.width,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}
