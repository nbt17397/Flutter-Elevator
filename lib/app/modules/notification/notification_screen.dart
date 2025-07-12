// lib/screens/notification_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../components/app_background.dart';

/* =================================================================== */
/*  MODELS                                                             */
/* =================================================================== */
enum NoticeType { taskAssigned, taskLate, deviceError }

class NotificationItem {
  final int id;
  final String title;
  final String message;
  final DateTime time;
  final NoticeType type;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
  });
}

/* =================================================================== */
/*  MAIN SCREEN                                                        */
/* =================================================================== */
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _items = [];
  final ScrollController _scrollCtrl = ScrollController();

  /* paging giả lập --------------------------------------------------- */
  bool _isLoadingMore = false;
  static const int _pageSize = 20;
  static const int _maxItems = 100;

  /* ------------------------------------------------------------------ */
  @override
  void initState() {
    super.initState();
    _generateFakeData(0, _pageSize);
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  /* ---- helpers ----------------------------------------------------- */
  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _items.length < _maxItems) {
      _loadMore();
    }
  }

  void _loadMore() {
    setState(() => _isLoadingMore = true);

    // Giả lập call API 1s
    Future.delayed(const Duration(seconds: 1), () {
      final start = _items.length;
      final count = (_items.length + _pageSize) > _maxItems
          ? _maxItems - _items.length
          : _pageSize;
      _generateFakeData(start, count);
      setState(() => _isLoadingMore = false);
    });
  }

  void _generateFakeData(int start, int count) {
    final now = DateTime.now();
    for (int i = 0; i < count; i++) {
      final id = start + i;
      final type = NoticeType.values[id % NoticeType.values.length];
      _items.add(
        NotificationItem(
          id: id,
          title: switch (type) {
            NoticeType.taskAssigned => 'Công việc mới được giao',
            NoticeType.taskLate => 'Công việc trễ tiến độ',
            NoticeType.deviceError => 'Thiết bị gặp sự cố',
          },
          message: 'Mã #${1000 + id} – kiểm tra chi tiết...',
          time: now.subtract(Duration(minutes: id * 5)),
          type: type,
        ),
      );
    }
  }

  IconData _iconFor(NoticeType t) => switch (t) {
        NoticeType.taskAssigned => Icons.assignment_turned_in,
        NoticeType.taskLate => Icons.schedule,
        NoticeType.deviceError => Icons.build
      };

  Color _colorFor(NoticeType t) => switch (t) {
        NoticeType.taskAssigned => Colors.blue.shade600,
        NoticeType.taskLate => Colors.orange.shade700,
        NoticeType.deviceError => Colors.red.shade600
      };

  /* ---- UI ---------------------------------------------------------- */
  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _items.clear();
              _generateFakeData(0, _pageSize);
            });
          },
          child: ListView.separated(
            controller: _scrollCtrl,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 30, left: 12, right: 12),
            itemCount: _items.length + (_isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              /* ô loading cuối danh sách -------------------------------- */
              if (index >= _items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              }

              final n = _items[index];

              return _NotificationTile(
                n: n,
                icon: _iconFor(n.type),
                iconColor: _colorFor(n.type),
              );
            },
          ),
        ),
      ),
    );
  }
}

/* =================================================================== */
/*  SINGLE TILE WIDGET                                                 */
/* =================================================================== */
class _NotificationTile extends StatelessWidget {
  final NotificationItem n;
  final IconData icon;
  final Color iconColor;

  const _NotificationTile({
    required this.n,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* ------------ HÌNH VUÔNG --------------------------------- */
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 65,
                height: 65,
                color: Colors.blue.shade50,
                alignment: Alignment.center,
                child: Icon(icon, size: 32, color: iconColor),
              ),
            ),

            /* ------------ DIVIDER DỌC (không có nút tròn) ------------- */
            Container(
              width: 1,
              height: 65,                               // cao bằng hình
              margin: const EdgeInsets.symmetric(horizontal: 12),
              color: Colors.black12,
            ),

            /* ------------ THÔNG TIN ---------------------------------- */
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(n.message,
                      style:
                          const TextStyle(fontSize: 13, color: Colors.black54)),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(n.time),
                    style:
                        TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* util -------------------------------------------------------------- */
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
