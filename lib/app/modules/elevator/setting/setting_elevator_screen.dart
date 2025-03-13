import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';

class SettingElevatorScreen extends StatefulWidget {
  final BoardDB board;
  const SettingElevatorScreen({super.key, required this.board});

  @override
  State<SettingElevatorScreen> createState() => _SettingElevatorScreenState();
}

class _SettingElevatorScreenState extends State<SettingElevatorScreen> {
  final List<Map<String, dynamic>> settingOptions = [
    {'title': 'Tải trọng tối đa', 'icon': Icons.scale, 'desc': '200kg'},
    {'title': 'Tốc độ thang máy', 'icon': Icons.speed, 'desc': '10m/s'},
    {'title': 'Thời gian đóng cửa', 'icon': Icons.timer, 'desc': '5s'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cài đặt thang máy'),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn thông số cần cài đặt',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: settingOptions.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ListTile(
                      leading: Icon(
                        settingOptions[index]['icon'],
                        color: Colors.white,
                      ),
                      title: Text(
                        settingOptions[index]['title'],
                        style: TextStyle(color: Colors.white),
                      ),
                      trailing: Text(
                        settingOptions[index]['desc'],
                        style: TextStyle(color: Colors.green),
                      ),
                      onTap: () {
                        _showSettingDialog(settingOptions[index]['title']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingDialog(String settingTitle) {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Nhập giá trị cho $settingTitle"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Nhập giá trị..."),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Hủy"),
            ),
            TextButton(
              onPressed: () {
                // Lưu giá trị (cần thêm logic xử lý lưu dữ liệu)
                Navigator.pop(context);
              },
              child: Text("Lưu"),
            ),
          ],
        );
      },
    );
  }
}
