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
  bool _ujiCobaRouteActive = false;
  bool _terkendaliRouteActive = false;

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
    if (status == null) return;

    if (status.isSafe) {
      _dangerAlertShownForCurrentEpisode = false;
      return;
    }

    if (status.isUjiCoba && !_ujiCobaRouteActive) {
      _ujiCobaRouteActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _ujiCobaRouteActive = false;
          return;
        }
        unawaited(
          Navigator.of(context).pushNamed<void>('/uji-coba').then((_) {
            _ujiCobaRouteActive = false;
          }),
        );
      });
      return;
    }

    if (status.isTerkendali && !_terkendaliRouteActive) {
      _terkendaliRouteActive = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          _terkendaliRouteActive = false;
          return;
        }
        unawaited(
          Navigator.of(context).pushNamed<void>('/kembali-aman').then((_) {
            _terkendaliRouteActive = false;
          }),
        );
      });
      return;
    }

    if (!status.isDanger ||
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: green,
          unselectedItemColor: const Color(0xFF6B7280),
          selectedIconTheme: const IconThemeData(size: 24),
          unselectedIconTheme: const IconThemeData(size: 24),
          selectedFontSize: 11,
          unselectedFontSize: 11,
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
