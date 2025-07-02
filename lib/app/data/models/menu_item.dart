import 'package:flutter/material.dart';

class MenuItem {
  final String title;
  final String asset;
  final VoidCallback onTap;
  const MenuItem({
    required this.title,
    required this.asset,
    required this.onTap,
  });
}
