
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/diary_entry.dart';
import '../services/diary_storage_service.dart';
import '../services/location_service.dart';
import '../services/photo_service.dart';
import '../widgets/diary_entry_card.dart';
import '../widgets/photo_preview.dart';

class PhotoDiaryScreen extends StatefulWidget {
  const PhotoDiaryScreen({super.key});

  @override
  State<PhotoDiaryScreen> createState() =>
      _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState
    extends State<PhotoDiaryScreen> {
  static const green = Color(0xFF354D40);
  static const sage = Color(0xFF718776);
  static const background = Color(0xFFF7F4EF);

  final _photoService = PhotoService();
  final _locationService = LocationService();
  final _storage = DiaryStorageService();
  final _caption = TextEditingController();

  XFile? _photo;
  Position? _position;
  DateTime? _takenAt;

  List<DiaryEntry> _entries = [];

  String _search = '';
  bool _favoritesOnly = false;
  bool _fetchingGps = false;
  bool _picking = false;
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  String _formatTime(DateTime value) {
    String pad(int n) =>
        n.toString().padLeft(2, '0');

    return '${value.year}-${pad(value.month)}-${pad(value.day)} '
        '${pad(value.hour)}:${pad(value.minute)}:${pad(value.second)}';
  }

  void _message(
      String text, {
        bool error = false,
      }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        error ? Colors.red.shade700 : green,
      ),
    );
  }

  // =====================================
  // LOAD SAVED DIARY
  // =====================================

  Future<void> _loadEntries() async {
    try {
      final entries = await _storage.loadEntries();

      if (mounted) {
        setState(() {
          _entries = entries;
        });
      }
    } catch (e) {
      _message(
        'Could not load entries: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =====================================
  // CAMERA / GALLERY
  // =====================================

  Future<void> _pickPhoto(
      ImageSource source,
      ) async {
    if (_picking) return;

    setState(() {
      _picking = true;
    });

    try {
      final image =
      await _photoService.pickPhoto(source);

      if (!mounted || image == null) return;

      setState(() {
        _photo = image;
        _takenAt = DateTime.now();
        _position = null;
      });

      _message(
        'Photo selected! Fetch the GPS location next.',
      );
    } on UnsupportedError catch (e) {
      _message(
        '${e.message}',
        error: true,
      );
    } catch (e) {
      _message(
        'Photo error: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _picking = false;
        });
      }
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: background,
      showDragHandle: true,
      builder: (sheet) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(sheet);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  onTap: () {
                    Navigator.pop(sheet);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // =====================================
  // GPS LOCATION
  // =====================================

  Future<void> _fetchLocation() async {
    if (_fetchingGps) return;

    setState(() {
      _fetchingGps = true;
      _position = null;
    });

    try {
      final position =
      await _locationService.fetchCurrentPosition();

      if (!mounted) return;

      setState(() {
        _position = position;
      });

      _message('GPS location acquired!');
    } on LocationServiceDisabled {
      if (!mounted) return;

      final open = await showDialog<bool>(
        context: context,
        builder: (dialog) {
          return AlertDialog(
            title: const Text('GPS is disabled'),
            content: const Text(
              'Turn on Location Services '
                  'to geotag your photo.',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialog, false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(dialog, true),
                child: const Text('SETTINGS'),
              ),
            ],
          );
        },
      );

      if (open == true) {
        await _locationService.openLocationSettings();
      }
    } on LocationPermissionBlocked {
      _message(
        'Location permission blocked. '
            'Please enable it in app settings.',
        error: true,
      );

      await _locationService.openAppSettings();
    } on LocationPermissionRejected {
      _message(
        'Location permission denied.',
        error: true,
      );
    } catch (e) {
      _message(
        'GPS error: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _fetchingGps = false;
        });
      }
    }
  }

  // =====================================
  // SAVE DIARY ENTRY
  // =====================================

  Future<void> _saveEntry() async {
    if (_saving) return;

    if (_photo == null) {
      _message(
        'Choose a photo first.',
        error: true,
      );
      return;
    }

    if (_position == null) {
      _message(
        'Fetch GPS location first.',
        error: true,
      );
      return;
    }

    if (_caption.text.trim().isEmpty) {
      _message(
        'Write a caption first.',
        error: true,
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    String? copiedPath;

    try {
      final id =
      DateTime.now().microsecondsSinceEpoch.toString();

      copiedPath = await _storage.savePhoto(
        _photo!,
        id,
      );

      final pos = _position!;

      final entry = DiaryEntry(
        id: id,
        imagePath: copiedPath,
        caption: _caption.text.trim(),
        timestamp: _takenAt ?? DateTime.now(),
        latitude: pos.latitude,
        longitude: pos.longitude,
        altitude: pos.altitude,
        accuracy: pos.accuracy,
      );

      final newEntries = [
        entry,
        ..._entries,
      ];

      await _storage.saveEntries(newEntries);

      if (!mounted) return;

      setState(() {
        _entries = newEntries;
        _photo = null;
        _position = null;
        _takenAt = null;
        _caption.clear();
      });

      _message('Your moment was saved!');
    } catch (e) {
      if (copiedPath != null) {
        await _storage.deletePhoto(copiedPath);
      }

      _message(
        'Save failed: $e',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // =====================================
  // FAVORITES
  // =====================================

  Future<void> _toggleFavorite(
      DiaryEntry entry,
      ) async {
    try {
      final updated = _entries.map((e) {
        if (e.id == entry.id) {
          return e.copyWith(
            favorite: !e.favorite,
          );
        }
        return e;
      }).toList();

      await _storage.saveEntries(updated);

      if (mounted) {
        setState(() {
          _entries = updated;
        });
      }
    } catch (e) {
      _message(
        'Favorite error: $e',
        error: true,
      );
    }
  }

  // =====================================
  // DELETE ENTRY
  // =====================================

  Future<void> _deleteEntry(
      DiaryEntry entry,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) {
        return AlertDialog(
          title: const Text(
            'Delete this memory?',
          ),
          content: const Text(
            'The photo and metadata will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialog, false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialog, true),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    try {
      final updated = _entries
          .where((e) => e.id != entry.id)
          .toList();

      await _storage.saveEntries(updated);

      if (mounted) {
        setState(() {
          _entries = updated;
        });
      }

      await _storage.deletePhoto(entry.imagePath);

      _message('Memory deleted.');
    } catch (e) {
      _message(
        'Delete error: $e',
        error: true,
      );
    }
  }

  // =====================================
  // UI HELPERS
  // =====================================

  Widget _heading(
      String title,
      String subtitle,
      ) {
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
            fontSize: 12,
            color: Colors.black45,
          ),
        ),
      ],
    );
  }

  Widget _info(
      String name,
      String value,
      IconData icon,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: sage,
            size: 19,
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(
              color: Colors.black54,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =====================================
  // MAIN SCREEN
  // =====================================

  @override
  Widget build(BuildContext context) {
    final filtered = _entries.where((entry) {
      return entry.caption
          .toLowerCase()
          .contains(_search.toLowerCase()) &&
          (!_favoritesOnly || entry.favorite);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: background,
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
                const Icon(
                  Icons.auto_awesome,
                  color: sage,
                  size: 25,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Collect moments,\nnot things.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 35,
                    color: green,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'YOUR PERSONAL GEOTAGGED PHOTO JOURNAL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: sage,
                  ),
                ),
                const SizedBox(height: 30),

                // PHOTO SECTION
                _heading(
                  'Capture a memory',
                  'Every place has a story worth remembering.',
                ),
                const SizedBox(height: 18),

                PhotoPreview(
                  photo: _photo,
                  onTap: _showSourceSheet,
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _picking
                            ? null
                            : () => _pickPhoto(
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
                        onPressed: _picking
                            ? null
                            : () => _pickPhoto(
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

                // GPS INFORMATION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      _info(
                        'Latitude',
                        _position?.latitude
                            .toStringAsFixed(6) ??
                            'Not fetched',
                        Icons.place_outlined,
                      ),
                      _info(
                        'Longitude',
                        _position?.longitude
                            .toStringAsFixed(6) ??
                            'Not fetched',
                        Icons.explore_outlined,
                      ),
                      _info(
                        'Accuracy',
                        _position == null
                            ? '—'
                            : '±${_position!.accuracy.toStringAsFixed(1)} m',
                        Icons.my_location_outlined,
                      ),
                      _info(
                        'Altitude',
                        _position == null
                            ? '—'
                            : '${_position!.altitude.toStringAsFixed(1)} m',
                        Icons.terrain_outlined,
                      ),
                      _info(
                        'Timestamp',
                        _takenAt == null
                            ? '—'
                            : _formatTime(_takenAt!),
                        Icons.schedule_outlined,
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _fetchingGps
                              ? null
                              : _fetchLocation,
                          style: FilledButton.styleFrom(
                            backgroundColor: sage,
                          ),
                          icon: _fetchingGps
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.gps_fixed,
                          ),
                          label: Text(
                            _fetchingGps
                                ? 'LOCATING...'
                                : 'FETCH CURRENT GPS',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 27),

                // CAPTION
                _heading(
                  'Your story',
                  'Give this moment a meaningful name.',
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: _caption,
                  maxLength: 120,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText:
                    'e.g. An unforgettable day at Narxoz...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(17),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // SAVE BUTTON
                SizedBox(
                  height: 55,
                  child: FilledButton.icon(
                    onPressed:
                    _saving ? null : _saveEntry,
                    style: FilledButton.styleFrom(
                      backgroundColor: green,
                    ),
                    icon: _saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.bookmark_add_outlined,
                    ),
                    label: Text(
                      _saving
                          ? 'SAVING...'
                          : 'SAVE ENTRY TO DIARY',
                    ),
                  ),
                ),

                const SizedBox(height: 36),
                const Divider(),
                const SizedBox(height: 20),

                // DIARY FEED
                _heading(
                  'The Memory Collection',
                  '${_entries.length} moments preserved',
                ),
                const SizedBox(height: 18),

                // SEARCH
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _search = value;
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
                      borderRadius:
                      BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                // FAVORITES FILTER
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilterChip(
                    label: const Text('Favorites only'),
                    avatar: const Icon(
                      Icons.favorite_border,
                      size: 17,
                    ),
                    selected: _favoritesOnly,
                    onSelected: (selected) {
                      setState(() {
                        _favoritesOnly = selected;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // DIARY ITEMS
                if (_loading)
                  const Center(
                    child: CircularProgressIndicator(),
                  )
                else if (filtered.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(20),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 45,
                          color: sage,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No memories here yet.',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 21,
                            color: green,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...filtered.map(
                        (entry) => DiaryEntryCard(
                      key: ValueKey(entry.id),
                      entry: entry,
                      onFavorite: () =>
                          _toggleFavorite(entry),
                      onDelete: () =>
                          _deleteEntry(entry),
                    ),
                  ),

                const SizedBox(height: 20),

                const Center(
                  child: Text(
                    'LUNA MOMENTS  •  MADE WITH MEMORIES',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.5,
                      color: sage,
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
