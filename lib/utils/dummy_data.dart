class DummyUser {
  static const name = 'Muhammad Yusuf';
  static const rt = 'RT 01';
  static const rw = 'RW 05';
  static const phone = '08123456789';
  static const status = 'Terverifikasi';
}

class DummyAreaStatus {
  static const status = 'AMAN';
  static const intensity = '0.02 g';
  static const nodeA = 'Online';
  static const nodeB = 'Online';
}

class DummyEarthquake {
  const DummyEarthquake({
    required this.date,
    required this.intensity,
    required this.duration,
    required this.consensus,
  });
  final String date;
  final String intensity;
  final String duration;
  final String consensus;
}

const dummyEarthquakeHistory = <DummyEarthquake>[
  DummyEarthquake(
    date: '04 Nov 2026 · 21:14',
    intensity: 'Intensitas ringan',
    duration: '18 detik',
    consensus: 'Terverifikasi',
  ),
  DummyEarthquake(
    date: '28 Okt 2026 · 08:32',
    intensity: 'Intensitas 0.08 g',
    duration: '11 detik',
    consensus: 'Tidak konsisten',
  ),
  DummyEarthquake(
    date: '12 Okt 2026 · 15:07',
    intensity: 'Magnitudo 4.2 SR',
    duration: '24 detik',
    consensus: 'Terverifikasi',
  ),
  DummyEarthquake(
    date: '30 Sep 2026 · 03:45',
    intensity: 'Getaran lokal',
    duration: '6 detik',
    consensus: 'Uji coba',
  ),
];

class DummyGuide {
  const DummyGuide({
    required this.title,
    required this.description,
    required this.category,
  });
  final String title;
  final String description;
  final String category;
}

const dummyGuides = <DummyGuide>[
  DummyGuide(
    title: 'Lindungi kepala',
    description: 'Menunduk dan berlindung dari jatuhan benda.',
    category: 'Saat gempa',
  ),
  DummyGuide(
    title: 'Jauhi bangunan',
    description: 'Jika berada di luar, bergerak ke tempat terbuka.',
    category: 'Saat gempa',
  ),
  DummyGuide(
    title: 'Jangan gunakan lift',
    description: 'Gunakan tangga setelah keadaan stabil.',
    category: 'Saat gempa',
  ),
  DummyGuide(
    title: 'Periksa bahaya',
    description: 'Jauhi kabel, gas, dan bangunan yang retak.',
    category: 'Setelah gempa',
  ),
  DummyGuide(
    title: 'Siapkan tas darurat',
    description: 'Sediakan obat, lampu, air, dan dokumen.',
    category: 'Persiapan',
  ),
];
