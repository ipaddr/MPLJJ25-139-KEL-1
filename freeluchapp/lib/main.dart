import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🔍 Tambahkan ini
import 'firebase_options.dart';
import 'login.dart';
import 'home_page.dart'; // 🔍 Tambahkan ini

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Free Lunch App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const InitFirebase(),
    );
  }
}

class InitFirebase extends StatelessWidget {
  const InitFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          // ✅ Cek apakah user sudah login
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            return const HomePage(); // ✅ Jika sudah login
          } else {
            return const SimpleLoginPage(); // 🔐 Jika belum login
          }
        }
      },
    );
  }
}
