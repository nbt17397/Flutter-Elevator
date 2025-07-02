import 'dart:async';
import 'package:flutter/material.dart';

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

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _items = [];
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoadingMore = false;
  static const int _pageSize = 20;
  static const int _maxItems = 100;

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

  /* ---- helpers ---------------------------------------------------------- */

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
    // giả lập call API
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

  /* ---- UI ---------------------------------------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            if (index >= _items.length) {
              // ô loading cuối danh sách
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ));
            }
            final n = _items[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_iconFor(n.type), size: 28, color: _colorFor(n.type)),
                  const SizedBox(width: 12),
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
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black54)),
                        const SizedBox(height: 4),
                        Text(
                          _timeAgo(n.time),
                          style: TextStyle(
                              fontSize: 12, color: Colors.blueGrey.shade400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }
}
