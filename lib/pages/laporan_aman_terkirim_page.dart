import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class LaporanAmanTerkirimPage extends StatefulWidget {
  const LaporanAmanTerkirimPage({super.key});

  @override
  State<LaporanAmanTerkirimPage> createState() => _LaporanAmanTerkirimPageState();
}

class _LaporanAmanTerkirimPageState extends State<LaporanAmanTerkirimPage> {
  late final String _reportTime;
  bool _isSwitchingToHelp = false;

  @override
  void initState() {
    super.initState();
    _reportTime = formatHmsTime(DateTime.now());
  }

  Future<void> _handleNeedHelp() async {
    setState(() => _isSwitchingToHelp = true);
    try {
      await ApiService.instance.kirimRespons('BUTUH_BANTUAN');
    } catch (_) {}
    if (mounted) {
      setState(() => _isSwitchingToHelp = false);
      Navigator.pushReplacementNamed(context, '/bantuan-terkirim');
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
                  color: Color(0xFF15803D),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Laporan Terkirim',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Terima kasih. Petugas sudah menerima kabar bahwa Anda dalam keadaan aman.',
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
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Aman',
                          style: TextStyle(
                            color: Color(0xFF166534),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                    _statusRow(
                      'Lokasi',
                      const Text(
                        'RT 01 · titik GPS terkirim',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
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
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 22,
                      color: Color(0xFFD97706),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tetap waspada terhadap gempa susulan. Jauhi bangunan yang retak.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/panduan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1F2937),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Buka Panduan Evakuasi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/beranda',
                    (route) => false,
                  ),
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
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isSwitchingToHelp ? null : _handleNeedHelp,
                child: _isSwitchingToHelp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Saya sebenarnya butuh bantuan',
                        style: TextStyle(
                          color: Color(0xFFB42318),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
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
