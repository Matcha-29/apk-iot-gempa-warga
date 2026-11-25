import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class BantuanTerkirimPage extends StatefulWidget {
  const BantuanTerkirimPage({super.key});

  @override
  State<BantuanTerkirimPage> createState() => _BantuanTerkirimPageState();
}

class _BantuanTerkirimPageState extends State<BantuanTerkirimPage> {
  late final String _reportTime;
  String _nomorTeleponWarga = '0812-••••-1234';
  String _nomorPetugas = '08123456789';
  bool _isSwitchingToSafe = false;

  @override
  void initState() {
    super.initState();
    _reportTime = formatHmsTime(DateTime.now());
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await ApiService.instance.getSessionUser();
    if (mounted && user != null) {
      final phone = user['no_telepon']?.toString() ?? '';
      if (phone.length >= 8) {
        setState(() {
          _nomorTeleponWarga =
              '${phone.substring(0, 4)}-••••-${phone.substring(phone.length - 4)}';
        });
      }
    }
    try {
      final status = await ApiService.instance.getStatusWilayah();
      if (mounted && status.noTeleponPetugas.isNotEmpty) {
        setState(() => _nomorPetugas = status.noTeleponPetugas);
      }
    } catch (_) {}
  }

  Future<void> _callOfficer() async {
    final clean = _nomorPetugas.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomor Petugas: $_nomorPetugas'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleAlreadySafe() async {
    setState(() => _isSwitchingToSafe = true);
    try {
      await ApiService.instance.kirimRespons('AMAN');
    } catch (_) {}
    if (mounted) {
      setState(() => _isSwitchingToSafe = false);
      Navigator.pushReplacementNamed(context, '/laporan-terkirim');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF111827),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'RT 01',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: Color(0xFFB42318),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Permintaan Bantuan\nTerkirim',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Petugas RT 01 sudah menerima laporan Anda dan akan segera menghubungi. Tetap di tempat yang aman.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF4B5563),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    _statusRow(
                      'Status',
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Butuh bantuan',
                          style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _statusRow(
                      'Waktu lapor',
                      Text(
                        _reportTime,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _statusRow(
                      'Lokasi',
                      const Text(
                        'Titik GPS terkirim ±15 m',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _statusRow(
                      'Petugas menelepon ke',
                      Text(
                        _nomorTeleponWarga,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Sambil menunggu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hemat baterai ponsel. Jika terjebak, ketuk pipa atau dinding agar terdengar.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _callOfficer,
                  icon: const Icon(Icons.phone, size: 20),
                  label: const Text(
                    'Telepon Petugas Sekarang',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB42318),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
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
                        onPressed: () =>
                            Navigator.pushNamed(context, '/panduan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111827),
                          side: const BorderSide(
                            color: Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Panduan Evakuasi',
                            style: TextStyle(
                              fontSize: 14,
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
                            _isSwitchingToSafe ? null : _handleAlreadySafe,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111827),
                          side: const BorderSide(
                            color: Color(0xFFD1D5DB),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSwitchingToSafe
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'Saya Sudah Aman',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
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
      ),
    );
  }

  Widget _statusRow(String label, Widget right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        right,
      ],
    );
  }
}
