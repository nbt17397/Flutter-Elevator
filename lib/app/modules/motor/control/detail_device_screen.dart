import 'package:elevator/app/data/response/register_response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../config/shared/colors.dart';

class DeviceDetailScreen extends StatefulWidget {
  final RegisterDB register;
  const DeviceDetailScreen({super.key, required this.register});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  RegisterDB get register => widget.register;
  bool isOn = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(register.name.toString()),
        backgroundColor: CustomColors.appbarColor,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final newName =
                  await _showEditNameDialog(context, register.name ?? '');
              if (newName != null && newName != register.name) {
                setState(() {
                  register.name = newName;
                });
              }
            },
            icon: Icon(Icons.edit),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.45,
              child: Center(
                child: CircleAvatar(
                  radius: size.width * 0.35,
                  backgroundColor: Colors.grey.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Hero(
                      tag: 'device-${register.id}',
                      child: Image.asset(
                        'assets/images/${register.type}.png',
                        fit: BoxFit.contain,
                        width: size.width * 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8),
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  Text(
                    isOn ? "Đang hoạt động" : "Ngưng hoạt động",
                    style: TextStyle(
                      color: isOn ? Colors.green : Colors.red,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoSwitch(
                    value: isOn,
                    onChanged: (value) {
                      setState(() {
                        isOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomButton(
                      icon: Icons.history,
                      label: "Lịch sử",
                      onTap: () {},
                    ),
                    _BottomButton(
                      icon: Icons.settings,
                      label: "Cài đặt",
                      onTap: () {
                        // handle
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showEditNameDialog(
      BuildContext context, String currentName) async {
    final TextEditingController controller =
        TextEditingController(text: currentName);

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text('Đổi tên thiết bị'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên mới',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Huỷ'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text.trim());
              },
              child: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, size: 28),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
