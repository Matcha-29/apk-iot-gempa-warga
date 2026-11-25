import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class NotifikasiLayarKunciPage extends StatefulWidget {
  const NotifikasiLayarKunciPage({super.key});

  @override
  State<NotifikasiLayarKunciPage> createState() =>
      _NotifikasiLayarKunciPageState();
}

class _NotifikasiLayarKunciPageState extends State<NotifikasiLayarKunciPage> {
  late DateTime _currentTime;
  Timer? _timer;
  AreaStatus? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final status = await ApiService.instance.getStatusWilayah();
      if (mounted) setState(() => _status = status);
    } catch (_) {
      // gunakan nilai default
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _handleSayaAman() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.instance.kirimRespons('AMAN');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Laporan "Saya Aman" berhasil dicatat.'),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Status dicatat: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';
    final dateStr = formatHariTanggalIndonesia(_currentTime);

    final lokasi = _status?.namaLokasi.isNotEmpty == true
        ? _status!.namaLokasi
        : 'RT 01';
    final getaran = _status?.intensityLabel ?? 'KUAT';

    return MobileFrame(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF17212B), Color(0xFF06090D)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    tooltip: 'Tutup pratinjau',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xFFEAF0F4),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeStr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    height: 1,
                    fontWeight: FontWeight.w200,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECE8),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.emergency_outlined,
                              color: Color(0xFFD83A2E),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Peringatan Dini IoT',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF667085),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'GEMPA TERDETEKSI · $lokasi',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFB42318),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Sekarang',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF667085),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Intensitas getaran $getaran. Merunduk, berlindung di bawah meja kuat, dan lindungi kepala.',
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSayaAman,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: green,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Saya Aman',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushNamed(context, '/panduan');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF1F4F6),
                                  foregroundColor: const Color(0xFF111827),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Buka Panduan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121A38),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFF93C5FD),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Informasi Pemantauan RT 01',
                            style: TextStyle(
                              color: Color(0xFF93C5FD),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Sensor Node A & Node B siaga 24 jam memantau kestabilan getaran tanah wilayah.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const Text(
                  'Notifikasi darurat tetap tampil di layar kunci\ndan membunyikan alarm peringatan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF8F9AA5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
