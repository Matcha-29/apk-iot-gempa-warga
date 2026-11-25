import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

typedef AktivasiPage = ActivatePage;

class ActivatePage extends StatefulWidget {
  const ActivatePage({super.key});

  @override
  State<ActivatePage> createState() => _ActivatePageState();
}

class _ActivatePageState extends State<ActivatePage> {
  final _activationCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _activationCodeController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _activate() async {
    final code = _activationCodeController.text.trim();
    final password = _passwordController.text;
    final passwordConfirmation = _passwordConfirmationController.text;

    if (code.isEmpty) {
      _showMessage('Masukkan kode aktivasi terlebih dahulu.');
      return;
    }
    if (password.isEmpty) {
      _showMessage('Masukkan kata sandi baru.');
      return;
    }
    if (password.length < 8) {
      _showMessage('Kata sandi minimal 8 karakter.');
      return;
    }
    if (password != passwordConfirmation) {
      _showMessage('Konfirmasi kata sandi tidak cocok.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.instance.aktivasiAkun(
        kodeAktivasi: code,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/beranda', (route) => false);
    } on ApiException catch (error) {
      _showMessage(error.message);
    } catch (error) {
      _showMessage('Terjadi kesalahan: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            back(context),
            const SizedBox(height: 24),
            const Text(
              'Aktifkan Akun',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Masukkan kode aktivasi dari petugas RT, lalu buat kata sandi Anda sendiri.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: Color(0xFF55615A),
              ),
            ),
            const SizedBox(height: 28),
            label('Kode aktivasi'),
            const SizedBox(height: 8),
            Field(
              hint: 'RT01-XXXX',
              controller: _activationCodeController,
            ),
            const SizedBox(height: 12),
            const Text(
              'Berlaku 24 jam dan hanya bisa dipakai sekali.',
              style: TextStyle(fontSize: 14, color: Color(0xFF55615A)),
            ),
            const SizedBox(height: 20),
            label('Kata sandi baru'),
            const SizedBox(height: 8),
            Field(
              hint: 'Minimal 8 karakter',
              obscure: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 20),
            label('Ulangi kata sandi'),
            const SizedBox(height: 8),
            Field(
              hint: 'Ketik ulang kata sandi',
              obscure: true,
              controller: _passwordConfirmationController,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 24, color: Color(0xFFC27A00)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Data Anda hanya dipakai untuk peringatan gempa di RT ini. Jangan bagikan kode kepada orang lain.',
                      style: TextStyle(fontSize: 14, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _activate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Aktifkan Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
