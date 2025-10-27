import 'package:flutter/foundation.dart'; // Thêm kDebugMode

import 'package:audioplayers/audioplayers.dart';

Future<void> playWarningSound(String level) async {
  try {
    final player = AudioPlayer();
    // Phát file từ assets/warning1.mp3
    await player.play(AssetSource(
        level == '0' ? 'sounds/warning1.mp3' : 'sounds/warning3.mp3'));
    await Future.delayed(Duration(seconds: 2));
    await player.stop();
  } catch (e) {
    if (kDebugMode) {
      print("Lỗi phát âm thanh: $e");
    }
  }
}
