import 'package:flutter/widgets.dart';

import 'services/api_service.dart';
import 'services/api_state.dart';
import 'pages/masuk_page.dart';
import 'pages/aktivasi_akun_page.dart';
import 'pages/lupa_kata_sandi_page.dart';
import 'pages/izin_aplikasi_page.dart';
import 'pages/notifikasi_layar_kunci_page.dart';
import 'pages/beranda_page.dart';
import 'pages/pemantauan_tidak_aktif_page.dart';
import 'pages/gempa_terdeteksi_page.dart';
import 'pages/uji_coba_page.dart';
import 'pages/laporan_aman_terkirim_page.dart';
import 'pages/bantuan_terkirim_page.dart';
import 'pages/kembali_aman_page.dart';
import 'pages/panduan_evakuasi_page.dart';
import 'pages/history_page.dart';
import 'pages/profil_page.dart';

Map<String, WidgetBuilder> appRoutes() {
  Widget earthquakeRoute(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is ApiState) {
      return GempaTerdeteksiPage(
        status: arguments.areaStatus,
        apiState: arguments,
      );
    }
    return GempaTerdeteksiPage(
      status: arguments is AreaStatus ? arguments : null,
    );
  }

  return {
    '/': (_) => const LoginPage(),
    '/login': (_) => const LoginPage(),
    '/aktivasi': (_) => const AktivasiPage(),
    '/activate': (_) => const ActivatePage(),
    '/forgot': (_) => const ForgotPage(),
    '/permissions': (_) => const PermissionsPage(),
    '/lock-notification': (_) => const NotifikasiLayarKunciPage(),
    '/beranda': (_) => const BerandaPage(),
    '/home': (_) => const BerandaPage(),
    '/gempa-terdeteksi': earthquakeRoute,
    '/earthquake': earthquakeRoute,
    '/pemantauan-nonaktif': (_) => const PemantauanTidakAktifPage(),
    '/inactive': (_) => const PemantauanTidakAktifPage(),
    '/uji-coba': (_) => const UjiCobaPage(),
    '/test-warning': (_) => const UjiCobaPage(),
    '/laporan-terkirim': (_) => const LaporanAmanTerkirimPage(),
    '/safe-report': (_) => const LaporanAmanTerkirimPage(),
    '/bantuan-terkirim': (_) => const BantuanTerkirimPage(),
    '/help-request': (_) => const BantuanTerkirimPage(),
    '/kembali-aman': (_) => const KembaliAmanPage(),
    '/after-earthquake': (_) => const KembaliAmanPage(),
    '/panduan': (_) => const PanduanEvakuasiPage(),
    '/guide': (_) => const PanduanEvakuasiPage(),
    '/riwayat': (_) => const RiwayatPage(),
    '/history': (_) => const RiwayatPage(),
    '/profil': (_) => const ProfilPage(),
    '/profile': (_) => const ProfilPage(),
  };
}
