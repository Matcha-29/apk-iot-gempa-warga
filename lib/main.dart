import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';

void main() => runApp(
  DevicePreview(
    enabled: !kReleaseMode,
    builder: (context) => const GempaApp(),
  ),
);

class GempaApp extends StatelessWidget {
  const GempaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Gempa Warga',
    theme: AppTheme.light,
    locale: DevicePreview.locale(context),
    builder: DevicePreview.appBuilder,
    routes: appRoutes(),
  );
}
