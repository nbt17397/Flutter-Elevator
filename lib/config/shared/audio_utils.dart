import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _sharedPlayer = AudioPlayer();
bool _isPlaying = false;

Future<void> playWarningSound(String level) async {
  if (_isPlaying) return; // Đang phát thì bỏ qua

  try {
    _isPlaying = true;
    await _sharedPlayer.play(AssetSource(
        level == '0' ? 'sounds/warning1.mp3' : 'sounds/warning3.mp3'));
    await Future.delayed(const Duration(seconds: 10));
    await _sharedPlayer.stop();
  } catch (e) {
    if (kDebugMode) {
      print("Lỗi phát âm thanh: $e");
    }
  } finally {
    _isPlaying = false;
  }
}