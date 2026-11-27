
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool hidePassword = true;

  static const background = Color(0xFFF8F5F0);
  static const dark = Color(0xFF28231F);
  static const gold = Color(0xFFB49363);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration fieldDecoration(
      String label,
      IconData icon, {
        Widget? suffix,
      }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: gold),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(19),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFB83B45),
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.all(18),
              ),
            );
          }

          if (state is AuthSuccess) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CatalogScreen(
                  username: state.username,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 35,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.diamond_outlined,
                        size: 50,
                        color: gold,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'LUNA MODE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 39,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 6,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'THE ART OF ELEGANCE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: gold,
                          fontSize: 10,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 55),
                      const Text(
                        'Welcome back.',
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 30,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Sign in to discover your next favorite look.',
                        style: TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 30),
                      TextField(
                        controller: emailController,
                        enabled: state is! AuthLoading,
                        keyboardType: TextInputType.emailAddress,
                        decoration: fieldDecoration(
                          'Email address',
                          Icons.mail_outline,
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: passwordController,
                        enabled: state is! AuthLoading,
                        obscureText: hidePassword,
                        decoration: fieldDecoration(
                          'Password',
                          Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (state is AuthLoading)
                        const Center(
                          child: CircularProgressIndicator(
                            color: gold,
                          ),
                        )
                      else
                        SizedBox(
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () {
                              context.read<AuthCubit>().login(
                                emailController.text,
                                passwordController.text,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: dark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'SIGN IN',
                              style: TextStyle(
                                letterSpacing: 3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'DEMO ACCESS',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: gold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'student@narxoz.kz\n123456',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: 1.7,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 45),
                      const Text(
                        'LUNA MODE  •  EST. 2026',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
