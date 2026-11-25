import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class GempaTerdeteksiPage extends StatefulWidget {
  const GempaTerdeteksiPage({super.key, this.status, this.apiState});

  final AreaStatus? status;
  final ApiState? apiState;

  @override
  State<GempaTerdeteksiPage> createState() => _GempaTerdeteksiPageState();
}

class _GempaTerdeteksiPageState extends State<GempaTerdeteksiPage> {
  bool _closingForSafeStatus = false;
  late DateTime _currentTime;
  Timer? _clockTimer;
  bool _isResponding = false;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _currentTime = DateTime.now());
    });
    widget.apiState?.addListener(_handleStatusChange);
  }

  void _handleStatusChange() {
    if (!(widget.apiState?.areaStatus?.isSafe ?? false) ||
        _closingForSafeStatus) {
      return;
    }
    _closingForSafeStatus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    widget.apiState?.removeListener(_handleStatusChange);
    super.dispose();
  }

  Future<void> _handleSayaAman() async {
    setState(() => _isResponding = true);
    try {
      final state = widget.apiState;
      if (state != null) {
        await state.sendResidentResponse('AMAN');
      } else {
        await ApiService.instance.kirimRespons('AMAN');
      }
    } catch (_) {
      // Abaikan error agar navigasi tetap berjalan
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
        Navigator.pushReplacementNamed(context, '/laporan-terkirim');
      }
    }
  }

  Future<void> _handleHubungiPetugas() async {
    setState(() => _isResponding = true);
    try {
      final state = widget.apiState;
      if (state != null) {
        await state.sendResidentResponse('BUTUH_BANTUAN');
      } else {
        await ApiService.instance.kirimRespons('BUTUH_BANTUAN');
      }
    } catch (_) {
      // Abaikan error agar navigasi tetap berjalan
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
        Navigator.pushReplacementNamed(context, '/bantuan-terkirim');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.status ?? widget.apiState?.areaStatus;
    final lokasi = status?.namaLokasi.isNotEmpty == true
        ? status!.namaLokasi
        : 'RT 01';
    final intensityG = double.tryParse(status?.intensity ?? '') ?? 0.0;
    final intensityLevel = intensityG >= 0.2
        ? 'KUAT'
        : (intensityG >= 0.08 ? 'SEDANG' : 'RINGAN');
    final timeStr = formatHmsTime(_currentTime);

    return MobileFrame(
      child: Container(
        color: const Color(0xFFB42318),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            lokasi,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Terdeteksi $timeStr',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 66,
                            height: 66,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_amber_rounded,
                              color: Color(0xFFB42318),
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GEMPA TERDETEKSI!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Intensitas getaran',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intensityLevel,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Terkonfirmasi di wilayah Anda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 24,
                            height: 3,
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/panduan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF111827),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Buka Panduan Evakuasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed: _isResponding
                                    ? null
                                    : _handleHubungiPetugas,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(
                                    color: Colors.white70,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Hubungi Petugas',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton(
                                onPressed:
                                    _isResponding ? null : _handleSayaAman,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.12),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isResponding
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Saya Aman',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Lakukan sekarang',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _actionItem(
                              '1',
                              'Lindungi kepala',
                              'Jongkok dan berlindung di bawah meja yang kuat.',
                            ),
                            _actionItem(
                              '2',
                              'Jauhi kaca dan benda jatuh',
                              'Hindari jendela, lemari, dan rak tinggi.',
                            ),
                            _actionItem(
                              '3',
                              'Keluar setelah guncangan berhenti',
                              'Menuju tempat terbuka. Jangan gunakan lift.',
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

  Widget _actionItem(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Color(0xFFB42318),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
