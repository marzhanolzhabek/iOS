
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';

class LocalStorageService {
  static const String themeKey = 'app_theme_dark_mode';
  static const String usernameKey = 'user_display_name';
  static const String notesKey = 'saved_notes';


  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(themeKey, isDark);
  }


  static Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(themeKey) ?? false;
  }

  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(usernameKey, username);
  }

  static Future<String> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey) ?? 'Guest User';
  }

  static Future<void> saveNotes(List<NoteItem> notes) async {
    final prefs = await SharedPreferences.getInstance();

    final jsonList = notes.map((note) => note.toJson()).toList();
    final jsonString = jsonEncode(jsonList);

    await prefs.setString(notesKey, jsonString);
  }

  static Future<List<NoteItem>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(notesKey);

    if (jsonString == null) {
      return [];
    }

    final List<dynamic> decoded = jsonDecode(jsonString);

    return decoded
        .map((item) =>
        NoteItem.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
