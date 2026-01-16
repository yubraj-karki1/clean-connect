
import 'package:cleanconnect/app/app.dart';
import 'package:cleanconnect/core/services/hive/hive_service.dart';
import 'package:cleanconnect/core/services/storage/user_session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveService().init();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      ],
      child: const App(), // ✅ use App, not MyApp
    ),
  );
}
