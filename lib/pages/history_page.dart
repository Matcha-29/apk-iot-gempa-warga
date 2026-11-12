import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
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

  @override
  void initState() {
    super.initState();
    _ownsApiState = widget.apiState == null;
    _apiState = widget.apiState ?? ApiState();
    if (_ownsApiState) _apiState.refreshHistory();
  }

  @override
  void dispose() {
    if (_ownsApiState) _apiState.dispose();
    super.dispose();
  }

  List<EarthquakeHistoryItem> get filteredHistory {
    if (selectedCategory == 'Semua') return _apiState.earthquakeHistory;
    return _apiState.earthquakeHistory.where((item) {
      final category = item.category.toLowerCase();
      final consensus = item.consensus.toLowerCase();
      final description = item.intensity.toLowerCase();
      if (selectedCategory == 'Uji coba') {
        return category.contains('uji') || consensus.contains('uji');
      }
      if (selectedCategory == 'Info') {
        return category.contains('info') ||
            consensus.contains('tidak konsisten') ||
            description.contains('getaran');
      }
      return !category.contains('uji') &&
          !category.contains('info') &&
          !consensus.contains('uji') &&
          !consensus.contains('tidak konsisten');
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
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Perbarui riwayat',
                        onPressed: _apiState.loadingHistory
                            ? null
                            : _apiState.refreshHistory,
                        icon: _apiState.loadingHistory
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Peringatan dan kejadian di RT 01',
                    style: TextStyle(fontSize: 15, color: Color(0xFF55615A)),
                  ),
                  const SizedBox(height: 20),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Gempa', 'Uji coba', 'Info']
                          .map(
                            (category) => Padding(
                              padding: const EdgeInsets.only(right: 10),
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
                  else if (history.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7F6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        _apiState.earthquakeHistory.isEmpty
                            ? 'Belum ada riwayat gempa dari server.'
                            : 'Tidak ada riwayat pada kategori ini.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF55615A),
                        ),
                      ),
                    )
                  else
                    ...history.map((item) => _item(item)),
              ],
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

  Widget _chip(String category) {
    final active = selectedCategory == category;
    return InkWell(
      onTap: () => setState(() => selectedCategory = category),
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF252525) : const Color(0xFFF1F3F4),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          category,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : const Color(0xFF55615A),
          ),
        ),
      ),
    );
  }

  Widget _item(EarthquakeHistoryItem item) {
    final danger = item.category.toLowerCase().contains('gempa') ||
        item.consensus.toLowerCase().contains('verifikasi');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE1E6E3)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: danger ? const Color(0xFFFFE4DE) : const Color(0xFFEAF8EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              danger ? Icons.warning_amber_rounded : Icons.notifications_none,
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF55615A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: danger ? const Color(0xFFFFDADA) : const Color(0xFFE9F7EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.consensus,
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
