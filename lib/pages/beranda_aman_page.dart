import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class BerandaAmanPage extends StatefulWidget {
  const BerandaAmanPage({
    super.key,
    required this.apiState,
    this.showBottomNavigation = true,
  });

  final ApiState apiState;
  final bool showBottomNavigation;

  @override
  State<BerandaAmanPage> createState() => _BerandaAmanPageState();
}

class _BerandaAmanPageState extends State<BerandaAmanPage> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    // Inisialisasi awal
    widget.apiState.refreshStatus();
    widget.apiState.refreshHistory();
    // Polling otomatis setiap 3 detik secara diam-diam
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        widget.apiState.refreshStatus();
        widget.apiState.refreshHistory();
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _callOfficer(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!context.mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Hubungi Petugas RT'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nomor kontak darurat petugas:'),
              const SizedBox(height: 10),
              SelectableText(
                phoneNumber.isNotEmpty ? phoneNumber : '08123456789',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _sendResponse(
    BuildContext context,
    String status,
    String route,
  ) async {
    try {
      await widget.apiState.sendResidentResponse(status);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Laporan "Saya Aman" berhasil dikirim ke sistem.'),
            backgroundColor: green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(error.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.apiState,
      builder: (context, _) {
        final status = widget.apiState.areaStatus;
        final isDanger = status?.isDanger ?? false;
        final isGangguan = status?.isGangguan ?? false;
        final isWarning = status?.isWarning ?? false;
        final isOffline = status?.isOffline ?? false;

        final Color statusColor = isDanger
            ? const Color(0xFFB42318)
            : (isGangguan || isWarning)
                ? const Color(0xFFD97706)
                : const Color(0xFF06725A);

        final String statusTitle = isDanger
            ? 'Kondisi Wilayah\nBAHAYA · GEMPA TERDETEKSI'
            : isGangguan
                ? 'GANGGUAN SENSOR LOKAL'
                : isWarning
                    ? 'Kondisi Wilayah\nWASPADA GETARAN TERDETEKSI'
                    : 'Kondisi Wilayah\nAMAN';

        final String statusSubtitle = isGangguan
            ? 'Getaran terdeteksi pada 1 node saja (bukan gempa)'
            : (status != null
                ? 'Getaran ${status.intensityLabel}  ·  Magnitudo ${status.magnitudeLabel}'
                : 'Getaran 0.00 g  ·  Magnitudo 0.0 M');

        final IconData statusIcon = isDanger
            ? Icons.warning_amber_rounded
            : isGangguan
                ? Icons.sensors_off_outlined
                : isWarning
                    ? Icons.notification_important_outlined
                    : Icons.shield_outlined;

        final String lokasiText = status?.namaLokasi.isNotEmpty == true
            ? status!.namaLokasi
            : 'RT 01 / RW 05';

        final String nomorPetugas = status?.noTeleponPetugas.isNotEmpty == true
            ? status!.noTeleponPetugas
            : '08123456789';

        return MobileFrame(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      widget.apiState.refreshStatus(),
                      widget.apiState.refreshHistory(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Lokasi Anda',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF55615A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  lokasiText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PopupMenuButton<String>(
                                tooltip: 'Simulasi kondisi',
                                onSelected: (value) =>
                                    Navigator.pushNamed(context, value),
                                itemBuilder: (context) => const [
                                  PopupMenuItem(
                                    value: '/gempa-terdeteksi',
                                    child: Text('Simulasi Gempa Terdeteksi'),
                                  ),
                                  PopupMenuItem(
                                    value: '/pemantauan-nonaktif',
                                    child: Text('Simulasi Pemantauan Nonaktif'),
                                  ),
                                  PopupMenuItem(
                                    value: '/uji-coba',
                                    child: Text('Buka Uji Coba Sistem'),
                                  ),
                                  PopupMenuItem(
                                    value: '/lock-notification',
                                    child: Text('Simulasi Layar Kunci'),
                                  ),
                                ],
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Color(0xFF1E293B),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Perbarui status wilayah',
                                onPressed: () {
                                  widget.apiState.refreshStatus();
                                  widget.apiState.refreshHistory();
                                },
                                icon: const Icon(Icons.refresh, size: 24),
                              ),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/lock-notification',
                                ),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7F6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (isOffline) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB45309),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.shield_outlined,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Pemantauan Tidak Aktif',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Kami belum bisa memastikan kondisi wilayah Anda. Jangan anggap aman hanya karena tidak ada peringatan.',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Terakhir diperbarui 10:31 · 16 menit lalu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Yang bisa Anda lakukan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              const SizedBox(height: 12),
                              _bulletItem('Tetap waspada dan perhatikan guncangan di sekitar.'),
                              const SizedBox(height: 8),
                              _bulletItem('Ikuti arahan petugas RT jika ada pengumuman.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _callOfficer(context, nomorPetugas),
                            icon: const Icon(Icons.phone_outlined, size: 20),
                            label: Text(
                              'Hubungi Petugas $lokasiText',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF111827),
                              side: const BorderSide(
                                color: Color(0xFFD1D5DB),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/panduan'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1F2937),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.menu_book_outlined,
                                    color: Colors.white,
                                    size: 24,
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
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Bisa dibaca tanpa internet',
                                        style: TextStyle(
                                          color: Color(0xFF9CA3AF),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                statusIcon,
                                color: Colors.white,
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                statusTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                statusSubtitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _nodeIndicator(
                                          'Node A',
                                          status?.nodeA ?? 'Online',
                                        ),
                                        _nodeIndicator(
                                          'Node B',
                                          status?.nodeB ?? 'Online',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, '/panduan'),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F7F6),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.menu_book_outlined,
                                  size: 30,
                                  color: Color(0xFF865400),
                                ),
                                SizedBox(width: 14),
                                Expanded(
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
                                      SizedBox(height: 4),
                                      Text(
                                        'Baca langkah cepat saat keadaan darurat',
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF55615A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, size: 26),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: widget.apiState.responseInProgress == null
                                      ? () => _sendResponse(
                                            context,
                                            'AMAN',
                                            '/laporan-terkirim',
                                          )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: widget.apiState.responseInProgress == 'AMAN'
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            'Saya Aman',
                                            maxLines: 1,
                                            softWrap: false,
                                            style: TextStyle(
                                              fontSize: 15,
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
                                height: 52,
                                child: OutlinedButton(
                                  onPressed: () =>
                                      _callOfficer(context, nomorPetugas),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFC62828),
                                    side: const BorderSide(
                                      color: Color(0xFFC62828),
                                      width: 1.5,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      'Hubungi Petugas',
                                      maxLines: 1,
                                      softWrap: false,
                                      style: TextStyle(
                                        fontSize: 15,
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
                      const SizedBox(height: 24),
                      const Text(
                        'Riwayat Terakhir',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (widget.apiState.loadingHistory &&
                          widget.apiState.earthquakeHistory.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (widget.apiState.historyError != null &&
                          widget.apiState.earthquakeHistory.isEmpty)
                        TextButton.icon(
                          onPressed: widget.apiState.refreshHistory,
                          icon: const Icon(Icons.refresh),
                          label: Text(widget.apiState.historyError!),
                        )
                      else if (widget.apiState.earthquakeHistory.isEmpty)
                        const Text(
                          'Belum ada riwayat gempa dari server.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF55615A),
                          ),
                        )
                      else
                        ...widget.apiState.earthquakeHistory.take(3).map(_activity),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            if (widget.showBottomNavigation)
                const AppBottomNavigation(selectedIndex: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _nodeIndicator(String name, String value) {
    final online = value.toLowerCase() == 'online';
    final displayText = '$name ${online ? 'Online' : 'Offline'}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.circle,
          size: 9,
          color: online ? const Color(0xFFBFEEDC) : const Color(0xFFFFC5C5),
        ),
        const SizedBox(width: 7),
        Text(
          displayText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _activity(EarthquakeHistoryItem item) {
    final normalizedCategory = item.category.toLowerCase();
    final normalizedConsensus = item.consensus.toLowerCase();
    final isTest = normalizedCategory.contains('uji') ||
        normalizedConsensus.contains('uji');
    final isGangguan = normalizedCategory.contains('gangguan') ||
        normalizedConsensus.contains('gangguan') ||
        item.sumberKejadian.contains('1 Node');
    final isWarning = !isGangguan &&
        (normalizedCategory.contains('waspada') ||
            normalizedConsensus.contains('waspada'));
    final isDanger = !isTest &&
        !isWarning &&
        !isGangguan &&
        (normalizedCategory.contains('gempa') ||
            normalizedConsensus.contains('verifikasi'));

    final IconData icon = isTest
        ? Icons.notifications_none
        : isDanger
            ? Icons.warning_amber_rounded
            : isGangguan
                ? Icons.sensors_off_outlined
                : Icons.notification_important_outlined;

    final String tag = isTest
        ? 'Uji coba'
        : isDanger
            ? 'Gempa'
            : isGangguan
                ? 'Gangguan'
                : 'Waspada';

    final Color tagColor = isDanger
        ? const Color(0xFFB42318)
        : isGangguan
            ? const Color(0xFF475569)
            : isWarning
                ? const Color(0xFFD97706)
                : green;

    final Color tagBg = isDanger
        ? const Color(0xFFFFD7D7)
        : isGangguan
            ? const Color(0xFFE2E8F0)
            : isWarning
                ? const Color(0xFFFEF3C7)
                : const Color(0xFFE8F4FF);

    final Color iconColor = tagColor;
    final Color iconBg = tagBg;

    // Hilangkan tanda "· -" pada subjudul
    final subInfo = item.subInfoText;
    final dateFormatted = formatWaktuIndonesia(item.date);
    final subtitleText =
        subInfo.isNotEmpty ? '$dateFormatted · $subInfo' : dateFormatted;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              size: 26,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.intensity,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF55615A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                color: tagColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF374151),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
