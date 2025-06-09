import 'package:dropdown_search/dropdown_search.dart';
import 'package:elevator/app/data/models/user_model.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
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
      appBar: AppBar(
        title: Text('Hồ sơ khách hàng', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Container(
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
                // Khung thông tin khách hàng
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage:
                            AssetImage('assets/images/person1.png'),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _user?.name.toUpperCase() ?? 'Người dùng',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Khách hàng VIP',
                              style: TextStyle(color: Colors.grey[400])),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                //   margin: EdgeInsets.only(bottom: 2),
                //   decoration: BoxDecoration(
                //     color: Colors.black.withOpacity(0.6),
                //     borderRadius: BorderRadius.circular(6),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(Icons.devices_other_outlined,
                //               color: Colors.blueAccent),
                //           SizedBox(width: 10),
                //           Text('Thêm thiết bị',
                //               style: TextStyle(color: Colors.white)),
                //         ],
                //       ),
                //       IconButton(
                //           onPressed: () => _showAddDeviceDialog(context),
                //           icon: Icon(Icons.add_box, color: Colors.white))
                //     ],
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notifications_active,
                              color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text('Thông báo',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      CupertinoSwitch(
                        value: true,
                        onChanged: (bool value) async {
                          print(value);
                        },
                      )
                    ],
                  ),
                ),
                // Cài đặt ngôn ngữ
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.language, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text('Cài đặt ngôn ngữ',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      DropdownButton<String>(
                        dropdownColor: Colors.black,
                        value: 'Tiếng Việt',
                        onChanged: (value) {},
                        items: ['Tiếng Việt', 'English'].map((String lang) {
                          return DropdownMenuItem<String>(
                            value: lang,
                            child: Text(lang,
                                style: TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                _buildProfileItem(Icons.info, 'Phiên bản', '1.0.0'),
                SizedBox(height: 20),
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
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 2),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.white)),
              SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddDeviceDialog(BuildContext context) {
  TextEditingController _uuidController = TextEditingController();
  String? selectedCustomer;
  String? selectedLocation;

  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.black.withOpacity(0.9),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tiêu đề
              Text(
                'Thêm thiết bị',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // Dropdown chọn khách hàng
              DropdownSearch<String>(
                items: (filter, infiniteScrollProps) =>
                    ["Khách hàng A", "Khách hàng B", "Khách hàng C"],
                selectedItem: selectedCustomer,
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(color: Colors.white),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    labelText: "Chọn khách hàng",
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(maxHeight: 400),
                  showSelectedItems: true,
                  showSearchBox: true,
                  containerBuilder: (context, popupWidget) {
                    return Material(
                      color: Colors.black87,
                      child: popupWidget,
                    );
                  },
                ),
                onChanged: (value) {
                  selectedCustomer = value;
                },
              ),
              SizedBox(height: 10),

              // Dropdown chọn địa điểm
              DropdownSearch<String>(
                items: (filter, infiniteScrollProps) =>
                    ["Tầng 1", "Tầng 2", "Tầng 3"],
                selectedItem: selectedLocation,
                decoratorProps: DropDownDecoratorProps(
                  baseStyle: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Chọn địa điểm",
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                popupProps: PopupProps.menu(
                  fit: FlexFit.loose,
                  constraints: BoxConstraints(maxHeight: 200),
                  showSelectedItems: true,
                  showSearchBox: true,
                  containerBuilder: (context, popupWidget) {
                    return Material(
                      color: Colors.black87,
                      child: popupWidget,
                    );
                  },
                ),
                onChanged: (value) {
                  selectedLocation = value;
                },
              ),
              SizedBox(height: 10),

              // TextField nhập UUID
              TextField(
                controller: _uuidController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Nhập UUID thiết bị',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.qr_code, color: Colors.white),
                    onPressed: () {
                      // Gọi hàm quét QR ở đây
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Nút gửi yêu cầu
              ElevatedButton(
                onPressed: () {
                  String uuid = _uuidController.text.trim();
                  if (uuid.isNotEmpty &&
                      selectedCustomer != null &&
                      selectedLocation != null) {
                    // Thực hiện gửi yêu cầu ghép nối
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Gửi yêu cầu',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
