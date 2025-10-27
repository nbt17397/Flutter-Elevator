// user_model.dart

import 'package:hive/hive.dart';

// this line must be written by you
// for example => ( part 'filename.g.dart'; )
// FILENAME not class name and also all in lower case
part 'user_model.g.dart';

@HiveType(typeId: 1) // id must be unique
class UserModel {
  @HiveField(0)
  final String username;
  @HiveField(1)
  final bool isSuperuser;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String name;
  @HiveField(4)
  final int userId;
  @HiveField(5)
  final String accessToken;
  
  // ⭐️ Khai báo là bool? để tương thích ngược với dữ liệu cũ (null)
  @HiveField(6)
  final bool? isAlarm;

  UserModel(
      {required this.username,
      required this.isSuperuser,
      required this.email,
      required this.name,
      required this.userId,
      required this.accessToken,
      // isAlarm không required
      this.isAlarm}); 
      
  // ⭐️ Getter tiện ích để truy cập giá trị isAlarm an toàn (mặc định là false)
  bool get alarmStatus => isAlarm ?? false;

  // ⭐️ HÀM copyWith ĐƯỢC YÊU CẦU
  /// Tạo một bản sao mới của UserModel, cho phép cập nhật từng trường.
  UserModel copyWith({
    String? username,
    bool? isSuperuser,
    String? email,
    String? name,
    int? userId,
    String? accessToken,
    bool? isAlarm,
  }) {
    return UserModel(
      username: username ?? this.username,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      email: email ?? this.email,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      accessToken: accessToken ?? this.accessToken,
      // Cập nhật isAlarm nếu được truyền vào, hoặc giữ giá trị cũ
      isAlarm: isAlarm ?? this.isAlarm, 
    );
  }
}