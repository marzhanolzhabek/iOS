
import 'package:flutter/material.dart';
import 'lab13/screens/photo_diary_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LunaMomentsApp());
}

class LunaMomentsApp extends StatelessWidget {
  const LunaMomentsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUNA MOMENTS | Lab 13',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F4EF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF718776),
        ),
      ),
      home: const PhotoDiaryScreen(),
    );
  }
}
