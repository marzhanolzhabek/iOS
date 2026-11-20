
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_item.dart';
import '../services/local_storage_service.dart';

class NotesScreen extends StatefulWidget {
  final bool initialDarkMode;

  const NotesScreen({
    super.key,
    required this.initialDarkMode,
  });

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  static const gold = Color(0xFFB99865);

  late bool isDarkMode;

  String username = 'Guest User';
  String selectedMood = 'Calm';
  String selectedCategory = 'All';
  String searchQuery = '';

  List<NoteItem> notes = [];
  bool isLoading = true;
  bool showCelebration = false;

  final usernameController = TextEditingController();
  final noteController = TextEditingController();
  final searchController = TextEditingController();

  final categories = [
    'All',
    'Personal',
    'Study',
    'Work',
    'Ideas',
  ];

  final moods = [
    'Happy',
    'Calm',
    'Motivated',
    'Tired',
  ];

  String newNoteCategory = 'Personal';

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.initialDarkMode;
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    try {
      final savedUsername =
      await LocalStorageService.loadUsername();

      final savedNotes =
      await LocalStorageService.loadNotes();

      final prefs = await SharedPreferences.getInstance();

      final mood = prefs.getString('luna_mood') ?? 'Calm';

      if (!mounted) return;

      setState(() {
        username = savedUsername;
        usernameController.text =
        savedUsername == 'Guest User' ? '' : savedUsername;
        notes = savedNotes;
        selectedMood = moods.contains(mood) ? mood : 'Calm';
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      showMessage('Could not load saved data');
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> changeTheme(bool value) async {
    setState(() => isDarkMode = value);

    try {
      await LocalStorageService.saveTheme(value);
    } catch (e) {
      if (!mounted) return;
      setState(() => isDarkMode = !value);
      showMessage('Could not save theme');
    }
  }

  Future<void> saveUsername() async {
    final value = usernameController.text.trim();
    final name = value.isEmpty ? 'Guest User' : value;

    try {
      await LocalStorageService.saveUsername(name);

      if (!mounted) return;

      setState(() => username = name);
      showMessage('Profile saved successfully');
    } catch (e) {
      showMessage('Could not save profile');
    }
  }

  Future<void> changeMood(String mood) async {
    setState(() => selectedMood = mood);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('luna_mood', mood);
    } catch (e) {
      showMessage('Could not save mood');
    }
  }

  Future<void> addNote() async {
    final title = noteController.text.trim();

    if (title.isEmpty) {
      showMessage('Please write a note first');
      return;
    }

    final now = DateTime.now();

    final note = NoteItem(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      dateText:
      '${now.day.toString().padLeft(2, '0')}.'
          '${now.month.toString().padLeft(2, '0')}.'
          '${now.year}',
      isCompleted: false,
    );

    final updatedNotes = [note, ...notes];

    try {
      await LocalStorageService.saveNotes(updatedNotes);

      if (!mounted) return;

      setState(() {
        notes = updatedNotes;
        noteController.clear();
        showCelebration = false;
      });

      // Category is saved separately using the note ID.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'luna_category_${note.id}',
        newNoteCategory,
      );
    } catch (e) {
      showMessage('Could not save note');
    }
  }

  Future<void> toggleNote(int index, bool value) async {
    final updatedNotes = List<NoteItem>.from(notes);

    updatedNotes[index] = updatedNotes[index].copyWith(
      isCompleted: value,
    );

    try {
      await LocalStorageService.saveNotes(updatedNotes);

      if (!mounted) return;

      setState(() {
        notes = updatedNotes;
        showCelebration = notes.isNotEmpty &&
            notes.every((note) => note.isCompleted);
      });
    } catch (e) {
      showMessage('Could not update note');
    }
  }

  Future<void> deleteNote(int index) async {
    final note = notes[index];
    final updatedNotes = List<NoteItem>.from(notes)
      ..removeAt(index);

    try {
      await LocalStorageService.saveNotes(updatedNotes);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('luna_category_${note.id}');

      if (!mounted) return;

      setState(() {
        notes = updatedNotes;
        showCelebration = false;
      });
    } catch (e) {
      showMessage('Could not delete note');
    }
  }

  Future<String> getNoteCategory(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('luna_category_$id') ?? 'Personal';
  }

  int get completedCount =>
      notes.where((note) => note.isCompleted).length;

  double get progress =>
      notes.isEmpty ? 0 : completedCount / notes.length;

  String get motivation {
    final quotes = [
      'Small steps create big changes.',
      'Your future begins with what you do today.',
      'Make today your masterpiece.',
      'Progress matters more than perfection.',
      'Dream big. Start small. Stay consistent.',
      'You are capable of amazing things.',
      'Every completed task is a little victory.',
    ];

    return quotes[DateTime.now().day % quotes.length];
  }

  Color get background =>
      isDarkMode ? const Color(0xFF141414) : const Color(0xFFF8F5F0);

  Color get cardColor =>
      isDarkMode ? const Color(0xFF242424) : Colors.white;

  Color get textColor =>
      isDarkMode ? Colors.white : const Color(0xFF211E1A);

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: textColor,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
    );
  }

  Widget panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: gold.withValues(alpha: 0.16),
        ),
      ),
      child: child,
    );
  }

  Widget buildMoodTracker() {
    final moodIcons = {
      'Happy': Icons.sentiment_very_satisfied_outlined,
      'Calm': Icons.spa_outlined,
      'Motivated': Icons.bolt_outlined,
      'Tired': Icons.bedtime_outlined,
    };

    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('HOW ARE YOU FEELING?'),
          const SizedBox(height: 8),
          Text(
            'Choose your mood for today',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: moods.map((mood) {
              final selected = selectedMood == mood;

              return ChoiceChip(
                avatar: Icon(
                  moodIcons[mood],
                  size: 18,
                  color: selected ? Colors.black : gold,
                ),
                label: Text(mood),
                selected: selected,
                selectedColor: gold,
                onSelected: (_) => changeMood(mood),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildProgress() {
    return panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionTitle('DAILY PROGRESS'),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${(progress * 100).round()}%',
                style: TextStyle(
                  color: gold,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '$completedCount of ${notes.length} notes completed',
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            color: gold,
            backgroundColor: gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          if (showCelebration) ...[
            const SizedBox(height: 16),
            const Text(
              '✦ ✧ ✦  AMAZING! ALL DONE!  ✦ ✧ ✦',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildNoteCard(NoteItem note, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: gold.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: note.isCompleted,
            activeColor: gold,
            onChanged: (value) =>
                toggleNote(index, value ?? false),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    decoration: note.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  note.dateText,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => deleteNote(index),
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    noteController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = notes.asMap().entries.where((entry) {
      return entry.value.title
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
    }).toList();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: gold,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: gold,
      ),
      home: Scaffold(
        backgroundColor: background,
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 760,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'LUNA NOTES',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'YOUR PERSONAL UNIVERSE',
                            style: TextStyle(
                              color: gold,
                              fontSize: 10,
                              letterSpacing: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Hello, $username',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      motivation,
                      style: const TextStyle(
                        color: gold,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 26),

                    panel(
                      child: Column(
                        children: [
                          SwitchListTile(
                            title: const Text('Dark Mode'),
                            subtitle: const Text(
                              'Personalize your space',
                            ),
                            value: isDarkMode,
                            activeThumbColor: gold,
                            onChanged: changeTheme,
                          ),
                          const Divider(),
                          TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Your username',
                              prefixIcon: Icon(
                                Icons.person_outline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: saveUsername,
                              child: const Text('SAVE PROFILE'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    buildMoodTracker(),

                    const SizedBox(height: 18),
                    buildProgress(),

                    const SizedBox(height: 28),
                    sectionTitle('CREATE A NOTE'),
                    const SizedBox(height: 14),

                    panel(
                      child: Column(
                        children: [
                          TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              hintText: 'What is on your mind?',
                              prefixIcon: Icon(Icons.edit_note),
                            ),
                            onSubmitted: (_) => addNote(),
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            initialValue: newNoteCategory,
                            decoration: const InputDecoration(
                              labelText: 'Category',
                              prefixIcon: Icon(
                                Icons.category_outlined,
                              ),
                            ),
                            items: categories
                                .where((c) => c != 'All')
                                .map(
                                  (category) =>
                                  DropdownMenuItem(
                                    value: category,
                                    child: Text(category),
                                  ),
                            )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  newNoteCategory = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: addNote,
                              icon: const Icon(Icons.add),
                              label: const Text('ADD NOTE'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    sectionTitle('MY COLLECTION'),
                    const SizedBox(height: 14),

                    TextField(
                      controller: searchController,
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search your notes...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: cardColor,
                        border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (filteredNotes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            notes.isEmpty
                                ? 'Your story starts with one note.'
                                : 'No matching notes found.',
                            style: TextStyle(
                              color: textColor.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ...filteredNotes.map(
                          (entry) => buildNoteCard(
                        entry.value,
                        entry.key,
                      ),
                    ),

                    const SizedBox(height: 30),
                    Center(
                      child: Text(
                        'LUNA NOTES  •  MADE FOR YOUR MOMENTS',
                        style: TextStyle(
                          color: textColor.withValues(
                            alpha: 0.4,
                          ),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
