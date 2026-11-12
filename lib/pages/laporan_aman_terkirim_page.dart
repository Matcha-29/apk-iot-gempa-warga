import 'package:flutter/material.dart';

import '../widgets/api_response_action.dart';
import '../widgets/common_widgets.dart';

class LaporanAmanTerkirimPage extends StatelessWidget {
  const LaporanAmanTerkirimPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 18),
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Laporan Terkirim',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Terima kasih, petugas sudah menerima kabar bahwa Anda dalam keadaan aman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF55615A),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _status('Status', 'Aman'),
                  _status('Lokasi', 'RT 01 · titik GPS terkirim'),
                  _status('Waktu lapor', '10:52:41'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 28,
                    color: Color(0xFFB7791F),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tetap waspada terhadap gempa susulan. Jauhi bangunan yang retak.',
                      style: TextStyle(fontSize: 15, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/panduan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF252525),
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Buka Panduan Evakuasi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/beranda',
                  (route) => false,
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ApiResponseAction(
              status: 'butuh_bantuan',
              route: '/bantuan-terkirim',
              builder: (context, loading, onPressed) => TextButton(
                onPressed: onPressed,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Saya sebenarnya butuh bantuan',
                        style: TextStyle(
                          color: Color(0xFFB42318),
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15, color: Color(0xFF55615A)),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
