import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return IconButton(
      tooltip: isDark ? 'Ganti ke tema terang' : 'Ganti ke tema gelap',
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
    );
  }
}
