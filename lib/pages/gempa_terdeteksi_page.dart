import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/api_state.dart';
import '../widgets/api_response_action.dart';
import '../widgets/common_widgets.dart';

class GempaTerdeteksiPage extends StatefulWidget {
  const GempaTerdeteksiPage({super.key, this.status, this.apiState});

  final AreaStatus? status;
  final ApiState? apiState;

  @override
  State<GempaTerdeteksiPage> createState() => _GempaTerdeteksiPageState();
}

class _GempaTerdeteksiPageState extends State<GempaTerdeteksiPage> {
  bool _closingForSafeStatus = false;

  @override
  void initState() {
    super.initState();
    widget.apiState?.addListener(_handleStatusChange);
    _handleStatusChange();
  }

  @override
  void didUpdateWidget(covariant GempaTerdeteksiPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.apiState != widget.apiState) {
      oldWidget.apiState?.removeListener(_handleStatusChange);
      widget.apiState?.addListener(_handleStatusChange);
      _handleStatusChange();
    }
  }

  void _handleStatusChange() {
    if (!(widget.apiState?.areaStatus?.isSafe ?? false) ||
        _closingForSafeStatus) {
      return;
    }
    _closingForSafeStatus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    widget.apiState?.removeListener(_handleStatusChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final apiState = widget.apiState;
    if (apiState == null) return _buildPage(context, widget.status);
    return AnimatedBuilder(
      animation: apiState,
      builder: (context, _) =>
          _buildPage(context, apiState.areaStatus ?? widget.status),
    );
  }

  Widget _buildPage(BuildContext context, AreaStatus? status) {
    return MobileFrame(
      child: Container(
        color: const Color(0xFFA71419),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'RT 01 / RW 05',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Text(
                    '10:47:12',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFBB2629),
                    border: Border.all(
                      color: const Color(0xFFF5B4B4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Center(
                child: Text(
                  'GEMPA TERDEKSI!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Kondisi wilayah',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  status?.status ?? 'BAHAYA',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Getaran ${status?.intensityLabel ?? '-'}  ·  Magnitudo ${status?.magnitudeLabel ?? '-'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Node A ${status?.nodeA ?? 'Tidak diketahui'}  ·  Node B ${status?.nodeB ?? 'Tidak diketahui'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/panduan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB42318),
                  ),
                  child: const Text(
                    'Buka Panduan Evakuasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ApiResponseAction(
                        status: 'butuh_bantuan',
                        route: '/bantuan-terkirim',
                        builder: (context, loading, onPressed) =>
                            ElevatedButton(
                              onPressed: onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB42A2D),
                                foregroundColor: Colors.white,
                              ),
                              child: loading
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ApiResponseAction(
                        status: 'aman',
                        route: '/laporan-terkirim',
                        builder: (context, loading, onPressed) =>
                            ElevatedButton(
                              onPressed: onPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB42A2D),
                                foregroundColor: Colors.white,
                              ),
                              child: loading
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
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Lakukan sekarang',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _action(
                Icons.shield_outlined,
                'Menunduk dan berlindung',
                'Lindungi kepala, jangan lari',
              ),
              _action(Icons.open_in_new, 'Jika di luar', 'Menuju area terbuka'),
              _action(
                Icons.warning_amber_outlined,
                'Jauhi bangunan',
                'Hindari kaca dan kabel listrik',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _action(IconData icon, String title, String subtitle) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFB42A2D),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      children: [
        Icon(icon, size: 28, color: Colors.white),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
