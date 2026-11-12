import 'package:flutter/material.dart';

import '../utils/dummy_data.dart';
import '../widgets/common_widgets.dart';

class PanduanEvakuasiPage extends StatelessWidget {
  const PanduanEvakuasiPage({super.key, this.showBottomNavigation = true});
  final bool showBottomNavigation;

  @override
  Widget build(BuildContext context) {
    return MobileFrame(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panduan Evakuasi',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tersedia tanpa internet',
                    style: TextStyle(fontSize: 15, color: Color(0xFF55615A)),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC62828),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _step('1', 'Menunduk'),
                        const SizedBox(width: 10),
                        _step('2', 'Berlindung'),
                        const SizedBox(width: 10),
                        _step('3', 'Bertahan'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Langkah penting',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...dummyGuides.map(
                    (guide) =>
                        _guide(guide.title, guide.description, guide.category),
                  ),
                ],
              ),
            ),
          ),
          if (showBottomNavigation) const AppBottomNavigation(selectedIndex: 2),
        ],
      ),
    );
  }

  Widget _step(String number, String title) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF9E2022),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _guide(String title, String text, String category) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7F6),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            title.contains('Jangan')
                ? Icons.warning_amber_rounded
                : Icons.shield_outlined,
            size: 28,
            color: green,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF55615A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(text, style: const TextStyle(fontSize: 14, height: 1.45)),
            ],
          ),
        ),
      ],
    ),
  );
}
