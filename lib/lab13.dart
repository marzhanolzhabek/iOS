
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'
as ph;
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LunaMomentsApp());
}

class LunaMomentsApp extends StatelessWidget {
  const LunaMomentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUNA MOMENTS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF718776),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F4EF),
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const PhotoDiaryScreen(),
    );
  }
}


class DiaryEntry {
  final String id;
  final String imagePath;
  final String caption;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final double altitude;
  final double accuracy;
  final bool favorite;

  const DiaryEntry({
    required this.id,
    required this.imagePath,
    required this.caption,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.accuracy,
    this.favorite = false,
  });

  DiaryEntry copyWith({bool? favorite}) {
    return DiaryEntry(
      id: id,
      imagePath: imagePath,
      caption: caption,
      timestamp: timestamp,
      latitude: latitude,
      longitude: longitude,
      altitude: altitude,
      accuracy: accuracy,
      favorite: favorite ?? this.favorite,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'caption': caption,
    'timestamp': timestamp.toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'accuracy': accuracy,
    'favorite': favorite,
  };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      caption: json['caption'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      favorite: json['favorite'] as bool? ?? false,
    );
  }
}



class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  State<PhotoDiaryScreen> createState() =>
      _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends State<PhotoDiaryScreen> {
  static const bg = Color(0xFFF7F4EF);
  static const green = Color(0xFF354D40);
  static const sage = Color(0xFF718776);
  static const cream = Color(0xFFE9E5DB);

  final ImagePicker picker = ImagePicker();
  final TextEditingController captionController =
  TextEditingController();
  final TextEditingController searchController =
  TextEditingController();

  XFile? selectedPhoto;
  Position? currentPosition;
  DateTime? photoTimestamp;

  List<DiaryEntry> entries = [];

  bool fetchingGPS = false;
  bool saving = false;
  bool pickingPhoto = false;
  bool loadingEntries = true;
  bool favoritesOnly = false;

  String searchText = '';

  @override
  void initState() {
    super.initState();
    loadEntries();
  }

  @override
  void dispose() {
    captionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');

    return '${date.year}-${two(date.month)}-${two(date.day)} '
        '${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }

  void notify(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }



  Future<void> loadEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('luna_diary_entries');

      if (raw != null) {
        final decoded = jsonDecode(raw) as List<dynamic>;

        final restored = decoded
            .map(
              (item) => DiaryEntry.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
            .where((entry) => File(entry.imagePath).existsSync())
            .toList();

        if (!mounted) return;

        setState(() {
          entries = restored;
        });
      }
    } catch (e) {
      notify('Could not load diary: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          loadingEntries = false;
        });
      }
    }
  }

  Future<void> persistEntries(
      List<DiaryEntry> updated,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      updated.map((entry) => entry.toJson()).toList(),
    );

    final success = await prefs.setString(
      'luna_diary_entries',
      encoded,
    );

    if (!success) {
      throw Exception('Could not save diary metadata.');
    }
  }



  Future<void> choosePhoto(ImageSource source) async {
    if (pickingPhoto) return;

    setState(() {
      pickingPhoto = true;
    });

    try {
      if (source == ImageSource.camera) {
        final status = await ph.Permission.camera.request();

        if (status.isPermanentlyDenied) {
          notify(
            'Camera blocked. Enable it in app settings.',
            error: true,
          );
          await ph.openAppSettings();
          return;
        }

        if (!status.isGranted) {
          notify('Camera permission denied.', error: true);
          return;
        }
      }

      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1080,
      );

      if (photo == null || !mounted) return;

      setState(() {
        selectedPhoto = photo;
        photoTimestamp = DateTime.now();
        currentPosition = null;
      });

      notify('Photo selected! Now fetch GPS location.');
    } catch (e) {
      notify('Photo error: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          pickingPhoto = false;
        });
      }
    }
  }

  void showPhotoOptions() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: bg,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Capture a Moment',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    color: green,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                    color: sage,
                  ),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Open device camera'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    choosePhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: sage,
                  ),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select an existing photo'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    choosePhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> fetchLocation() async {
    if (fetchingGPS) return;

    setState(() {
      fetchingGPS = true;
      currentPosition = null;
    });

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        final openSettings = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('GPS is disabled'),
            content: const Text(
              'Please enable Location Services '
                  'to save a geotagged photo.',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialogContext, true),
                child: const Text('OPEN SETTINGS'),
              ),
            ],
          ),
        );

        if (openSettings == true) {
          await Geolocator.openLocationSettings();
        }
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        notify('Location permission denied.', error: true);
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        notify(
          'Location permission permanently denied. '
              'Open app settings.',
          error: true,
        );

        await Geolocator.openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      setState(() {
        currentPosition = position;
      });

      notify('GPS location acquired successfully!');
    } catch (e) {
      notify('Unable to fetch GPS: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          fetchingGPS = false;
        });
      }
    }
  }


  Future<void> saveEntry() async {
    if (saving) return;

    if (selectedPhoto == null) {
      notify('Please choose a photo first.', error: true);
      return;
    }

    if (currentPosition == null) {
      notify('Please fetch GPS location first.', error: true);
      return;
    }

    final caption = captionController.text.trim();

    if (caption.isEmpty) {
      notify('Please write a caption.', error: true);
      return;
    }

    setState(() {
      saving = true;
    });

    File? copiedFile;

    try {
      final directory =
      await getApplicationDocumentsDirectory();

      final photosDirectory = Directory(
        '${directory.path}/luna_moments_photos',
      );

      if (!await photosDirectory.exists()) {
        await photosDirectory.create(recursive: true);
      }

      final id =
      DateTime.now().microsecondsSinceEpoch.toString();

      final sourceFile = File(selectedPhoto!.path);

      final extension = sourceFile.path
          .split('.')
          .last
          .toLowerCase();

      final safeExtension = [
        'jpg', 'jpeg', 'png', 'heic', 'webp',
      ].contains(extension)
          ? extension
          : 'jpg';

      copiedFile = await sourceFile.copy(
        '${photosDirectory.path}/$id.$safeExtension',
      );

      final position = currentPosition!;

      final entry = DiaryEntry(
        id: id,
        imagePath: copiedFile.path,
        caption: caption,
        timestamp: photoTimestamp ?? DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
      );

      final updated = [entry, ...entries];

      await persistEntries(updated);

      if (!mounted) return;

      setState(() {
        entries = updated;
        selectedPhoto = null;
        currentPosition = null;
        photoTimestamp = null;
        captionController.clear();
      });

      notify('Your moment has been saved!');
    } catch (e) {
      if (copiedFile != null &&
          await copiedFile.exists()) {
        await copiedFile.delete();
      }

      notify('Save failed: $e', error: true);
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  Future<void> deleteEntry(DiaryEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text(
          'This photo and diary entry will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      final updated = entries
          .where((item) => item.id != entry.id)
          .toList();

      await persistEntries(updated);

      if (!mounted) return;

      setState(() {
        entries = updated;
      });

      final file = File(entry.imagePath);

      if (await file.exists()) {
        await file.delete();
      }

      notify('Memory deleted.');
    } catch (e) {
      notify('Delete error: $e', error: true);
    }
  }

  Future<void> toggleFavorite(DiaryEntry entry) async {
    try {
      final updated = entries.map((item) {
        if (item.id == entry.id) {
          return item.copyWith(
            favorite: !item.favorite,
          );
        }
        return item;
      }).toList();

      await persistEntries(updated);

      if (!mounted) return;

      setState(() {
        entries = updated;
      });
    } catch (e) {
      notify('Favorite error: $e', error: true);
    }
  }



  Widget sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 26,
            color: green,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Colors.black45,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget locationRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: sage, size: 19),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget photoPreview() {
    return InkWell(
      onTap: showPhotoOptions,
      borderRadius: BorderRadius.circular(23),
      child: Container(
        height: 245,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cream,
          borderRadius: BorderRadius.circular(23),
        ),
        clipBehavior: Clip.antiAlias,
        child: selectedPhoto != null
            ? Image.file(
          File(selectedPhoto!.path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image_outlined),
          ),
        )
            : const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              size: 52,
              color: sage,
            ),
            SizedBox(height: 17),
            Text(
              'A new memory starts here',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 21,
                color: green,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap to add your favorite moment',
              style: TextStyle(
                color: Colors.black45,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget diaryCard(DiaryEntry entry) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.file(
                File(entry.imagePath),
                height: 185,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 185,
                  color: cream,
                  child: const Center(
                    child: Icon(Icons.broken_image_outlined),
                  ),
                ),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      entry.favorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: entry.favorite
                          ? Colors.redAccent
                          : green,
                    ),
                    onPressed: () => toggleFavorite(entry),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.caption,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    color: green,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: sage,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${entry.latitude.toStringAsFixed(4)}°, '
                            '${entry.longitude.toStringAsFixed(4)}°',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_outlined,
                      color: sage,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        formatDate(entry.timestamp),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Altitude: ${entry.altitude.toStringAsFixed(1)} m'
                            '  •  ±${entry.accuracy.toStringAsFixed(1)} m',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete memory',
                      onPressed: () => deleteEntry(entry),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final filtered = entries.where((entry) {
      final matchesSearch = entry.caption
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesFavorite =
          !favoritesOnly || entry.favorite;

      return matchesSearch && matchesFavorite;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'LUNA MOMENTS',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 23,
            letterSpacing: 3,
            color: green,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20, 18, 20, 40,
              ),
              children: [
                const Center(
                  child: Icon(
                    Icons.auto_awesome,
                    color: sage,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Collect moments,\nnot things.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 35,
                    height: 1.2,
                    color: green,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'YOUR PERSONAL GEOTAGGED PHOTO JOURNAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 1.7,
                    fontSize: 10,
                    color: sage,
                  ),
                ),
                const SizedBox(height: 30),

                sectionTitle(
                  'Capture a memory',
                  'Every place has a story worth remembering.',
                ),
                const SizedBox(height: 18),
                photoPreview(),
                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickingPhoto
                            ? null
                            : () => choosePhoto(
                          ImageSource.camera,
                        ),
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                        ),
                        label: const Text('CAMERA'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: pickingPhoto
                            ? null
                            : () => choosePhoto(
                          ImageSource.gallery,
                        ),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                        ),
                        label: const Text('GALLERY'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 23),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      locationRow(
                        Icons.place_outlined,
                        'Latitude',
                        currentPosition == null
                            ? 'Not fetched'
                            : currentPosition!.latitude
                            .toStringAsFixed(6),
                      ),
                      locationRow(
                        Icons.explore_outlined,
                        'Longitude',
                        currentPosition == null
                            ? 'Not fetched'
                            : currentPosition!.longitude
                            .toStringAsFixed(6),
                      ),
                      locationRow(
                        Icons.my_location_outlined,
                        'Accuracy',
                        currentPosition == null
                            ? '—'
                            : '±${currentPosition!.accuracy.toStringAsFixed(1)} m',
                      ),
                      locationRow(
                        Icons.terrain_outlined,
                        'Altitude',
                        currentPosition == null
                            ? '—'
                            : '${currentPosition!.altitude.toStringAsFixed(1)} m',
                      ),
                      locationRow(
                        Icons.access_time_outlined,
                        'Timestamp',
                        photoTimestamp == null
                            ? '—'
                            : formatDate(photoTimestamp!),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: fetchingGPS
                              ? null
                              : fetchLocation,
                          style: FilledButton.styleFrom(
                            backgroundColor: sage,
                          ),
                          icon: fetchingGPS
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.gps_fixed),
                          label: Text(
                            fetchingGPS
                                ? 'LOCATING...'
                                : 'FETCH CURRENT GPS',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 27),

                sectionTitle(
                  'Your story',
                  'Give this moment a meaningful name.',
                ),
                const SizedBox(height: 15),

                TextField(
                  controller: captionController,
                  maxLines: 2,
                  maxLength: 120,
                  decoration: InputDecoration(
                    hintText:
                    'e.g. An unforgettable day at Narxoz...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                SizedBox(
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: saving ? null : saveEntry,
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    icon: saving
                        ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.bookmark_add_outlined),
                    label: Text(
                      saving
                          ? 'SAVING MEMORY...'
                          : 'SAVE ENTRY TO DIARY',
                      style: const TextStyle(
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 38),
                const Divider(),
                const SizedBox(height: 22),

                sectionTitle(
                  'The Memory Collection',
                  '${entries.length} moments preserved',
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search your memories...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: sage,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Favorites only'),
                    selected: favoritesOnly,
                    onSelected: (value) {
                      setState(() {
                        favoritesOnly = value;
                      });
                    },
                    avatar: const Icon(
                      Icons.favorite_border,
                      size: 17,
                    ),
                  ),
                ),

                const SizedBox(height: 17),

                if (loadingEntries)
                  const Padding(
                    padding: EdgeInsets.all(25),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(35),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 48,
                          color: sage,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No memories here yet.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 20,
                            color: green,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Capture your first moment above.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map(diaryCard),

                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    'LUNA MOMENTS  •  MADE WITH MEMORIES',
                    style: TextStyle(
                      fontSize: 10,
                      color: sage,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
