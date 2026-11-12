import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
import '../widgets/common_widgets.dart';

class BerandaAmanPage extends StatelessWidget {
  const BerandaAmanPage({
    super.key,
    required this.apiState,
    this.showBottomNavigation = true,
  });

  final ApiState apiState;
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: apiState,
      builder: (context, _) {
        final status = apiState.areaStatus;
        final danger = status?.isDanger ?? false;
        final statusColor = status == null || (!status.isSafe && !danger)
            ? const Color(0xFF52605B)
            : danger
            ? const Color(0xFFB42318)
            : const Color(0xFF06725A);
        return MobileFrame(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                          Column(
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
                              const Text(
                                'Wilayah Anda',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                tooltip: 'Perbarui status wilayah',
                                onPressed: apiState.loadingStatus
                                    ? null
                                    : apiState.refreshStatus,
                                icon: apiState.loadingStatus
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.refresh, size: 26),
                              ),
                              InkWell(
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/lock-notification',
                                ),
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F7F6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_none,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
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
                              danger
                                  ? Icons.warning_amber_rounded
                                  : Icons.shield_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Kondisi Wilayah\n${status == null ? (apiState.loadingStatus ? 'Memuat...' : 'Tidak diketahui') : danger ? 'BAHAYA / GEMPA TERDETEKSI' : status.status}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              status == null
                                  ? apiState.loadingStatus
                                        ? 'Mengambil status wilayah dari server...'
                                        : apiState.statusError ??
                                              'Status wilayah belum tersedia.'
                                  : 'Getaran ${status.intensityLabel}  ·  Magnitudo ${status.magnitudeLabel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (apiState.loadingStatus && status == null)
                              const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            else if (status == null)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: apiState.refreshStatus,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.white,
                                  ),
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Coba lagi'),
                                ),
                              )
                            else
                              Row(
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 16,
                                      runSpacing: 8,
                                      children: [
                                        _nodeIndicator('Node A', status.nodeA),
                                        _nodeIndicator('Node B', status.nodeB),
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
                                size: 32,
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
                                      'Baca langkah cepat menjadi',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF55615A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 28),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: apiState.responseInProgress == null
                                    ? () => _sendResponse(
                                        context,
                                        'AMAN',
                                        '/laporan-terkirim',
                                      )
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: apiState.responseInProgress == 'AMAN'
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        'Saya Aman',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 54,
                              child: OutlinedButton(
                                onPressed: apiState.responseInProgress == null
                                    ? () => _sendResponse(
                                        context,
                                        'BUTUH_BANTUAN',
                                        '/bantuan-terkirim',
                                      )
                                    : null,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFC62828),
                                  side: const BorderSide(
                                    color: Color(0xFFC62828),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child:
                                    apiState.responseInProgress ==
                                        'BUTUH_BANTUAN'
                                    ? const CircularProgressIndicator()
                                    : const Text(
                                        'Hubungi Petugas',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Riwayat Terakhir',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (apiState.loadingHistory &&
                          apiState.earthquakeHistory.isEmpty)
                        const Center(child: CircularProgressIndicator())
                      else if (apiState.historyError != null &&
                          apiState.earthquakeHistory.isEmpty)
                        TextButton.icon(
                          onPressed: apiState.refreshHistory,
                          icon: const Icon(Icons.refresh),
                          label: Text(apiState.historyError!),
                        )
                      else if (apiState.earthquakeHistory.isEmpty)
                        const Text(
                          'Belum ada riwayat dari server.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF55615A),
                          ),
                        )
                      else
                        ...apiState.earthquakeHistory.take(3).map(_activity),
                    ],
                  ),
                ),
              ),
              if (showBottomNavigation)
                const AppBottomNavigation(selectedIndex: 0),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendResponse(
    BuildContext context,
    String status,
    String route,
  ) async {
    try {
      await apiState.sendResidentResponse(status);
      if (context.mounted) Navigator.pushNamed(context, route);
    } on ApiException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Widget _nodeIndicator(String name, String value) {
    final online = value.toLowerCase() == 'online';
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
          '$name $value',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _activity(EarthquakeHistoryItem item) {
    final normalizedCategory = item.category.toLowerCase();
    final normalizedConsensus = item.consensus.toLowerCase();
    final isTest =
        normalizedCategory.contains('uji') ||
        normalizedConsensus.contains('uji');
    final danger =
        !isTest &&
        (normalizedCategory.contains('gempa') ||
            normalizedConsensus.contains('verifikasi'));
    final icon = isTest
        ? Icons.notifications_none
        : danger
        ? Icons.warning_amber_rounded
        : Icons.flash_on_outlined;
    final tag = isTest
        ? 'Uji coba'
        : danger
        ? 'Gempa'
        : item.category;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: danger ? const Color(0xFFFFE5D5) : const Color(0xFFE9F7EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 28,
              color: danger ? const Color(0xFFC62828) : green,
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
                  '${item.date} · ${item.duration}',
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
              color: danger ? const Color(0xFFFFD7D7) : const Color(0xFFE8F4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                color: danger ? const Color(0xFFB42318) : green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
