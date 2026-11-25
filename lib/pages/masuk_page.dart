import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../widgets/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password = _passwordController.text;
    if (emailOrPhone.isEmpty || password.isEmpty) {
      _showMessage('Nomor telepon/email dan kata sandi wajib diisi.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ApiService.instance.login(emailOrPhone, password);
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
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: green,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.monitor_heart_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Masuk',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aplikasi peringatan gempa untuk warga RT 01',
                  style: TextStyle(fontSize: 15, color: Color(0xFF55615A)),
                ),
                const SizedBox(height: 28),
                label('Nomor telepon atau email'),
                const SizedBox(height: 8),
                Field(
                  hint: '08xx-xxxx-xxxx',
                  controller: _emailOrPhoneController,
                ),
                const SizedBox(height: 20),
                label('Kata sandi'),
                const SizedBox(height: 8),
                Field(
                  hint: 'Masukkan kata sandi',
                  obscure: true,
                  controller: _passwordController,
                ),
                const SizedBox(height: 12),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 44),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/forgot'),
                  child: const Text(
                    'Lupa kata sandi?',
                    style: TextStyle(
                      color: green,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 54,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
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
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7F6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 28, color: blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Belum punya akun? Akun warga dibuat oleh petugas RT. Minta petugas mendaftarkan Anda.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: Color(0xFF55615A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                outline(
                  'Saya punya kode aktivasi',
                  () => Navigator.pushNamed(context, '/aktivasi'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
