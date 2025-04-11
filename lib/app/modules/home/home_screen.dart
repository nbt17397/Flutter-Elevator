import 'package:elevator/app/data/response/location_response.dart';
import 'package:elevator/app/modules/elevator/scada/scada_elevator_screen.dart';
import 'package:elevator/app/modules/home/bloc/location_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController _controller;
  LocationDB? _selectedMarkerInfo;
  Set<Marker> _markers = {};
  late LocationBloc locationBloc;

  @override
  void initState() {
    super.initState();
    locationBloc = LocationBloc()..add(GetLocationByUser());
  }

  void _onMarkerTapped(LocationDB? location) {
    setState(() {
      _selectedMarkerInfo = location;
    });
    _controller.showMarkerInfoWindow(MarkerId(location!.id.toString()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<LocationBloc, LocationState>(
        bloc: locationBloc,
        listener: (context, state) {
          if (state is GetLocationLoaded && state.locations.isNotEmpty) {}
        },
        child: BlocBuilder<LocationBloc, LocationState>(
          bloc: locationBloc,
          builder: (context, state) {
            if (state is GetLocationLoading) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (state is GetLocationFailure) {
              return Center(child: Text("Error: ${state.error}"));
            }
            if (state is GetLocationLoaded) {
              _markers = state.locations.map((location) {
                return Marker(
                  markerId: MarkerId(location.id.toString()),
                  position: LatLng(location.lat!, location.lng!),
                  infoWindow: InfoWindow(title: location.name),
                  onTap: () => _onMarkerTapped(location),
                );
              }).toSet();

              return Stack(
                children: [
                  Positioned.fill(
                    child: GoogleMap(
                      onMapCreated: (controller) {
                        setState(() {
                          _controller = controller;
                        });

                        if (state.locations.isNotEmpty) {
                          Future.delayed(const Duration(milliseconds: 300), () {
                            _moveCameraToFirstLocation(state.locations);
                          });
                        }
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                            state.currentLatitude, state.currentLongitude),
                        zoom: 12,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                  ),
                  if (_selectedMarkerInfo != null)
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: _buildMarkerInfoCard(
                          _selectedMarkerInfo!, state.locations),
                    ),
                ],
              );
            }
            return Center(child: Text("No Data Available"));
          },
        ),
      ),
    );
  }

  Widget _buildMarkerInfoCard(LocationDB location, List<LocationDB> locations) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          margin: EdgeInsets.only(top: 16), // Tạo khoảng trống cho nút đóng
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(locations),
              Text(
                location.description!,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Divider(thickness: .4),
              Row(
                children: location.boards?.map((item) {
                      return badges.Badge(
                        showBadge: item.status!,
                        position:
                            badges.BadgePosition.topEnd(top: -12, end: -8),
                        badgeContent: Text('3'),
                        badgeStyle: badges.BadgeStyle(
                          shape: badges.BadgeShape.square,
                          badgeColor: Colors.red,
                          padding: EdgeInsets.all(5),
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          elevation: 0,
                        ),
                        ignorePointer: false,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (_) =>
                                      ScadaElevatorScreen(board: item))),
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 9),
                            padding: const EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: item.status!
                                  ? Colors.green
                                  : Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                item.name.toString(),
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarkerInfo = null;
              });
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(List<LocationDB> locations) {
    Size size = MediaQuery.of(context).size;
    return Container(
      // width: size.width * .7,
      height: size.width * .16,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<LocationDB>(
        isExpanded: true,
        value: _selectedMarkerInfo ?? locations.first,
        dropdownColor: Colors.black.withOpacity(0.7),
        underline: SizedBox(),
        iconEnabledColor: Colors.white,
        onChanged: (LocationDB? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedMarkerInfo = newValue;
              LatLng target = LatLng(newValue.lat!, newValue.lng!);
              _controller.animateCamera(CameraUpdate.newLatLngZoom(target, 13));
            });
          }
        },
        items: locations.map<DropdownMenuItem<LocationDB>>((location) {
          return DropdownMenuItem<LocationDB>(
            value: location,
            child: Text(
              location.name!,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _moveCameraToFirstLocation(List<LocationDB> locations) {
    if (locations.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        LatLng firstLocation = LatLng(locations[0].lat!, locations[0].lng!);
        _controller
            .animateCamera(CameraUpdate.newLatLngZoom(firstLocation, 13));
        _onMarkerTapped(locations[0]);
      });
    }
  }
}
