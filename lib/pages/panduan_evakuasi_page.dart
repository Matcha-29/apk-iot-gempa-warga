import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class PanduanEvakuasiPage extends StatefulWidget {
  const PanduanEvakuasiPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  State<PanduanEvakuasiPage> createState() => _PanduanEvakuasiPageState();
}

class _PanduanEvakuasiPageState extends State<PanduanEvakuasiPage> {
  String _selectedTab = 'Saat gempa';

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
                    'Panduan Evakuasi',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      '✓ Tersedia tanpa internet',
                      style: TextStyle(
                        color: Color(0xFF166534),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _tabChip('Saat gempa'),
                      const SizedBox(width: 8),
                      _tabChip('Setelah'),
                      const SizedBox(width: 8),
                      _tabChip('Persiapan'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (_selectedTab == 'Saat gempa') ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB42318),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JIKA DI DALAM BANGUNAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _stepColumn('1', 'Merunduk', 'Turun ke\nlantai'),
                              const SizedBox(width: 8),
                              _stepColumn(
                                '2',
                                'Berlindung',
                                'Di bawah\nmeja kuat',
                              ),
                              const SizedBox(width: 8),
                              _stepColumn(
                                '3',
                                'Bertahan',
                                'Sampai\nberhenti',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _guideCard(
                      icon: Icons.home_work_outlined,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      title: 'Jika di luar bangunan',
                      desc:
                          'Menjauh dari gedung, tiang listrik, papan reklame, dan pohon tinggi. Cari lapangan terbuka lalu jongkok sambil melindungi kepala.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.directions_car_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Jika di dalam kendaraan',
                      desc:
                          'Berhenti di tempat terbuka, jauh dari jembatan dan bangunan. Tetap di dalam kendaraan sampai guncangan berhenti.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.close_rounded,
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFDC2626),
                      title: 'Jangan lakukan',
                      desc:
                          'Jangan memakai lift, berlari keluar saat masih berguncang, atau berdiri di dekat jendela kaca.',
                    ),
                  ] else if (_selectedTab == 'Setelah') ...[
                    _guideCard(
                      icon: Icons.warning_amber_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Waspada gempa susulan',
                      desc:
                          'Gempa susulan sering kali terjadi beberapa menit atau jam setelah gempa utama. Tetap berada di tempat terbuka yang aman.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.power_off_outlined,
                      iconBg: const Color(0xFFFEE2E2),
                      iconColor: const Color(0xFFDC2626),
                      title: 'Periksa bahaya listrik & gas',
                      desc:
                          'Segera matikan sekring meteran listrik dan cabut regulator tabung gas. Jangan menyalakan korek api jika tercium bau gas.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.stairs_outlined,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      title: 'Gunakan tangga darurat',
                      desc:
                          'Jangan gunakan lift. Periksa apakah tangga mengalami retakan struktural sebelum digunakan untuk evakuasi keluar.',
                    ),
                  ] else ...[
                    _guideCard(
                      icon: Icons.backpack_outlined,
                      iconBg: const Color(0xFFDCFCE7),
                      iconColor: const Color(0xFF166534),
                      title: 'Tas Siaga Bencana (TSB)',
                      desc:
                          'Siapkan dokumen penting, kotak P3K, obat pribadi, senter, baterai cadangan, peluit, air minum, dan makanan instan tahan lama.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.family_restroom_outlined,
                      iconBg: const Color(0xFFDBEAFE),
                      iconColor: const Color(0xFF1D4ED8),
                      title: 'Rencana evakuasi keluarga',
                      desc:
                          'Tentukan titik kumpul yang disepakati bersama seluruh anggota keluarga jika terjadi gempa saat sedang terpisah.',
                    ),
                    const SizedBox(height: 12),
                    _guideCard(
                      icon: Icons.handyman_outlined,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFD97706),
                      title: 'Amankan perabotan rumah',
                      desc:
                          'Kaitkan lemari atau rak buku ke dinding. Pasang pengait pengaman pada pintu lemari dapur agar piring tidak berhamburan.',
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          if (widget.showBottomNavigation)
            const AppBottomNavigation(selectedIndex: 2),
        ],
      ),
    );
  }

  Widget _tabChip(String title) {
    final active = _selectedTab == title;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = title),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: active ? Colors.white : const Color(0xFF4B5563),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepColumn(String number, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF991B1B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
