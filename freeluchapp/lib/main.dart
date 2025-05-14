import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'login.dart';

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
      home: const InitFirebase(), // Ganti ke widget inisialisasi
    );
  }
}

class InitFirebase extends StatelessWidget {
  const InitFirebase({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform, // ✅ gunakan ini
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
          return const SimpleLoginPage(); // ✅ lanjutkan ke login jika sukses
        }
      },
    );
  }
}
