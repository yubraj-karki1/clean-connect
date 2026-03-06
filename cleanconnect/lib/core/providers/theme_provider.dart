import 'package:cleanconnect/core/providers/ambient_light_provider.dart';
import 'package:cleanconnect/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const String _themeModeKey = 'app_theme_mode';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  ThemeMode build() => _loadThemeMode(_prefs);

  static ThemeMode _loadThemeMode(SharedPreferences prefs) {
    final stored = prefs.getString(_themeModeKey);
    switch (stored) {
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeModeKey, _toStorage(mode));
  }

  Future<void> toggleDarkMode(bool enabled) async {
    await setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  String _toStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Effective theme mode:
/// - Uses ambient light sensor when available.
/// - Falls back to light mode when unavailable (to avoid being stuck in dark).
final effectiveThemeModeProvider = Provider<ThemeMode>((ref) {
  final selectedMode = ref.watch(themeModeProvider);
  final ambientLuxAsync = ref.watch(ambientLightLuxProvider);

  if (selectedMode != ThemeMode.system) {
    return selectedMode;
  }

  final lux = ambientLuxAsync.maybeWhen(
    data: (value) => value,
    orElse: () => null,
  );

  if (lux == null) return ThemeMode.light;

  // Requested rule:
  // lux < 60 => dark, lux >= 60 => light.
  const darkLuxThreshold = 60.0;
  return lux < darkLuxThreshold ? ThemeMode.dark : ThemeMode.light;
});
