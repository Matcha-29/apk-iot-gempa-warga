import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';
import '../widgets/common_widgets.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

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
                  const Text(
                    'Profil',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Container(
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
                          decoration: const BoxDecoration(
                            color: green,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text(
                              'MY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                DummyUser.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                DummyUser.phone,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF55615A),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                '${DummyUser.rt} / ${DummyUser.rw}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF55615A),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF3E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            DummyUser.status,
                            style: TextStyle(
                              fontSize: 13,
                              color: green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pengaturan peringatan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _setting(
                    Icons.notifications_active_outlined,
                    'Notifikasi darurat',
                    'Wajib aktif agar peringatan sampai',
                    true,
                  ),
                  _setting(
                    Icons.vibration,
                    'Bunyi dan getar',
                    'Aktif saat ada peringatan darurat',
                    true,
                  ),
                  _setting(
                    Icons.location_on_outlined,
                    'Izin lokasi',
                    'Dipakai untuk melaporkan kejadian',
                    false,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Tampilan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Ukuran teks',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 14),
                        Row(
                          children: [
                            Text('A', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 12),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: 0.5,
                                minHeight: 6,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('A', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Bahasa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Bahasa Indonesia',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF55615A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB42318),
                        side: const BorderSide(color: Color(0xFFB42318)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Keluar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showBottomNavigation) const AppBottomNavigation(selectedIndex: 3),
        ],
      ),
    );
  }

  Widget _setting(IconData icon, String title, String subtitle, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            child: Icon(icon, size: 28, color: green),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF55615A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            active ? Icons.toggle_on : Icons.toggle_off,
            size: 42,
            color: active ? green : const Color(0xFF9CA3AF),
          ),
        ],
      ),
    );
  }
}
