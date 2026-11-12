import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class KembaliAmanPage extends StatelessWidget {
  const KembaliAmanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF06725A),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined, color: Colors.white, size: 30),
                  SizedBox(height: 12),
                  Text(
                    'Situasi Sudah\nTerkendali',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Petugas menyatakan RT 01 kembali aman. Tetap waspada terhadap gempa susulan.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _status('Ringkasan kejadian', '10:47–10:58'),
                  _status('Intensitas gempa', 'Kuat'),
                  _status('Laporan Anda', 'Aman · 10:52'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Setelah gempa',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 9),
            _check('Periksa listrik dan gas. Matikan jika ada kebocoran.'),
            _check('Cek retakan di dinding dan atap sebelum masuk kembali.'),
            _check('Bantu tetangga yang lansia atau anak-anak.'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/panduan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Panduan Setelah Gempa',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/beranda',
                  (route) => false,
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF111827),
                  side: const BorderSide(color: Color(0xFF9CA3AF)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Kembali ke Beranda',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 9.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _status(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 8.5))),
        Text(
          value,
          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
  Widget _check(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, size: 13, color: green),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 8.5, height: 1.25),
          ),
        ),
      ],
    ),
  );
}
