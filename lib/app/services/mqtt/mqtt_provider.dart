import 'package:flutter/material.dart';
import 'mqtt_service.dart';

class MqttProvider with ChangeNotifier {
  final MqttService mqttService;
  bool isConnected = false;
  final Map<String, String> _messages = {};

  Map<String, String> get messages => _messages;

  MqttProvider(this.mqttService) {
    _initMqtt(); // Gọi connect khi Provider được khởi tạo
  }

  Future<void> _initMqtt() async {
    isConnected = await mqttService.connect(onMessageReceived);
    notifyListeners(); // Cập nhật giao diện nếu cần
  }

  void subscribeTopic(String topic) {
    mqttService.subscribe(topic);
  }

  void unsubscribeTopic(String topic) {
    mqttService.unsubscribe(topic);
  }

  void onMessageReceived(String topic, String payload) {
    _messages[topic] = payload;
    notifyListeners();
  }

  void publishMessage(String topic, String message) {
    mqttService.publish(topic, message);
  }
}
