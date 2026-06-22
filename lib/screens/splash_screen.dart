import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final String? token;

  const SplashScreen({super.key, this.token});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Timer delay 3 detik untuk Splash Screen
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      // Mempertahankan logika login / logout asli kamu
      if (widget.token != null && widget.token!.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(token: widget.token!),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Menampilkan logo aplikasi
            Image.asset(
              'assets/LOGO MY ANTRIAN.png',
              height: 130, // Sedikit diperkecil agar proporsional dengan teks
            ),
            const SizedBox(height: 16),

            // 2. TAMBAHAN: Menampilkan nama aplikasi dengan desain yang sinkron dengan Login Screen
            const Text(
              "My Antrian",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 40),

            // 3. Loading indicator di bagian bawah
            const CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
