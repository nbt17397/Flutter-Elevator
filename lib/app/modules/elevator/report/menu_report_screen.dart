import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/data/response/register_response.dart';
import 'package:elevator/app/modules/elevator/alarm/alarm_elevator_screen.dart';
import 'package:elevator/app/modules/elevator/report/bloc/register_bloc.dart';
import 'package:elevator/app/modules/elevator/report/elevator_temperature_chart.dart';
import 'package:elevator/app/modules/elevator/report/elevator_door_open_chart.dart';
import 'package:elevator/app/modules/elevator/report/elevator_usage_floor_chart.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MenuReportScreen extends StatefulWidget {
  final BoardDB board;
  const MenuReportScreen({super.key, required this.board});

  @override
  State<MenuReportScreen> createState() => _MenuReportScreenState();
}

class _MenuReportScreenState extends State<MenuReportScreen> {
  late RegisterBloc _registerBloc;

  final List<Map<String, dynamic>> reportOptions = [
    {'title': 'Số lần đóng mở cửa thang máy', 'icon': Icons.elevator},
    {'title': 'Số lần mở cửa tầng', 'icon': Icons.door_front_door},
    {'title': 'Biến tầng nhiệt độ', 'icon': Icons.thermostat},
    {'title': 'Cảnh báo', 'icon': Icons.notifications_active_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _registerBloc = RegisterBloc();
    _registerBloc
        .add(FetchRegisterEvent(widget.board.id!)); // 👈 gọi API tại đây
  }

  @override
  void dispose() {
    _registerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tra cứu dữ liệu'),
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
        child: BlocBuilder<RegisterBloc, RegisterState>(
          bloc: _registerBloc,
          builder: (context, state) {
            if (state is RegisterLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is RegisterLoaded) {
              return _buildBody(state.data);
            } else if (state is RegisterError) {
              return Center(
                  child: Text('Lỗi: ${state.message}',
                      style: TextStyle(color: Colors.red)));
            }
            return Container();
          },
        ),
      ),
    );
  }

  int GetIdByName({required List<RegisterDB>? results, required String name}) {
    try {
      final register = results?.firstWhere(
        (item) => item.name?.toLowerCase().trim() == name.toLowerCase().trim(),
        orElse: () => RegisterDB(id: -1),
      );
      return register?.id ?? -1;
    } catch (e) {
      print('Lỗi tìm ID: $e');
      return -1;
    }
  }

  Widget _buildBody(RegisterResponse data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn loại báo cáo',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: reportOptions.length,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ListTile(
                  leading:
                      Icon(reportOptions[index]['icon'], color: Colors.white),
                  title: Text(reportOptions[index]['title'],
                      style: TextStyle(color: Colors.white)),
                  trailing: Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 14),
                  onTap: () {
                    switch (index) {
                      case 0:
                        {
                          int tmp = GetIdByName(
                              results: data.results, name: "TAG005");
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>
                                  ElevatorDoorOpenChart(registerId: tmp),
                            ),
                          );
                          break;
                        }
                      case 1:
                        {
                          int tmp = GetIdByName(
                              results: data.results, name: "TAG005");
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>
                                  ElevatorUsageFloorChart(registerId: tmp),
                            ),
                          );
                          break;
                        }
                      case 2:
                        {
                          int tmp = GetIdByName(
                              results: data.results, name: "TAG055");
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>
                                  ElevatorTemperatureChart(registerId: tmp),
                            ),
                          );
                          break;
                        }
                      // case 3:
                      //   {
                      //     int tmp = GetIdByName(
                      //         results: data.results, name: "TAG050");
                      //     Navigator.push(
                      //       context,
                      //       CupertinoPageRoute(
                      //         builder: (_) =>
                      //             ElevatorSpeedChart(registerId: tmp),
                      //       ),
                      //     );
                      //     break;
                      //   }
                      default:
                        {
                          int tmp = GetIdByName(
                              results: data.results, name: "TAG049");
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) =>
                                  AlarmElevatorScreen(registerID: tmp),
                            ),
                          );
                          break;
                        }
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
