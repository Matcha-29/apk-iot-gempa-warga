import 'package:flutter/material.dart';

import '../widgets/common_widgets.dart';

class ForgotPage extends StatelessWidget {
  const ForgotPage({super.key});
  @override
  Widget build(BuildContext context) => MobileFrame(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          back(context),
          const SizedBox(height: 22),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lock_outline, color: blue, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'Lupa kata sandi?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Akun warga dikelola oleh petugas RT. Hubungi petugas untuk mengatur ulang kata sandi. Anda akan menerima kode aktivasi baru.',
            style: TextStyle(fontSize: 10, height: 1.45),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F5FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siapkan ini saat menghubungi petugas',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 8),
                Check('Nama lengkap Anda'),
                Check('Nomor telepon yang terdaftar'),
                Check('Nomor rumah'),
              ],
            ),
          ),
          const Spacer(),
          primary('Telepon Petugas RT', () {}),
          const SizedBox(height: 10),
          outline(
            'Saya sudah punya kode baru',
            () => Navigator.pushNamed(context, '/activate'),
          ),
        ],
      ),
    ),
  );
}
