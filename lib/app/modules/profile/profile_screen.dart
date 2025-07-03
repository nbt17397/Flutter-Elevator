import 'package:elevator/app/data/models/user_model.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../auth/bloc/login_bloc.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final LoginBloc _loginBloc;

  @override
  void initState() {
    super.initState();
    _loginBloc = LoginBloc();
  }

  @override
  void dispose() {
    _loginBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<UserModel>('userModel').listenable(),
          builder: (context, Box<UserModel> box, _) {
            final user = box.isNotEmpty ? box.getAt(0) : null;

            return Column(
              children: [
                // ---------- THẺ HỒ SƠ ----------
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black12),
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
                  value: true,
                  onChanged: (v) {},
                ),

                // ---------- NGÔN NGỮ ----------
                _buildLanguageItem(),

                // ---------- PHIÊN BẢN ----------
                _buildProfileItem(Icons.info, 'Phiên bản', '1.0.0'),
              ],
            );
          },
        ),
      ),
    );
  }

  //--- Widgets tiện ích ------------------------------------------------------

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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
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

  Widget _buildLanguageItem() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
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
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
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
