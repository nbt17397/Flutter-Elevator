import 'dart:convert';

import 'package:flutter/material.dart';
import 'mqtt_service.dart';

class MqttProvider with ChangeNotifier {
  final MqttService mqttService;
  bool isConnected = false;
  final Set<String> _subscribedTopics = {};
  final Map<String, String> _messages = {};

  Map<String, String> get messages => _messages;

  MqttProvider(this.mqttService) {
    _initMqtt();
  }

  Future<void> _initMqtt() async {
    isConnected = await mqttService.connect(onMessageReceived, onConnected: _onConnectedCallback);
    
    notifyListeners();
  }

  void _onConnectedCallback() {
    isConnected = true;
    // TỰ ĐỘNG SUBSCRIBE LẠI TẤT CẢ TOPIC TRONG QUEUE KHI CÓ MẠNG
    for (var topic in _subscribedTopics) {
      mqttService.subscribe(topic);
      print("🚀 Auto Re-subscribed to: $topic");
    }
    notifyListeners();
  }

  void subscribeTopic(String topic) {
    _subscribedTopics.add(topic); // Lưu vào danh sách quản lý
    if (isConnected) {
      mqttService.subscribe(topic);
    }
  }

  void unsubscribeTopic(String topic) {
    mqttService.unsubscribe(topic);
  }

  void onMessageReceived(String topic, String payload) {
    try {
      final Map<String, dynamic> data = jsonDecode(payload);
      _messages[topic] = data['status'].toString();
    } catch (e) {
      _messages[topic] = payload;
    }
    notifyListeners();
  }

  void publishMessage(String topic, String message) {
    mqttService.publish(topic, message);
  }
}
