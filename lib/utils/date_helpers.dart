/// Helper pemformat waktu Indonesia untuk aplikasi IoT Gempa Warga.
String formatWaktuIndonesia(String? rawDate) {
  if (rawDate == null || rawDate.trim().isEmpty || rawDate.trim() == '-') {
    return '-';
  }

  final trimmed = rawDate.trim();
  DateTime? dateTime;
  try {
    dateTime = DateTime.parse(trimmed);
  } catch (_) {
    // Jika format non-standar, coba bersihkan
    return trimmed;
  }

  // Konversi ke UTC+7 (Waktu Indonesia Barat - WIB)
  final wib = dateTime.isUtc
      ? dateTime.add(const Duration(hours: 7))
      : dateTime.toLocal();

  const bulan = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  final day = wib.day.toString().padLeft(2, '0');
  final monthName = (wib.month >= 1 && wib.month <= 12) ? bulan[wib.month] : '';
  final year = wib.year;
  final hour = wib.hour.toString().padLeft(2, '0');
  final minute = wib.minute.toString().padLeft(2, '0');

  return '$day $monthName $year, $hour:$minute WIB';
}

/// Format jam saja (HH:mm:ss WIB)
String formatJamWib(DateTime dateTime) {
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final second = dateTime.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

/// Format tanggal lengkap untuk layar kunci (contoh: Senin, 23 November)
String formatHariTanggalIndonesia(DateTime dateTime) {
  const namaHari = [
    '',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  const namaBulanLengkap = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final hari = (dateTime.weekday >= 1 && dateTime.weekday <= 7)
      ? namaHari[dateTime.weekday]
      : '';
  final bulan = (dateTime.month >= 1 && dateTime.month <= 12)
      ? namaBulanLengkap[dateTime.month]
      : '';

  return '$hari, ${dateTime.day} $bulan';
}

/// Alias helper untuk format jam HH:mm:ss
String formatHmsTime(DateTime dateTime) => formatJamWib(dateTime);

/// Alias helper untuk format tanggal Indonesia
String formatDateTime(String? rawDate) => formatWaktuIndonesia(rawDate);
