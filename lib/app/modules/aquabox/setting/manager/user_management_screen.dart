import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/shared/colors.dart';
import '../../../../components/app_background.dart';
import '../../../../data/json_annotation/location_user_db.dart';
import '../../../../services/reporitories/location_user_repo.dart';
import '../../../../data/response/login_response.dart';
import '../../../../services/reporitories/user_repo.dart';
import 'bloc/location_user_bloc.dart';

/// --------- MÀN HÌNH QUẢN LÝ NHÂN VIÊN ---------
class UserManagementScreen extends StatefulWidget {
  final int locationId;
  const UserManagementScreen({super.key, required this.locationId});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  late final LocationUserBloc _locationUserBloc;
  final UserRepo _userRepo = UserRepo();

  @override
  void initState() {
    super.initState();
    _locationUserBloc = LocationUserBloc(LocationUserRepo());
    _locationUserBloc.add(LoadLocationUsers(widget.locationId));
  }

  @override
  void dispose() {
    _locationUserBloc.close();
    super.dispose();
  }

  BoxDecoration get _box => BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      );

  /* ---------- DIALOG THÊM / SỬA ---------- */
  Future<void> _showUserDialog({LocationUserDB? locationUser}) async {
    final formKey = GlobalKey<FormState>();
    UserInfo? selectedUser;
    String selectedRole = locationUser?.role ?? 'operator';

    final Future<List<UserInfo>> usersFuture = _userRepo.getUsers();

    Alert(
      context: context,
      title: locationUser == null ? 'THÊM NHÂN VIÊN' : 'SỬA THÔNG TIN',
      style: AlertStyle(
        titleStyle:
            TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold),
        alertPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        isCloseButton: false,
      ),
      content: Form(
        key: formKey,
        child: Column(
          children: [
            if (locationUser == null)
              FutureBuilder<List<UserInfo>>(
                future: usersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Text('Không thể tải danh sách người dùng',
                        style: TextStyle(color: Colors.red));
                  }
                  final users = snapshot.data!;
                  return DropdownButtonFormField<UserInfo>(
                    decoration: const InputDecoration(
                      labelText: 'Chọn nhân viên',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: users
                        .map((user) => DropdownMenuItem(
                              value: user,
                              child: Text(user.name ?? user.username ?? 'N/A'),
                            ))
                        .toList(),
                    onChanged: (value) => selectedUser = value,
                    validator: (v) => v == null ? 'Không được để trống' : null,
                  );
                },
              ),
            if (locationUser == null) const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: const InputDecoration(
                labelText: 'Cấp bậc',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ['manager', 'operator']
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child:
                            Text(role == 'manager' ? 'Quản lý' : 'Nhân viên'),
                      ))
                  .toList(),
              onChanged: (val) => selectedRole = val ?? 'operator',
            ),
          ],
        ),
      ),
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.blue.shade700,
          onPressed: () {
            if (!(formKey.currentState?.validate() ?? false)) return;

            if (locationUser == null) {
              _locationUserBloc.add(
                AddLocationUser(
                  LocationUserDB(
                    id: 0,
                    location: widget.locationId,
                    user: selectedUser!.id!,
                    userName: selectedUser!.name ?? selectedUser!.username,
                    role: selectedRole,
                    joinedAt: DateTime.now(),
                  ),
                ),
              );
            } else {
              _locationUserBloc.add(
                UpdateLocationUser(
                  locationUser.user,
                  LocationUserDB(
                    id: locationUser.id,
                    location: locationUser.location,
                    user: locationUser.user,
                    userName: locationUser.userName,
                    role: selectedRole,
                    joinedAt: locationUser.joinedAt,
                  ),
                ),
              );
            }
            Navigator.pop(context);
            // Thêm lệnh tải lại dữ liệu sau khi đóng dialog
            _locationUserBloc.add(LoadLocationUsers(widget.locationId));
          },
          child: const Text('Lưu', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- XOÁ ---------- */
  void _confirmDelete(LocationUserDB locationUser) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'XOÁ NHÂN VIÊN',
      desc: 'Bạn có chắc muốn xoá "${locationUser.userName}"?',
      buttons: [
        DialogButton(
          color: Colors.grey.shade400,
          onPressed: () => Navigator.pop(context),
          child: const Text('Huỷ', style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          color: Colors.red.shade700,
          onPressed: () {
            _locationUserBloc.add(DeleteLocationUser(locationUser.user));
            Navigator.pop(context);
            // Thêm lệnh tải lại dữ liệu sau khi đóng dialog
            _locationUserBloc.add(LoadLocationUsers(widget.locationId));
          },
          child: const Text('Xoá', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).show();
  }

  /* ---------- HIỆU ỨNG LOADING SHIMMER ---------- */
  Widget _buildShimmerEffect() {
    return ListView.separated(
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  /* ---------- UI CHÍNH ---------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Quản lý Nhân viên'),
          backgroundColor: CustomColors.appbarColor,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _showUserDialog(),
              icon: const Icon(Icons.add),
              tooltip: 'Thêm nhân viên',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: BlocProvider.value(
            value: _locationUserBloc,
            child: BlocBuilder<LocationUserBloc, LocationUserState>(
              builder: (context, state) {
                if (state is LocationUserLoading) {
                  return _buildShimmerEffect();
                } else if (state is LocationUserLoaded) {
                  return ListView.separated(
                    itemCount: state.locationUsers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final user = state.locationUsers[i];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: _box,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.userName ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.role == 'manager'
                                        ? 'Quản lý'
                                        : 'Nhân viên',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showUserDialog(locationUser: user);
                                } else if (value == 'delete') {
                                  _confirmDelete(user);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text('Sửa')),
                                PopupMenuItem(
                                    value: 'delete', child: Text('Xoá')),
                              ],
                              icon: const Icon(Icons.more_vert),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is LocationUserError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  );
                }
                return const Center(child: Text('Không có dữ liệu'));
              },
            ),
          ),
        ),
      ),
    );
  }
}
