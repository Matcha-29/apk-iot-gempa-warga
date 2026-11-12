import 'package:flutter/material.dart' hide Badge;

import '../widgets/common_widgets.dart';

class PermissionsPage extends StatelessWidget {
  const PermissionsPage({super.key});
  @override
  Widget build(BuildContext context) => MobileFrame(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LANGKAH TERAKHIR',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Izin yang dibutuhkan',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Agar peringatan sampai tepat waktu dan petugas bisa membantu Anda.',
            style: TextStyle(fontSize: 10, height: 1.35),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBF5),
              border: Border.all(color: green, width: 1.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_none, size: 22, color: green),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Notifikasi darurat',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Badge('Wajib', Color(0xFFB91C1C)),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Peringatan gempa akan berbunyi keras dan menyatakan layar, bahkan saat ponsel dalam mode senyap.',
                  style: TextStyle(fontSize: 8.5, height: 1.35),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryCompact(
                    'Aktifkan Notifikasi',
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/lock-notification',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F9FC),
              border: Border.all(color: Color(0xFFD7DCE4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 21, color: blue),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Lokasi saat melapor',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Badge('Opsional', blue),
                  ],
                ),
                SizedBox(height: 10),
                Check(
                  'Hanya diambil saat Anda menekan Saya Aman atau Hubungi Petugas.',
                ),
                Check('Tidak dilacak terus-menerus.'),
                Check(
                  'Tanpa izin ini, laporan tetap berkirim tanpa titik lokasi.',
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlineCompact('Izinkan Lokasi'),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Center(
            child: Text(
              'Lewati lokasi untuk sekarang',
              style: TextStyle(fontSize: 8.5),
            ),
          ),
        ],
      ),
    ),
  );
}
