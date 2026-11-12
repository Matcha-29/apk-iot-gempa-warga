import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'theme/app_theme.dart';

void main() => runApp(const GempaApp());

class GempaApp extends StatelessWidget {
  const GempaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Gempa Warga',
    theme: AppTheme.light,
    routes: appRoutes(),
  );
}
