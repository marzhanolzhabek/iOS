
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'lab12/cubit/auth_cubit.dart';
import 'lab12/bloc/cart_bloc.dart';
import 'lab12/screens/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LunaModeApp());
}

class LunaModeApp extends StatelessWidget {
  const LunaModeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'LUNA MODE | Lab 12',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor:
          const Color(0xFFF8F5F0),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFB49363),
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
