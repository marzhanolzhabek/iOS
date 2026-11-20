
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'lab11/screens/notes_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final bool savedDarkMode =
      prefs.getBool('app_theme_dark_mode') ?? false;

  runApp(
    NotesScreen(
      initialDarkMode: savedDarkMode,
    ),
  );
}
