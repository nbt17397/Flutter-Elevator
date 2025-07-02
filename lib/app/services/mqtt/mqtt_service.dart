import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  final String broker =
      "mqtt-elevator.haophuong.com"; // Thay bằng broker của bạn
  final int port = 2001;
  final String clientId =
      const Uuid().v4().substring(0, 8); // Tạo clientId ngẫu nhiên
  MqttServerClient? client;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  Future<bool> connect(Function(String, String) onMessageReceived) async {
    client = MqttServerClient(broker, clientId);
    client!.port = port;
    client!.logging(on: true);
    client!.secure = true;
    client!.useWebSocket = false;
    client!.keepAlivePeriod = 60;

    client!.onConnected = () {
      print("✅ Kết nối MQTT thành công với clientId: $clientId");
      _isConnected = true;
      _reconnectTimer?.cancel(); // Dừng reconnect nếu đã kết nối thành công
    };

    client!.onDisconnected = () {
      print("❌ Mất kết nối MQTT! Đang thử kết nối lại...");
      _isConnected = false;
      _attemptReconnect(onMessageReceived);
    };

    try {
      await client!.connect();
      if (client!.connectionStatus?.state == MqttConnectionState.connected) {
        print("✅ Đã kết nối MQTT");

        // Đăng ký listener để nhận tin nhắn
        client!.updates!
            .listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
          final MqttPublishMessage recMess =
              messages![0].payload as MqttPublishMessage;
          final String topic = messages[0].topic;
          final String payload =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          print("📩 Nhận tin nhắn từ $topic: $payload");

          // Gửi tin nhắn đến listener đã đăng ký
          onMessageReceived(topic, payload);
        });

        return true;
      } else {
        print("⚠️ Kết nối MQTT thất bại");
        return false;
      }
    } catch (e) {
      print("⚠️ Lỗi kết nối MQTT: $e");
      _attemptReconnect(onMessageReceived);
      return false;
    }
  }

  void _attemptReconnect(Function(String, String) onMessageReceived) {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) return;
    _reconnectTimer = Timer.periodic(Duration(seconds: 15), (timer) {
      if (!_isConnected) {
        print("🔄 Thử kết nối lại MQTT...");
        connect(onMessageReceived);
      } else {
        timer.cancel();
      }
    });
  }

  void subscribe(String topic) {
    if (client != null &&
        client!.connectionStatus?.state == MqttConnectionState.connected) {
      client!.subscribe(topic, MqttQos.atLeastOnce);
      print("📡 Subscribed: $topic");
    } else {
      print("⚠️ Không thể subscribe, client chưa kết nối!");
    }
  }

  void unsubscribe(String topic) {
    if (client != null &&
        client!.connectionStatus?.state == MqttConnectionState.connected) {
      client!.unsubscribe(topic, expectAcknowledge: true);
      print("🚫 Unsubscribed: $topic");
    } else {
      print("⚠️ Không thể unsubscribe, client chưa kết nối!");
    }
  }

  void publish(String topic, String message) {
    if (client != null &&
        client!.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print("✅ Đã publish thành công tới topic: $topic");
      print("📨 Nội dung: $message");
    } else {
      print("⚠️ Không thể publish, client chưa kết nối!");
    }
  }
}
