
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'lab9/providers/cart_provider.dart';
import 'lab9/screens/catalog_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: const LumiApp(),
    ),
  );
}

class LumiApp extends StatelessWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LUMI STORE',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F7FC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7555D9),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8F7FC),
          centerTitle: false,
        ),
      ),
      home: const CatalogScreen(),
    );
  }
}
