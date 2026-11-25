import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
import '../utils/date_helpers.dart';
import '../widgets/common_widgets.dart';

class RiwayatPage extends StatefulWidget {
  const RiwayatPage({
    super.key,
    this.showBottomNavigation = true,
    this.apiState,
  });
  final bool showBottomNavigation;
  final ApiState? apiState;

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  String selectedCategory = 'Semua';
  late final ApiState _apiState;
  late final bool _ownsApiState;
  Timer? _historyTimer;

  @override
  void initState() {
    super.initState();
    _ownsApiState = widget.apiState == null;
    _apiState = widget.apiState ?? ApiState();
    _apiState.refreshHistory();
    _historyTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) _apiState.refreshHistory();
    });
  }

  @override
  void dispose() {
    _historyTimer?.cancel();
    if (_ownsApiState) _apiState.dispose();
    super.dispose();
  }

  List<EarthquakeHistoryItem> get filteredHistory {
    final list = _apiState.earthquakeHistory;
    if (selectedCategory == 'Semua') return list;
    return list.where((item) {
      final category = item.category.toLowerCase();
      final consensus = item.consensus.toLowerCase();
      final isGangguan = category.contains('gangguan') ||
          consensus.contains('gangguan') ||
          item.sumberKejadian.contains('1 Node');
      final isTest = category.contains('uji') || consensus.contains('uji');

      if (selectedCategory == 'Uji coba') {
        return isTest;
      }
      if (selectedCategory == 'Info') {
        return isGangguan ||
            category.contains('info') ||
            consensus.contains('tidak konsisten');
      }
      if (selectedCategory == 'Gempa') {
        return !isGangguan &&
            !isTest &&
            (category.contains('gempa') || consensus.contains('verifikasi'));
      }
      return true;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _apiState,
      builder: (context, _) {
        final history = filteredHistory;
        return MobileFrame(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _apiState.refreshHistory();
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    children: [
                      const Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Peringatan dan kejadian di RT 01',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Semua', 'Gempa', 'Uji coba', 'Info']
                              .map(
                                (category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: _chip(category),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_apiState.loadingHistory && history.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_apiState.historyError != null &&
                          _apiState.earthquakeHistory.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _apiState.historyError!,
                                style: const TextStyle(fontSize: 15),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _apiState.refreshHistory,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba lagi'),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // SECTION HARI INI
                        _sectionHeader('HARI INI'),
                        const SizedBox(height: 10),
                        if (history.isNotEmpty)
                          ...history.take(3).map(_renderApiItem)
                        else ...[
                          _historyCard(
                            icon: Icons.waves,
                            iconBg: const Color(0xFFFEF3C7),
                            iconColor: const Color(0xFFD97706),
                            title: 'Getaran lokal, bukan gempa',
                            subtitle: '10:47',
                            tag: 'Info',
                            tagBg: const Color(0xFFFEF3C7),
                            tagColor: const Color(0xFFB45309),
                          ),
                          const SizedBox(height: 10),
                          _historyCard(
                            icon: Icons.notifications_none,
                            iconBg: const Color(0xFFDBEAFE),
                            iconColor: const Color(0xFF1D4ED8),
                            title: 'Uji coba sistem peringatan',
                            subtitle: '08:00',
                            tag: 'Uji coba',
                            tagBg: const Color(0xFFDBEAFE),
                            tagColor: const Color(0xFF1E40AF),
                          ),
                          const SizedBox(height: 10),
                          _historyCard(
                            icon: Icons.shield_outlined,
                            iconBg: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF166534),
                            title: 'Pemantauan aktif kembali',
                            subtitle: '06:31',
                            tag: 'Pulih',
                            tagBg: const Color(0xFFDCFCE7),
                            tagColor: const Color(0xFF15803D),
                          ),
                        ],
                        const SizedBox(height: 20),
                        // SECTION KEMARIN
                        _sectionHeader('KEMARIN'),
                        const SizedBox(height: 10),
                        if (history.length > 3)
                          ...history.skip(3).map(_renderApiItem)
                        else ...[
                          _historyCard(
                            icon: Icons.warning_amber_rounded,
                            iconBg: const Color(0xFFFEE2E2),
                            iconColor: const Color(0xFFDC2626),
                            title: 'Gempa terdeteksi · intensitas ringan',
                            subtitle: '21:14 · laporan Anda: Aman',
                            tag: 'Gempa',
                            tagBg: const Color(0xFFFEE2E2),
                            tagColor: const Color(0xFFB91C1C),
                          ),
                          const SizedBox(height: 10),
                          _historyCard(
                            icon: Icons.shield_outlined,
                            iconBg: const Color(0xFFDCFCE7),
                            iconColor: const Color(0xFF166534),
                            title: 'Situasi sudah terkendali',
                            subtitle: '21:25',
                            tag: 'Selesai',
                            tagBg: const Color(0xFFDCFCE7),
                            tagColor: const Color(0xFF15803D),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              if (widget.showBottomNavigation)
                const AppBottomNavigation(selectedIndex: 1),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B7280),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _renderApiItem(EarthquakeHistoryItem item) {
    final cat = item.category.toLowerCase();
    final isTest = cat.contains('uji');
    final isGangguan = cat.contains('gangguan') || item.sumberKejadian.contains('1 Node');
    final isDanger = !isTest && !isGangguan && cat.contains('gempa');

    final IconData icon = isTest
        ? Icons.notifications_none
        : (isDanger
            ? Icons.warning_amber_rounded
            : (isGangguan ? Icons.waves : Icons.shield_outlined));

    final Color iconBg = isDanger
        ? const Color(0xFFFEE2E2)
        : (isTest
            ? const Color(0xFFDBEAFE)
            : (isGangguan ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7)));

    final Color iconColor = isDanger
        ? const Color(0xFFDC2626)
        : (isTest
            ? const Color(0xFF1D4ED8)
            : (isGangguan ? const Color(0xFFD97706) : const Color(0xFF15803D)));

    final String tag = isTest
        ? 'Uji coba'
        : (isDanger ? 'Gempa' : (isGangguan ? 'Info' : 'Pulih'));

    final String timeOnly = item.date.length >= 16
        ? item.date.substring(11, 16)
        : formatDateTime(item.date);

    final title = isGangguan
        ? 'Getaran lokal, bukan gempa'
        : (isTest
            ? 'Uji coba sistem peringatan'
            : (isDanger
                ? 'Gempa terdeteksi · ${item.intensity}'
                : 'Situasi aman'));

    final subtitle = '$timeOnly · ${item.subInfoText}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _historyCard(
        icon: icon,
        iconBg: iconBg,
        iconColor: iconColor,
        title: title,
        subtitle: subtitle,
        tag: tag,
        tagBg: iconBg,
        tagColor: iconColor,
      ),
    );
  }

  Widget _historyCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagBg,
    required Color tagColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String category) {
    final active = selectedCategory == category;
    return InkWell(
      onTap: () => setState(() => selectedCategory = category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}
