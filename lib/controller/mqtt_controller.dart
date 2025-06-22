import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import '../model/mqtt_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MqttController {
  final MqttModel model;
  Function(String)? onStatusUpdate;

  MqttController(this.model);

  Future<void> connect() async {
    model.client.onDisconnected = _onDisconnected;
    model.client.onConnected = _onConnected;
    model.client.onSubscribed = _onSubscribed;
    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs(model.username, model.password)
        .startClean();
    model.client.connectionMessage = connMess;
    try {
      await model.client.connect();
    } catch (e) {
      onStatusUpdate?.call('Gagal konek: $e');
      model.client.disconnect();
      // Coba reconnect otomatis setelah 5 detik jika gagal
      Future.delayed(const Duration(seconds: 5), connect);
      return;
    }
    model.client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );
      // Simpan histori jika mengandung info durasi
      if (pt.contains('Durasi Heater') && pt.contains('Durasi Pompa')) {
        model.history.add('${DateTime.now().toString().substring(0, 19)}: $pt');
        // Ambil durasi heater & pompa dari string
        final regex = RegExp(r'Durasi Heater: (\d+)s, Durasi Pompa: (\d+)s');
        final match = regex.firstMatch(pt);
        if (match != null) {
          final durasiHeater = int.tryParse(match.group(1) ?? '0') ?? 0;
          final durasiPompa = int.tryParse(match.group(2) ?? '0') ?? 0;
          insertRiwayatToSupabase(durasiHeater, durasiPompa);
        }
        if (model.history.length > 50) {
          model.history.removeAt(0); // Batasi histori max 50 entri
        }
      }
      onStatusUpdate?.call(pt);
    });
    model.client.subscribe(model.topicStatus, MqttQos.atMostOnce);
  }

  void sendControl(String message) {
    print('Mencoba kirim pesan: $message');
    print('Status koneksi: ${model.client.connectionStatus?.state}');

    if (model.client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);

      try {
        model.client.publishMessage(
          model.topicControl,
          MqttQos.atMostOnce,
          builder.payload!,
        );
        print('Pesan berhasil dipublish ke topik: ${model.topicControl}');
        onStatusUpdate?.call('Pesan terkirim: $message');
      } catch (e) {
        print('Error saat publish: $e');
        onStatusUpdate?.call('Gagal kirim pesan: $e');
      }
    } else {
      print(
        'MQTT belum connected, status: ${model.client.connectionStatus?.state}',
      );
      onStatusUpdate?.call('MQTT belum terhubung, tidak bisa kirim pesan');
    }
  }

  void _onConnected() {
    onStatusUpdate?.call('Terhubung ke MQTT, menunggu data...');
  }

  void _onDisconnected() {
    onStatusUpdate?.call('Terputus dari MQTT. Mencoba reconnect...');
    // Coba reconnect otomatis setelah 5 detik
    Future.delayed(const Duration(seconds: 5), connect);
  }

  void _onSubscribed(String topic) {
    onStatusUpdate?.call('Subscribed ke $topic, menunggu data...');
  }

  Future<void> insertRiwayatToSupabase(
    int durasiHeater,
    int durasiPompa,
  ) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('riwayat').insert({
      'user_id': user.id,
      'durasi_heater': durasiHeater,
      'durasi_pompa': durasiPompa,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  void dispose() {
    model.client.disconnect();
  }
}
