import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/app/data/models/user_model.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../../services/mqtt/mqtt_provider.dart';
import '../auth/bloc/login_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final LoginBloc _loginBloc;
  late MqttProvider _mqtt;

  @override
  void initState() {
    super.initState();
    _mqtt = Provider.of<MqttProvider>(context, listen: false);
    _loginBloc = LoginBloc();
  }

  @override
  void dispose() {
    _loginBloc.close();
    super.dispose();
  }

  // ⭐️ HÀM XỬ LÝ CẬP NHẬT IS_ALARM TRONG HIVE
  void _toggleAlarm(UserModel user, bool newValue) {
    if (user.userId == 0) return; // Bảo vệ nếu user là null/default

    final userBox = Hive.box<UserModel>('userModel');
    final key =
        userBox.keyAt(0); // Giả định UserModel chỉ có 1 entry tại index 0

    // 1. Tạo bản sao mới với isAlarm được cập nhật
    final updatedUser = user.copyWith(isAlarm: newValue);

    // 2. Lưu (ghi đè) lại đối tượng mới vào Hive
    userBox.put(key, updatedUser);

    // Có thể show SnackBar thông báo thành công nếu cần
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
          child: ValueListenableBuilder(
            valueListenable: Hive.box<UserModel>('userModel').listenable(),
            builder: (context, Box<UserModel> box, _) {
              // Lấy user đầu tiên, nếu box không rỗng.
              final user = box.isNotEmpty ? box.getAt(0) : null;
              final userKey = box.isNotEmpty ? box.keyAt(0) : null;

              // ⭐️ LẤY TRẠNG THÁI IS_ALARM, DÙNG alarmStatus GETTER AN TOÀN
              final isAlarmEnabled = user?.isAlarm ?? false;

              return Column(
                children: [
                  // ---------- THẺ HỒ SƠ (Giữ nguyên) ----------
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage('assets/images/person1.png'),
                        ),
                        const SizedBox(width: 16),
                        // --------- Tên & hạng ---------
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name.toUpperCase() ?? 'NGƯỜI DÙNG',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('Khách hàng VIP',
                                style: TextStyle(color: Colors.blue.shade600)),
                          ],
                        ),
                        const Spacer(), // đẩy nút sang bên phải
                        // --------- NÚT ĐĂNG XUẤT ---------
                        ElevatedButton.icon(
                          onPressed: () => _loginBloc.add(Logout()),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          icon: const Icon(Icons.logout,
                              size: 18, color: Colors.white),
                          label: const Text('',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- THÔNG BÁO ----------
                  _buildSwitchItem(
                    icon: Icons.notifications_active,
                    title: 'Thông báo',
                    // ⭐️ Đặt giá trị hiện tại
                    value: isAlarmEnabled,
                    // ⭐️ GỌI HÀM CẬP NHẬT
                    onChanged: (newValue) {
                      if (user != null && userKey != null) {
                        _toggleAlarm(user, newValue);
                        if (newValue) {
                          _mqtt.subscribeTopic('aquabox/alarm/get');
                        }else{
                          _mqtt.unsubscribeTopic('aquabox/alarm/get');
                        }
                      }
                    },
                  ),

                  // ---------- NGÔN NGỮ ----------
                  _buildLanguageItem(),

                  // ---------- PHIÊN BẢN ----------
                  _buildProfileItem(Icons.info, 'Phiên bản', '1.0.0'),
                  _buildProfileItem(Icons.info, 'CÔNG TY CỔ PHẦN HẠO PHƯƠNG',
                      'Email: Info@haophuong.com'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  //... (Các widget tiện ích giữ nguyên)

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              Text(title,
                  style: const TextStyle(color: Colors.black87, fontSize: 14)),
            ],
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  // ... (Phần còn lại của _buildLanguageItem và _buildProfileItem)
  Widget _buildLanguageItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.language, color: Colors.blue.shade600),
              const SizedBox(width: 10),
              const Text('Cài đặt ngôn ngữ',
                  style: TextStyle(color: Colors.black87, fontSize: 14)),
            ],
          ),
          DropdownButton<String>(
            dropdownColor: Colors.white,
            value: 'Tiếng Việt',
            underline: const SizedBox(),
            iconEnabledColor: Colors.blue.shade600,
            onChanged: (value) {},
            items: ['Tiếng Việt', 'English'].map((lang) {
              return DropdownMenuItem(
                value: lang,
                child:
                    Text(lang, style: const TextStyle(color: Colors.black87)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade600),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(color: Colors.black87, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
