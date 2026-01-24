import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/user_model.dart';

class MqttService {
  final String broker = "mqtt-elevator.haophuong.com";
  final int port = 2001;
  final String clientId = const Uuid().v4().substring(0, 8);

  MqttServerClient? client;
  bool _isConnected = false;
  Timer? _reconnectTimer;

  Future<bool> connect(Function(String, String) onMessageReceived, {VoidCallback? onConnected}) async {
    // 1. Khởi tạo client cục bộ để đảm bảo an toàn thread
    final currentClient = MqttServerClient(broker, clientId);
    currentClient.port = port;
    currentClient.logging(on: false); // Tắt bớt log nếu không cần thiết
    currentClient.secure = false;
    currentClient.useWebSocket = false;
    currentClient.keepAlivePeriod = 60;
    currentClient.autoReconnect =
        false; // Tự xử lý reconnect bằng Timer bên dưới

    currentClient.onConnected = () {
      print("✅ MQTT Connected: $clientId");
      _isConnected = true;
      if (onConnected != null) onConnected();
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    };

    currentClient.onDisconnected = () {
      print("❌ MQTT Disconnected!");
      _isConnected = false;
      _attemptReconnect(onMessageReceived);
    };

    try {
      client = currentClient; // Gán vào biến global sau khi cấu hình
      await currentClient.connect();

      if (currentClient.connectionStatus?.state ==
          MqttConnectionState.connected) {
        // 2. Xử lý Hive an toàn
        if (Hive.isBoxOpen('userModel')) {
          var userBox = Hive.box<UserModel>('userModel');
          if (userBox.isNotEmpty) {
            final userModel = userBox.getAt(0);
            if (userModel != null &&
                userModel.isSuperuser &&
                (userModel.isAlarm ?? false)) {
              currentClient.subscribe('aquabox/alarm/get', MqttQos.atLeastOnce);
            }
          }
        }

        // 3. Đăng ký listener an toàn
        currentClient.updates
            ?.listen((List<MqttReceivedMessage<MqttMessage?>>? messages) {
          if (messages == null || messages.isEmpty) return;

          final MqttPublishMessage recMess =
              messages[0].payload as MqttPublishMessage;
          final String topic = messages[0].topic;
          final String payload =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          onMessageReceived(topic, payload);
        });

        return true;
      }
    } catch (e) {
      print("⚠️ MQTT Connection Error: $e");
      _attemptReconnect(onMessageReceived);
    }
    return false;
  }

  void _attemptReconnect(Function(String, String) onMessageReceived) {
    if (_reconnectTimer != null) return;

    _reconnectTimer =
        Timer.periodic(const Duration(seconds: 15), (timer) async {
      if (!_isConnected) {
        print("🔄 Reconnecting MQTT...");
        await connect(onMessageReceived);
      } else {
        timer.cancel();
        _reconnectTimer = null;
      }
    });
  }

  void subscribe(String topic) {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client?.subscribe(topic, MqttQos.atLeastOnce);
    }
  }

  void unsubscribe(String topic) {
    if (client?.connectionStatus?.state == MqttConnectionState.connected) {
      client?.unsubscribe(topic, expectAcknowledge: true);
    }
  }

  void publish(String topic, String message) {
    final c = client; // Tạo bản sao local để check null
    if (c != null &&
        c.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      c.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
          retain: true);
    }
  }
}