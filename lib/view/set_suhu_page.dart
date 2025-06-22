import 'package:flutter/material.dart';
import '../controller/mqtt_controller.dart';

class SetSuhuPage extends StatefulWidget {
  final MqttController controller;
  const SetSuhuPage({super.key, required this.controller});

  @override
  State<SetSuhuPage> createState() => _SetSuhuPageState();
}

class _SetSuhuPageState extends State<SetSuhuPage> {
  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  bool isLoadingMin = false;
  bool isLoadingMax = false;
  String successMessageMin = '';
  String successMessageMax = '';

  void saveMinTemperature() async {
    final min = minController.text.trim();

    if (min.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi suhu minimum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi nilai
    final minValue = double.tryParse(min);

    if (minValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan angka yang valid untuk suhu minimum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi dengan suhu maksimum jika ada
    if (maxController.text.isNotEmpty) {
      final maxValue = double.tryParse(maxController.text);
      if (maxValue != null && minValue >= maxValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suhu minimum harus lebih kecil dari maksimum'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoadingMin = true;
    });

    try {
      // Kirim perintah set min
      widget.controller.sendControl('set min $min.text');

      if (!mounted) return;

      setState(() {
        isLoadingMin = false;
        successMessageMin = 'Suhu minimum berhasil diperbarui!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suhu minimum berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            successMessageMin = '';
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingMin = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui suhu minimum'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void saveMaxTemperature() async {
    final max = maxController.text.trim();

    if (max.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi suhu maksimum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi nilai
    final maxValue = double.tryParse(max);

    if (maxValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan angka yang valid untuk suhu maksimum'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validasi dengan suhu minimum jika ada
    if (minController.text.isNotEmpty) {
      final minValue = double.tryParse(minController.text);
      if (minValue != null && maxValue <= minValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Suhu maksimum harus lebih besar dari minimum'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      isLoadingMax = true;
    });

    try {
      // Kirim perintah set max
      widget.controller.sendControl('set max $max');

      if (!mounted) return;

      setState(() {
        isLoadingMax = false;
        successMessageMax = 'Suhu maksimum berhasil diperbarui!';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Suhu maksimum berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear success message after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            successMessageMax = '';
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoadingMax = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui suhu maksimum'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    // JANGAN dispose controller MQTT karena digunakan di halaman lain
    // widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Update Batas Suhu',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Update Batas Suhu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Suhu Minimum
                  const Text(
                    'Suhu Minimum (°C)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: minController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan suhu minimum',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Simpan Minimum
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoadingMin ? null : saveMinTemperature,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: isLoadingMin
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Simpan Suhu Minimum',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  // Success Message Min
                  if (successMessageMin.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                successMessageMin,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Suhu Maksimum
                  const Text(
                    'Suhu Maksimum (°C)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: maxController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Masukkan suhu maksimum',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        suffixIcon: Icon(
                          Icons.edit,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tombol Simpan Maksimum
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoadingMax ? null : saveMaxTemperature,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: isLoadingMax
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Simpan Suhu Maksimum',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),

                  // Success Message Max
                  if (successMessageMax.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                successMessageMax,
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
    );
  }
}
