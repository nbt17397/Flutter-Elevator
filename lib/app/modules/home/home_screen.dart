import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/aquabox/batch/batch_list_screen.dart';
import 'package:elevator/app/modules/home/bloc/location_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/menu_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LocationDB? _selectedMarkerInfo;
  late LocationBloc locationBloc;

  @override
  void initState() {
    super.initState();
    locationBloc = LocationBloc()..add(GetLocationByUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // nền trắng toàn màn
      body: BlocListener<LocationBloc, LocationState>(
        bloc: locationBloc,
        listener: (context, state) {
          if (state is GetLocationLoaded && state.locations.isNotEmpty) {}
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
              _selectedMarkerInfo = state.locations[0];
              return _buildMarkerInfoCard(
                  _selectedMarkerInfo!, state.locations);
            }
            return const Center(child: Text("No Data Available"));
          },
        ),
      ),
    );
  }

  Widget _buildMarkerInfoCard(LocationDB location, List<LocationDB> locations) {
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
      color: Colors.white,
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
          Expanded(child: _buildMenuGrid()),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<LocationDB> locations) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: size.width * .16,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: DropdownButton<LocationDB>(
        isExpanded: true,
        value: _selectedMarkerInfo ?? locations.first,
        dropdownColor: Colors.white,
        underline: const SizedBox(),
        iconEnabledColor: Colors.black87,
        onChanged: (LocationDB? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedMarkerInfo = newValue;
            });
          }
        },
        items: locations.map((location) {
          return DropdownMenuItem<LocationDB>(
            value: location,
            child: Text(
              location.name ?? '',
              style: const TextStyle(color: Colors.black87),
            ),
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
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<MenuItem> menuItems = [
      MenuItem(
        title: 'Vụ nuôi',
        asset: 'assets/images/timetable.png',
        onTap: () {
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => BatchListScreen()));
        },
      ),
      MenuItem(
        title: 'Công việc',
        asset: 'assets/images/checklist.png',
        onTap: () {},
      ),
      MenuItem(
        title: 'Tồn kho',
        asset: 'assets/images/inventory.png',
        onTap: () {},
      ),
      MenuItem(
        title: 'Cảnh báo',
        asset: 'assets/images/alarm.png',
        onTap: () {},
      ),
      MenuItem(
        title: 'Thiết bị',
        asset: 'assets/images/device.png',
        onTap: () {},
      ),
      MenuItem(
        title: 'Năng lượng',
        asset: 'assets/images/energy.png',
        onTap: () {},
      ),
      MenuItem(
        title: 'Cài đặt',
        asset: 'assets/images/setting.png',
        onTap: () {},
      ),
    ];

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
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(item.asset, fit: BoxFit.contain),
                ),
                const SizedBox(height: 6),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
