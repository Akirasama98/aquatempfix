import 'package:flutter/material.dart';
import '../controller/mqtt_controller.dart';

class MqttStatusPage extends StatefulWidget {
  final MqttController controller;
  const MqttStatusPage({super.key, required this.controller});

  @override
  State<MqttStatusPage> createState() => _MqttStatusPageState();
}

class _MqttStatusPageState extends State<MqttStatusPage> {
  String statusMessage = 'Belum terhubung ke MQTT...';
  String currentTemp = '26';
  bool iotStatus = true;
  bool heaterStatus = false;
  bool pompaStatus = false;
  String minTemp = '24';
  String maxTemp = '32';
  String currentMode = 'auto';
  bool isConnected = false;
  bool isToggleLoading = false; // Untuk indikator loading toggle
  @override
  void initState() {
    super.initState();
    widget.controller.onStatusUpdate = (msg) {
      print('onStatusUpdate callback dipanggil dengan: "$msg"');
      if (mounted) {
        setState(() {
          isConnected = true;
          _parseArduinoData(msg);
        });
        print('setState dipanggil, iotStatus sekarang: $iotStatus');
      } else {
        print('Widget sudah tidak mounted, skip setState');
      }
    };
    widget.controller.connect();
  }
  void _parseArduinoData(String msg) {
    print('=== PARSING MQTT MESSAGE ===');
    print('Pesan lengkap: "$msg"');
    
    // Parse data dari Arduino
    // Format pesan bisa berupa: "Suhu: 26.5 C, Heater: ON, Pompa: OFF, Mode: auto, Min: 24, Max: 32"

    // Parse suhu
    final tempRegex = RegExp(r'Suhu:\s*([\d.]+)\s*C');
    final tempMatch = tempRegex.firstMatch(msg);
    if (tempMatch != null) {
      String oldTemp = currentTemp;
      currentTemp = tempMatch.group(1) ?? currentTemp;
      print('Suhu: $oldTemp -> $currentTemp');
    }

    // Parse status heater
    if (msg.contains('Heater: ON')) {
      heaterStatus = true;
      print('Heater: ON');
    } else if (msg.contains('Heater: OFF')) {
      heaterStatus = false;
      print('Heater: OFF');
    }

    // Parse status pompa
    if (msg.contains('Pompa: ON')) {
      pompaStatus = true;
      print('Pompa: ON');
    } else if (msg.contains('Pompa: OFF')) {
      pompaStatus = false;
      print('Pompa: OFF');
    }

    // Parse mode dengan logging detail
    bool oldIotStatus = iotStatus;
    String oldMode = currentMode;
    
    if (msg.toLowerCase().contains('mode: auto')) {
      currentMode = 'auto';
      iotStatus = true;
      print('Mode detected: auto -> iotStatus = true');
    } else if (msg.toLowerCase().contains('mode: off')) {
      currentMode = 'off';
      iotStatus = false;
      print('Mode detected: off -> iotStatus = false');
    } else if (msg.toLowerCase().contains('mode: manual')) {
      currentMode = 'manual';
      iotStatus = false;
      print('Mode detected: manual -> iotStatus = false');
    }
    
    if (oldMode != currentMode) {
      print('Mode berubah: $oldMode -> $currentMode');
    }
      if (oldIotStatus != iotStatus) {
      print('IoT Status berubah: $oldIotStatus -> $iotStatus');
      print('UI akan update toggle ke: ${iotStatus ? "ON" : "OFF"}');
      // Reset loading state karena update berhasil dari MQTT
      isToggleLoading = false;
    }

    // Parse suhu minimum
    final minRegex = RegExp(r'Min:\s*([\d.]+)');
    final minMatch = minRegex.firstMatch(msg);
    if (minMatch != null) {
      String oldMin = minTemp;
      minTemp = minMatch.group(1) ?? minTemp;
      if (oldMin != minTemp) {
        print('Min temp: $oldMin -> $minTemp');
      }
    }

    // Parse suhu maksimum
    final maxRegex = RegExp(r'Max:\s*([\d.]+)');
    final maxMatch = maxRegex.firstMatch(msg);
    if (maxMatch != null) {
      String oldMax = maxTemp;
      maxTemp = maxMatch.group(1) ?? maxTemp;
      if (oldMax != maxTemp) {
        print('Max temp: $oldMax -> $maxTemp');
      }
    }

    // Update status message
    statusMessage = 'Suhu: $currentTemp °C';
    print('=== END PARSING ===');
  }

  String _getTemperatureStatus() {
    final temp = double.tryParse(currentTemp) ?? 26.0;
    final min = double.tryParse(minTemp) ?? 24.0;
    final max = double.tryParse(maxTemp) ?? 32.0;

    if (temp < min) {
      return 'Dingin';
    } else if (temp > max) {
      return 'Panas';
    } else {
      return 'Normal';
    }
  }

  Color _getTemperatureColor() {
    final temp = double.tryParse(currentTemp) ?? 26.0;
    final min = double.tryParse(minTemp) ?? 24.0;
    final max = double.tryParse(maxTemp) ?? 32.0;

    if (temp < min) {
      return Colors.blue;
    } else if (temp > max) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header dengan logo
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.set_meal,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'AQUATEMP',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Main content cards
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Card suhu air
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Suhu Air',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentTemp,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Text(
                                  '°C',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getTemperatureColor(),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getTemperatureStatus(),
                                  style: TextStyle(
                                    color: _getTemperatureColor(),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                if (!isConnected)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.wifi_off,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Offline',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Online',
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Wave decoration
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF42A5F5),
                                    Color(0xFF1976D2),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Card IoT Toggle Saja
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.router,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'IoT System',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),                            GestureDetector(
                              onTap: isToggleLoading ? null : () {
                                // Simpan status lama untuk rollback jika gagal
                                bool previousStatus = iotStatus;
                                
                                // Set loading state
                                setState(() {
                                  isToggleLoading = true;
                                  iotStatus = !iotStatus;
                                });
                                
                                // Kirim perintah ke MQTT
                                String command = iotStatus ? 'mode auto' : 'mode off';
                                print('User toggle IoT: ${!iotStatus} -> $iotStatus, kirim: $command');
                                
                                try {
                                  widget.controller.sendControl(command);
                                    // Timeout setelah 10 detik jika tidak ada response
                                  Future.delayed(const Duration(seconds: 10), () {
                                    if (mounted && isToggleLoading) {
                                      print('Timeout: tidak ada response setelah 10 detik, rollback UI');
                                      setState(() {
                                        iotStatus = previousStatus;
                                        isToggleLoading = false;
                                      });
                                    }
                                  });
                                } catch (e) {
                                  print('Error saat kirim toggle: $e');
                                  // Rollback jika error
                                  if (mounted) {
                                    setState(() {
                                      iotStatus = previousStatus;
                                      isToggleLoading = false;
                                    });
                                  }                                }
                              },
                              child: Opacity(
                                opacity: isToggleLoading ? 0.6 : 1.0,
                                child: Container(
                                  width: 60,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: iotStatus
                                        ? Colors.green
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: AnimatedAlign(
                                    duration: const Duration(milliseconds: 200),
                                    alignment: iotStatus
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      margin: const EdgeInsets.all(2),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: isToggleLoading 
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  Colors.grey,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              iotStatus ? 'ON' : 'OFF',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Batas Suhu section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.thermostat,
                                  color: Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Batas Suhu',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 80,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1976D2),
                                    Color(0xFF7B1FA2),
                                    Color(0xFFD32F2F),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'MIN',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                minTemp,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Text(
                                                '°C',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 40,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  Expanded(
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'MAX',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                maxTemp,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const Text(
                                                '°C',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // JANGAN dispose controller MQTT karena digunakan di halaman lain
    // widget.controller.dispose();
    super.dispose();
  }
}
