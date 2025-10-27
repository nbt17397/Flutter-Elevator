import 'dart:math';
import 'package:elevator/app/components/app_background.dart';
import 'package:elevator/config/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

// Import các file cần thiết từ NotificationRepo
import 'package:elevator/app/data/response/notification_response.dart';

import '../../../services/reporitories/notification_repo.dart';

/// ======== SCREEN (stateful) ========
class AlertScreen extends StatefulWidget {
  final int locationID;
  const AlertScreen({super.key, required this.locationID});
  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen>
    with SingleTickerProviderStateMixin {
  // Dữ liệu hợp nhất từ API (sử dụng cho cả Task và Device view)
  final List<NotificationDB> _taskAlerts = [];

  // Thêm Repository và Location ID
  final NotificationRepo _notificationRepo = NotificationRepo();

  // ⚡️ Biến mới: Theo dõi trang hiện tại cho việc Load More
  int _currentPage = 1;

  final _rng = Random();
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  static const int _pageSize = 10;
  static const int _maxItems = 100;

  // Biến trạng thái mới để quản lý việc hiển thị Task/Device (thay thế TabBar)
  // Mặc định là FALSE (Thiết bị)
  bool _isTaskTab = false;

  bool _loading = false; // Trạng thái loading chung
  bool _canLoadMore = true; // Cờ kiểm tra còn dữ liệu để load chung

  // Bộ lọc chung cho cả 2 view: 0: Chưa xử lý, 1: Đã xử lý
  int _taskFilter = 0;

  final ScrollController _listCtrl =
      ScrollController(); // Scroll Controller chung

  @override
  void initState() {
    super.initState();
    _fetchAlerts(isInitial: true); // Gọi API chung khi khởi tạo
    _listCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _listCtrl.removeListener(_onScroll);
    _listCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final ctrl = _listCtrl;
    if (ctrl.position.pixels >= ctrl.position.maxScrollExtent - 200 &&
        !_loading &&
        _canLoadMore) {
      _loadMore();
    }
  }

  void _loadMore() {
    _fetchAlerts();
  }

  // Hàm gọi API thực tế đã được hợp nhất (Cập nhật logic phân trang)
  Future<void> _fetchAlerts({bool isInitial = false}) async {
    if (_loading && !isInitial) return;
    if (!isInitial && !_canLoadMore) return;

    if (isInitial) {
      _taskAlerts.clear();
      _currentPage = 1; // ⚡️ Reset trang về 1 khi refresh/tải lần đầu
      _canLoadMore = true;
      // Quay lại đầu danh sách khi refresh
      if (_listCtrl.hasClients) {
        _listCtrl.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    }

    // ⚡️ Xác định page sẽ gọi
    final pageToFetch = _currentPage;

    setState(() => _loading = true);

    try {
      // ⚡️ Dùng biến pageToFetch
      final newAlerts = await _notificationRepo.getNotificationByLocationId(
          locationId: widget.locationID, page: pageToFetch
          // Thêm các tham số phân trang thực tế nếu API có
          );

      setState(() {
        _taskAlerts.addAll(newAlerts);
        _loading = false;

        // ⚡️ Tăng trang cho lần load tiếp theo nếu có dữ liệu
        if (newAlerts.isNotEmpty) {
          _currentPage++;
        }

        // Logic kiểm tra còn data để load không
        // Nếu số lượng item mới nhỏ hơn pageSize hoặc tổng item đạt maxItems
        if (newAlerts.length < _pageSize || _taskAlerts.length >= _maxItems) {
          _canLoadMore = false;
        }
      });
    } catch (e) {
      debugPrint('Lỗi khi tải thông báo: $e');
      setState(() {
        _loading = false;
        _canLoadMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Không thể tải thông báo. Lỗi: ${e.toString()}')),
      );
    }
  }

  // Hàm chung để ánh xạ màu sắc và icon
  Color _colorFor(String lv) => switch (lv) {
        '1' => Colors.red.shade600,
        '0' => Colors.orange.shade700,
        _ => Colors.green.shade600,
      };

  IconData _iconFor(String lv) => switch (lv) {
        '1' => Icons.warning,
        '0' => Icons.error,
        _ => Icons.info,
      };

  // Dialog xác nhận chung cho cả Task và Device
  void _showConfirmDialog(NotificationDB alert) {
    final isProcessed = alert.isConfirm ?? false;
    final msg = isProcessed
        ? 'Bạn có muốn hủy xác nhận hoàn thành?'
        : 'Bạn có muốn xác nhận hoàn thành?';
    final buttonText = isProcessed ? 'Hủy hoàn thành' : 'Hoàn thành';

    Alert(
      context: context,
      type: AlertType.warning,
      title: "Xác nhận",
      desc: msg,
      buttons: [
        DialogButton(
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
          child: const Text("Trì hoãn", style: TextStyle(color: Colors.white)),
        ),
        DialogButton(
          onPressed: () async {
            Navigator.pop(context); // Đóng dialog ngay lập tức

            final isProcessed = alert.isConfirm ?? false;
            final newStatus = !isProcessed;

            setState(() => _loading = true); // Hiển thị loading khi gọi API

            try {
              // ⚡️ Gọi API để cập nhật trạng thái
              final updatedAlert =
                  await _notificationRepo.updateNotificationConfirmStatus(
                notificationId: alert.id!,
                isConfirmStatus: newStatus,
              );

              // Cập nhật trạng thái trong danh sách local sau khi gọi API thành công
              setState(() {
                final index = _taskAlerts.indexOf(alert);
                if (index != -1) {
                  // Thay thế đối tượng cũ bằng đối tượng mới được trả về từ API
                  _taskAlerts[index] = updatedAlert;
                }
                _loading = false;
              });

              // Hiển thị thông báo thành công
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(newStatus
                        ? 'Xác nhận hoàn thành thành công!'
                        : 'Đã hủy xác nhận!')),
              );
            } catch (e) {
              setState(() => _loading = false);
              // Hiển thị lỗi nếu API thất bại
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Cập nhật thất bại: ${e.toString()}')),
              );
            }
          },
          color: Colors.blueAccent,
          child: Text(
            buttonText,
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    ).show();
  }

  void _toggleTab() {
    setState(() {
      _isTaskTab = !_isTaskTab;
      // Cuộn lên đầu khi chuyển tab để có trải nghiệm tốt hơn
      if (_listCtrl.hasClients) {
        _listCtrl.animateTo(0,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
    // Có thể gọi lại _fetchAlerts(isInitial: true) nếu dữ liệu Task và Device là khác nhau
    // và cần gọi API riêng biệt (nhưng hiện tại bạn đang dùng chung _taskAlerts)
  }

  @override
  Widget build(BuildContext context) {
    final title = _isTaskTab ? 'Công việc' : 'Thiết bị';
    final toggleIcon = _isTaskTab ? Icons.devices_other : Icons.assignment;
    final toggleTooltip =
        _isTaskTab ? 'Chuyển sang Thiết bị' : 'Chuyển sang Công việc';

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Cảnh báo - $title'),
          centerTitle: true,
          backgroundColor: CustomColors.appbarColor,
          actions: [
            // Icon để chuyển đổi giữa 'Công việc' và 'Thiết bị'
            IconButton(
              icon: Icon(toggleIcon),
              tooltip: toggleTooltip,
              onPressed: _toggleTab,
            ),
          ],
        ),
        body: _isTaskTab ? _taskTab() : _deviceTab(),
      ),
    );
  }

  // Cấu trúc lọc và danh sách chung cho Task và Device
  Widget _buildFilteredList({
    required bool isTaskView,
    required Widget Function(int i, NotificationDB a) itemBuilder,
  }) {
    // Lọc dữ liệu dựa trên _taskFilter (isConfirm)
    final list = _taskAlerts
        .where((a) =>
            _taskFilter == 0 ? !(a.isConfirm ?? false) : (a.isConfirm ?? false))
        .toList();

    return Column(
      children: [
        const SizedBox(height: 8),
        _TaskSegment(
          // Bộ lọc "Chưa xử lý / Đã xử lý" chung
          selected: _taskFilter,
          onChanged: (i) => setState(() {
            _taskFilter = i;
            // Cuộn lên đầu khi thay đổi filter
            if (_listCtrl.hasClients) {
              _listCtrl.animateTo(0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut);
            }
          }),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _alertList(
            onRefresh: () async => await _fetchAlerts(isInitial: true),
            controller: _listCtrl,
            dataLen: list.length,
            loading: _loading,
            canLoadMore: _canLoadMore,
            itemBuilder: (i) => itemBuilder(i, list[i]),
          ),
        ),
      ],
    );
  }

  Widget _taskTab() {
    return _buildFilteredList(
      isTaskView: true,
      itemBuilder: (i, a) {
        final title = a.title ?? 'Cảnh báo Công việc';
        // ⚡️ Fix múi giờ: Chuyển timestamp (giả định là UTC) sang giờ địa phương
        final date = a.timestamp != null
            ? a.timestamp!.toLocal()
            : DateTime.now().toLocal();
        // Giả định cấp độ cảnh báo (level) là "Cao" nếu là "Task"
        // Chú ý: Hàm _colorFor và _iconFor đang nhận String '0'/'1', nên giữ nguyên logic này
        String level = a.level == 0 ? '0' : '1';

        return _alertCard(
          leading: a.id.toString(),
          title: title,
          subtitle: _fmt.format(date),
          level: level,
          onTap: () => _showConfirmDialog(a), // Cho phép xác nhận
        );
      },
    );
  }

  Widget _deviceTab() {
    return _buildFilteredList(
      isTaskView: false,
      itemBuilder: (i, d) {
        // Ánh xạ dữ liệu NotificationDB sang Card Device
        final deviceCode = 'TB${d.id ?? 0}';
        final deviceName = d.title ?? 'Cảnh báo Thiết bị';
        // ⚡️ Fix múi giờ: Chuyển timestamp (giả định là UTC) sang giờ địa phương
        final faultTime = d.timestamp != null
            ? d.timestamp!.toLocal()
            : DateTime.now().toLocal();
        // Giả định mức độ cảnh báo ngẫu nhiên cho Device
        // Chú ý: Hàm _colorFor và _iconFor đang nhận String '0'/'1', nên giữ nguyên logic này
        final level = d.level == 0 ? '0' : '1';

        return _alertCard(
          leading: deviceCode,
          title: deviceName,
          subtitle: _fmt.format(faultTime),
          level: level,
          onTap: () => _showConfirmDialog(d), // Cho phép xác nhận
        );
      },
    );
  }

  // Widget hiển thị danh sách chung
  Widget _alertList({
    required Future<void> Function() onRefresh,
    required ScrollController controller,
    required int dataLen,
    required bool loading,
    required bool canLoadMore,
    required Widget Function(int) itemBuilder,
  }) {
    // ⚡️ Hiển thị thông báo "Không có dữ liệu"
    if (dataLen == 0 && !loading) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            const Center(
              child: Text(
                'Không có cảnh báo nào trong mục này.',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        controller: controller,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        // Thêm 1 item cho indicator load more nếu còn dữ liệu
        itemCount: dataLen + ((loading && canLoadMore) ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, idx) {
          if (idx >= dataLen) {
            if (loading && canLoadMore) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return const SizedBox.shrink();
          }
          return itemBuilder(idx);
        },
      ),
    );
  }

  Widget _alertCard({
    required String leading,
    required String title,
    required String subtitle,
    required String level,
    VoidCallback? onTap,
  }) =>
      InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _colorFor(level).withOpacity(.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(_iconFor(level), color: _colorFor(level)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _colorFor(level).withOpacity(.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(level == '0' ? 'Thấp' : 'Cao', // Hiển thị mức độ
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _colorFor(level))),
              ),
            ],
          ),
        ),
      );
}

/// ======== Segment Widget (giữ nguyên) ========
class _TaskSegment extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _TaskSegment({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _segBtn('Chưa xử lý', 0),
          _segBtn('Đã xử lý', 1),
        ],
      ),
    );
  }

  Expanded _segBtn(String text, int idx) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.horizontal(
            left: idx == 0 ? const Radius.circular(8) : Radius.zero,
            right: idx == 1 ? const Radius.circular(8) : Radius.zero,
          ),
          onTap: () => onChanged(idx),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected == idx
                  ? const Color(0xFFDDE1EA)
                  : Colors.transparent,
              borderRadius: BorderRadius.horizontal(
                left: idx == 0 ? const Radius.circular(8) : Radius.zero,
                right: idx == 1 ? const Radius.circular(8) : Radius.zero,
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
}
