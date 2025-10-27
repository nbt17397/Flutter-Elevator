import 'package:dio/dio.dart';
import 'package:elevator/app/data/response/notification_response.dart';

import '../base_client.dart';

class NotificationRepo extends ApiProvider {
  Future<List<NotificationDB>> getNotificationByLocationId(
      {required int locationId, required int page}) async {
    try {
      final Response response = await httpClient
          .get('locations/$locationId/notifications/?page=$page');
      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => NotificationDB.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to load location users. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Failed to get location users: ${e.message}');
    }
  }

  Future<NotificationDB> updateNotificationConfirmStatus({
    required int notificationId,
    required bool isConfirmStatus,
  }) async {
    try {
      // Giả định sử dụng PATCH hoặc PUT để cập nhật một phần/toàn bộ tài nguyên
      final Response response = await httpClient.patch(
        'notifications/$notificationId/', // Giả định endpoint
        data: {
          'is_confirm': isConfirmStatus,
          // Có thể thêm 'confirm_by' hoặc 'confirm_time' nếu API yêu cầu
        },
      );

      if (response.statusCode == 200) {
        // Trả về đối tượng NotificationDB đã được cập nhật từ phản hồi
        return NotificationDB.fromJson(response.data);
      } else {
        throw Exception(
            'Failed to update notification status. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Xử lý lỗi chi tiết hơn nếu cần
      throw Exception('Failed to update notification: ${e.message}');
    }
  }
}
