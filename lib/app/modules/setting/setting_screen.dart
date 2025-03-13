import 'package:elevator/app/data/models/user_model.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../auth/bloc/login_bloc.dart';

class SettingScreen extends StatefulWidget {
  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  late LoginBloc loginBloc;
  @override
  void initState() {
    loginBloc = LoginBloc();
    super.initState();
  }

  @override
  void dispose() {
    loginBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          title: Text('Hồ sơ khách hàng'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
        ),
        body: BlocListener<LoginBloc, LoginState>(
          bloc: loginBloc,
          listener: (context, state) {
            if (state is LogoutSuccess) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg1.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ValueListenableBuilder(
              valueListenable: Hive.box<UserModel>('userModel').listenable(),
              builder: (context, Box<UserModel> box, _) {
                UserModel? _user;
                if (box.isNotEmpty) _user = box.getAt(0)!;
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              child: Image.asset('assets/images/person1.png'),
                            ),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.name ?? '',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text('Khách hàng VIP',
                                    style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Thông tin khách hàng
                    _buildProfileItem(
                        Icons.email, 'Email', 'nguyenvana@example.com'),
                    _buildProfileItem(
                        Icons.location_on, 'Địa chỉ', '123 Đường ABC, TP. HCM'),

                    // Phiên bản ứng dụng
                    _buildProfileItem(Icons.info, 'Phiên bản', '1.0.0'),

                    Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white),
                      child: ListTile(
                        leading: Icon(Icons.language, color: Colors.blueAccent),
                        title: Text('Cài đặt ngôn ngữ'),
                        trailing: DropdownButton<String>(
                          value: 'Tiếng Việt',
                          onChanged: (value) {},
                          items: ['Tiếng Việt', 'English'].map((String lang) {
                            return DropdownMenuItem<String>(
                              value: lang,
                              child: Text(lang),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    Spacer(),

                    // Nút đăng xuất
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          loginBloc.add(Logout());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Đăng xuất',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }

  Widget _buildProfileItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6), color: Colors.white),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
