import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/aquabox/alert/alert_screen.dart';
import 'package:elevator/app/modules/aquabox/batch/batch_list_screen.dart';
import 'package:elevator/app/modules/aquabox/energy/energy_report_screen.dart';
import 'package:elevator/app/modules/aquabox/setting/menu_setting_screen.dart';
import 'package:elevator/app/modules/aquabox/warehouse/warehouse_menu_screen.dart';
import 'package:elevator/app/modules/home/bloc/location_bloc.dart';
import 'package:elevator/app/modules/aquabox/scada/menu_scada_screen.dart';
import 'package:elevator/app/modules/aquabox/work/work_calendar_screen.dart';
import 'package:elevator/app/data/models/user_model.dart';
import 'package:elevator/app/data/models/menu_item.dart';
import 'package:elevator/app/components/app_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int? _selectedLocationId; // lưu id thay vì instance để tránh mismatch
  late LocationBloc locationBloc;
  late bool isSuperuser;

  @override
  void initState() {
    super.initState();
    locationBloc = LocationBloc()..add(GetLocationByUser());

    // Lấy user từ Hive
    final userBox = Hive.box<UserModel>('userModel');
    final user = userBox.getAt(0);
    isSuperuser = user?.isSuperuser ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BlocListener<LocationBloc, LocationState>(
          bloc: locationBloc,
          // Dùng listener để gán giá trị mặc định 1 lần khi data load
          listener: (context, state) {
            if (state is GetLocationLoaded &&
                _selectedLocationId == null &&
                state.locations.isNotEmpty) {
              setState(() {
                _selectedLocationId = state.locations.first.id;
              });
            }
          },
          child: BlocBuilder<LocationBloc, LocationState>(
            bloc: locationBloc,
            builder: (context, state) {
              if (state is GetLocationLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GetLocationFailure) {
                return Center(child: Text("Error: ${state.error}"));
              }
              if (state is GetLocationLoaded) {
                // đảm bảo luôn có selected location hợp lệ
                final locations = state.locations;
                final selected = locations.firstWhere(
                  (l) => l.id == _selectedLocationId,
                  orElse: () => locations.first,
                );
                // cập nhật _selectedLocationId nếu trước đó null (trường hợp listener không chạy)
                if (_selectedLocationId == null && mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      _selectedLocationId = selected.id;
                    });
                  });
                }
                return _buildMarkerInfoCard(selected, locations);
              }
              return const Center(child: Text("No Data Available"));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerInfoCard(
      LocationDB selectedLocation, List<LocationDB> locations) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDropdown(locations),
          Row(
            children: [
              _buildMetricBox(label: 'Nhiệt độ', value: '36.1°C'),
              _buildMetricBox(label: 'Độ ẩm', value: '83%'),
              _buildMetricBox(label: 'Gió', value: '3.09 km/h'),
            ],
          ),
          const Divider(thickness: .4, color: Colors.black12),
          Expanded(child: _buildMenuGrid(selectedLocation.id!)),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<LocationDB> locations) {
    Size size = MediaQuery.of(context).size;

    // Lấy object tương ứng với id đã chọn, fallback về first
    final LocationDB currentValue = locations.firstWhere(
      (loc) => loc.id == _selectedLocationId,
      orElse: () => locations.first,
    );

    return Container(
      height: size.width * .16,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFBBDEFB), Color(0xFFE3F2FD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButton<LocationDB>(
        isExpanded: true,
        value: currentValue,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        iconEnabledColor: Colors.white,
        onChanged: (LocationDB? newValue) {
          if (newValue != null) {
            setState(() => _selectedLocationId = newValue.id);
            // Nếu bạn muốn load dữ liệu theo location mới,
            // thêm event tương ứng ở đây (nếu bloc hỗ trợ).
            // example: locationBloc.add(GetLocationDetail(newValue.id));
          }
        },
        items: locations.map((location) {
          return DropdownMenuItem<LocationDB>(
            value: location,
            child: Text(location.name ?? '',
                style: const TextStyle(color: Colors.black87)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetricBox({required String label, required String value}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid(int locationId) {
    final allMenus = [
      MenuItem(
        title: 'Vụ nuôi',
        asset: 'assets/images/timetable.png',
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => BatchListScreen(isTest: locationId == 6 ? true : false))),
      ),
      MenuItem(
        title: 'Công việc',
        asset: 'assets/images/checklist.png',
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => WorkCalendarScreen())),
      ),
      MenuItem(
        title: 'Tồn kho',
        asset: 'assets/images/inventory.png',
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => WarehouseMenuScreen())),
      ),
      MenuItem(
        title: 'Cảnh báo',
        asset: 'assets/images/alarm.png',
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => AlertScreen(locationID: _selectedLocationId!))),
      ),
      MenuItem(
        title: 'Thiết bị',
        asset: 'assets/images/device.png',
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) =>
                    ScadaMenuScreen(locationId: _selectedLocationId!))),
      ),
      MenuItem(
        title: 'Năng lượng',
        asset: 'assets/images/energy.png',
        onTap: () => Navigator.push(
            context, CupertinoPageRoute(builder: (_) => EnergyReportScreen())),
      ),
      MenuItem(
        title: 'Cài đặt',
        asset: 'assets/images/setting.png',
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) =>
                    FarmSettingsMenuScreen(locationId: locationId))),
      ),
      MenuItem(
        title: 'Hướng dẫn',
        asset: 'assets/images/tutorial.png',
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (_) =>
                    FarmSettingsMenuScreen(locationId: locationId))),
      ),
    ];

    // ⚡ Lọc theo quyền
    // final menuItems = isSuperuser
    //     ? allMenus
    //     : allMenus.where((item) {
    //         return ['Thiết bị', 'Cảnh báo', 'Cài đặt'].contains(item.title);
    //       }).toList();
    final menuItems = allMenus;

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      physics: const BouncingScrollPhysics(),
      itemCount: menuItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, idx) {
        final item = menuItems[idx];
        return InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.15),
                  blurRadius: 0.4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Image.asset(item.asset, fit: BoxFit.contain)),
                const SizedBox(height: 6),
                Text(item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
