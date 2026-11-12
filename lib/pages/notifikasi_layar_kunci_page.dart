import 'package:flutter/material.dart';

import '../widgets/api_response_action.dart';
import '../widgets/common_widgets.dart';

class NotifikasiLayarKunciPage extends StatelessWidget {
  const NotifikasiLayarKunciPage({super.key});

  @override
  Widget build(BuildContext context) => MobileFrame(
    child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17212B), Color(0xFF06090D)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
          child: Column(
            children: [
              const Text(
                'Kamis, 29 Oktober',
                style: TextStyle(color: Color(0xFFEAF0F4), fontSize: 9),
              ),
              const SizedBox(height: 2),
              const Text(
                '10:47',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  height: 1,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFECE8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.emergency_outlined,
                            color: Color(0xFFD83A2E),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Deteksi Gempa',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF667085),
                                ),
                              ),
                              Text(
                                'GEMPA TERDETEKSI · RT 01',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Text(
                          'Sekarang',
                          style: TextStyle(
                            fontSize: 7,
                            color: Color(0xFF667085),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Intensitas gempa KUAT. Merunduk, berlindung, dan bertahan. Tetap tenang.',
                        style: TextStyle(fontSize: 8.5, height: 1.35),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ApiResponseAction(
                            status: 'aman',
                            route: '/safe-report',
                            builder: (context, loading, onPressed) =>
                                ElevatedButton(
                                  onPressed: onPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                  ),
                                  child: loading
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Saya Aman',
                                          style: TextStyle(fontSize: 8.5),
                                        ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/panduan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1F4F6),
                              foregroundColor: const Color(0xFF111827),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Buka Panduan',
                              style: TextStyle(fontSize: 8.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF121A38),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFB7C4FF)),
                ),
                child: const Text(
                  'Deteksi Gempa · 08:00\nUJI COBA: Pilihan getaran mengguncang\nPetugas RT 01 sedang menguji sistem. Tidak ada tindakan.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    height: 1.35,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Notifikasi darurat tetap tampil di layar kunci\ndan menembus mode senyap ponsel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8F9AA5),
                  fontSize: 7.5,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
