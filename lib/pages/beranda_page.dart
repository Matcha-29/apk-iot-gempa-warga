import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_state.dart';
import '../widgets/common_widgets.dart';
import 'beranda_aman_page.dart';
import 'history_page.dart';
import 'panduan_evakuasi_page.dart';
import 'profil_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int selectedIndex = 0;
  late final ApiState _apiState;
  bool _dangerRouteActive = false;
  bool _dangerAlertShownForCurrentEpisode = false;

  @override
  void initState() {
    super.initState();
    _apiState = ApiState();
    _apiState.addListener(_handleStatusChange);
    _apiState.startStatusPolling();
    unawaited(_apiState.refreshHistory());
  }

  void _handleStatusChange() {
    final status = _apiState.areaStatus;
    if (status?.isSafe ?? false) {
      _dangerAlertShownForCurrentEpisode = false;
      return;
    }
    if (!(status?.isDanger ?? false) ||
        _dangerRouteActive ||
        _dangerAlertShownForCurrentEpisode) {
      return;
    }

    _dangerAlertShownForCurrentEpisode = true;
    _dangerRouteActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _dangerRouteActive = false;
        return;
      }
      unawaited(
        Navigator.of(context)
            .pushNamed<void>('/gempa-terdeteksi', arguments: _apiState)
            .then((_) {
              _dangerRouteActive = false;
              if (mounted &&
                  (_apiState.areaStatus?.isDanger ?? false) &&
                  !_dangerAlertShownForCurrentEpisode) {
                _handleStatusChange();
              }
            }),
      );
    });
  }

  @override
  void dispose() {
    _apiState.removeListener(_handleStatusChange);
    _apiState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      BerandaAmanPage(showBottomNavigation: false, apiState: _apiState),
      RiwayatPage(showBottomNavigation: false, apiState: _apiState),
      const PanduanEvakuasiPage(showBottomNavigation: false),
      const ProfilPage(showBottomNavigation: false),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(index: selectedIndex, children: tabs),
      floatingActionButton: selectedIndex == 0
          ? PopupMenuButton<String>(
              tooltip: 'Simulasi kondisi',
              onSelected: (value) => Navigator.pushNamed(context, value),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: '/gempa-terdeteksi',
                  child: Text('Simulasi gempa terdeteksi'),
                ),
                PopupMenuItem(
                  value: '/pemantauan-nonaktif',
                  child: Text('Simulasi pemantauan nonaktif'),
                ),
                PopupMenuItem(
                  value: '/uji-coba',
                  child: Text('Buka uji coba sistem'),
                ),
              ],
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: .88),
                  borderRadius: BorderRadius.circular(21),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          : null,
      bottomNavigationBar: SizedBox(
        height: 70,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: green,
          unselectedItemColor: const Color(0xFF6B7280),
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 26),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) => setState(() => selectedIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              label: 'Panduan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
