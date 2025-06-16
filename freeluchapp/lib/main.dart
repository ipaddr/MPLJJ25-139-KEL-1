// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:freeluchapp/firebase_options.dart'; // Pastikan path ini benar
import 'package:freeluchapp/guru/home_page_guru.dart'; // Import HomePageGuru Anda
import 'package:freeluchapp/login.dart'; // Import LoginPage Anda
import 'package:intl/date_symbol_data_local.dart'; // Import untuk inisialisasi data lokal
import 'package:flutter_localizations/flutter_localizations.dart'; // Import untuk delegates lokal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('id', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Freen Lunch App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('id', 'ID')],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('AUTH_WRAPPER_DEBUG: Menunggu status autentikasi...');
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          print(
            'AUTH_WRAPPER_DEBUG: Terjadi error pada stream autentikasi: ${snapshot.error}',
          );
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          print(
            'AUTH_WRAPPER_DEBUG: Pengguna LOGIN: ${user?.email ?? 'Unknown User'}',
          );
          return const HomePageGuru(); // Jika pengguna sudah login, arahkan ke HomePageGuru
        } else {
          print('AUTH_WRAPPER_DEBUG: Pengguna LOGOUT / BELUM LOGIN.');
          return SimpleLoginPage(); // Jika pengguna belum login, arahkan ke LoginPage
        }
      },
    );
  }
}
