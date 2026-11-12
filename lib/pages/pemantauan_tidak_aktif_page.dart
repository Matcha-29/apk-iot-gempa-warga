import 'package:flutter/material.dart';

import '../widgets/api_response_action.dart';
import '../widgets/common_widgets.dart';

class PemantauanTidakAktifPage extends StatelessWidget {
  const PemantauanTidakAktifPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Anda',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF55615A),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'RT 01',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () =>
                            Navigator.pushNamed(context, '/lock-notification'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F7F6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.notifications_none, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9A5E00),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        SizedBox(height: 18),
                        Text(
                          'Pemantauan Tidak Aktif',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Kami belum bisa memastikan kondisi wilayah Anda. Jangan anggap aman hanya karena tidak ada peringatan.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ApiResponseAction(
                      status: 'butuh_bantuan',
                      route: '/bantuan-terkirim',
                      builder: (context, loading, onPressed) =>
                          OutlinedButton(
                            onPressed: onPressed,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111827),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Hubungi Petugas RT 01',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Yang bisa Anda lakukan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _bullet('Tetap waspada dan perhatikan guncangan di sekitar.'),
                  _bullet('Jangan abaikan arahan petugas RT.'),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/panduan'),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.menu_book_outlined,
                              size: 28,
                              color: Color(0xFF865400),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panduan Evakuasi Darurat',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Langkah tepat untuk melindungi diri',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF55615A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const AppBottomNavigation(selectedIndex: 0),
        ],
      ),
    );
  }

  Widget _bullet(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '•',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 15, height: 1.45)),
        ),
      ],
    ),
  );
}
