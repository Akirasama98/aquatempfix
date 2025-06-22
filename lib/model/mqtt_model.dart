import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttModel {
  final String broker = '2919163bbc8f43aca4ac29f7167d2890.s1.eu.hivemq.cloud';
  final int port = 8883;
  final String username = 'aquatemp-api';
  final String password = 'AquaTemp2025!';
  final String topicStatus = 'iot/device/status';
  final String topicControl = 'iot/device/control';

  late MqttServerClient client;
  String statusMessage = 'Belum terhubung ke MQTT...';
  List<String> history = [];

  MqttModel() {
    client = MqttServerClient(broker, 'flutter_client');
    client.port = port;
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.setProtocolV311();
  }
}
