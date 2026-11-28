
import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/diary_entry.dart';

class DiaryStorageService {
  static const _key = 'luna_diary_entries';

  Future<List<DiaryEntry>> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);

    if (stored == null) return [];

    final decoded = jsonDecode(stored) as List<dynamic>;

    final entries = decoded
        .map(
          (json) => DiaryEntry.fromJson(
        Map<String, dynamic>.from(json as Map),
      ),
    )
        .where(
          (entry) => File(entry.imagePath).existsSync(),
    )
        .toList();

    return entries;
  }

  Future<void> saveEntries(
      List<DiaryEntry> entries,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final json = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );

    final saved = await prefs.setString(_key, json);

    if (!saved) {
      throw StateError(
        'Could not save diary metadata',
      );
    }
  }

  Future<String> savePhoto(
      XFile photo,
      String id,
      ) async {
    final docs =
    await getApplicationDocumentsDirectory();

    final directory = Directory(
      '${docs.path}/luna_moments_photos',
    );

    await directory.create(recursive: true);

    final extension =
    photo.path.split('.').last.toLowerCase();

    final safeExtension = [
      'jpg',
      'jpeg',
      'png',
      'heic',
      'webp',
    ].contains(extension)
        ? extension
        : 'jpg';

    final saved = await File(photo.path).copy(
      '${directory.path}/$id.$safeExtension',
    );

    return saved.path;
  }

  Future<void> deletePhoto(String path) async {
    final file = File(path);

    if (await file.exists()) {
      await file.delete();
    }
  }
}
