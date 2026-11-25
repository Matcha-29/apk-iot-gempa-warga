import 'package:flutter/material.dart';

const green = Color(0xFF0D7C5B);
const blue = Color(0xFF2563EB);

class MobileFrame extends StatelessWidget {
  const MobileFrame({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: child),
  );
}

Widget label(String text) => Text(
  text,
  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
);

Widget back(BuildContext context) => InkWell(
  onTap: () => Navigator.pop(context),
  child: const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.chevron_left, size: 24, color: green),
      Text(
        'Kembali',
        style: TextStyle(
          fontSize: 15,
          color: green,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  ),
);

class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.hint,
    this.obscure = false,
    this.controller,
  });
  final String hint;
  final bool obscure;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF9A9A9A)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E3E3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: green, width: 1.5),
      ),
    ),
  );
}

Widget primary(String text, VoidCallback onPressed) => SizedBox(
  height: 54,
  width: double.infinity,
  child: ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: green,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  ),
);

Widget outline(String text, VoidCallback onPressed) => SizedBox(
  height: 54,
  width: double.infinity,
  child: OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFF111827),
      side: const BorderSide(color: Color(0xFF9CA3AF)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
    ),
  ),
);

class Check extends StatelessWidget {
  const Check(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check, size: 13, color: green),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14, height: 1.45)),
        ),
      ],
    ),
  );
}

class Badge extends StatelessWidget {
  const Badge(this.text, this.color, {super.key});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w800),
    ),
  );
}

class PrimaryCompact extends StatelessWidget {
  const PrimaryCompact(this.text, {super.key, this.onPressed});
  final String text;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: ElevatedButton(
      onPressed: onPressed ?? () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: green,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
      ),
    ),
  );
}

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({super.key, this.selectedIndex = 0});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final items = <({IconData icon, String label, String route})>[
      (icon: Icons.home_outlined, label: 'Beranda', route: '/home'),
      (icon: Icons.warning_amber_rounded, label: 'Riwayat', route: '/history'),
      (icon: Icons.book_outlined, label: 'Panduan', route: '/guide'),
      (icon: Icons.person_outline, label: 'Profil', route: '/profile'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 62,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == selectedIndex;
            return Expanded(
              child: InkWell(
                onTap: () => Navigator.pushReplacementNamed(context, item.route),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: selected ? green : const Color(0xFF6B7280),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: selected ? green : const Color(0xFF6B7280),
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class OutlineCompact extends StatelessWidget {
  const OutlineCompact(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 38,
    child: OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF334155),
        side: const BorderSide(color: Color(0xFF9CA3AF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
