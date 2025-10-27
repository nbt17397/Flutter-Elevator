import 'dart:convert';
import 'package:flutter/foundation.dart';

String fixMqttUtf8(String badString) {
  try {
    // 1. Mã hóa chuỗi lỗi về bytes, giả sử nó được mã hóa sai thành Latin-1/ISO-8859-1.
    // Dữ liệu ban đầu là UTF-8, nhưng đã bị Flutter/Dart đọc sai thành Latin-1
    // vì vậy, khi ta mã hóa lại chuỗi lỗi này bằng Latin-1, ta sẽ thu được các bytes UTF-8 gốc.
    List<int> latin1Bytes = latin1.encode(badString);

    // 2. Giải mã lại các bytes đó bằng UTF-8.
    // Kết quả là chuỗi tiếng Việt đã được sửa.
    return utf8.decode(latin1Bytes);
  } catch (e) {
    if (kDebugMode) {
      print('Lỗi khi sửa UTF-8: $e');
    }
    // Trả về chuỗi gốc nếu có lỗi xảy ra
    return badString;
  }
}