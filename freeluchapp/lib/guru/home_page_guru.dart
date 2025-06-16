import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru yang baru

class HomePageGuru extends StatefulWidget {
  const HomePageGuru({super.key});

  @override
  State<HomePageGuru> createState() => _HomePageGuruState();
}

class _HomePageGuruState extends State<HomePageGuru> {
  String siswaMakanHariIni = "Memuat...";
  String menuHariIni = "Memuat...";
  String _userName = "Guru";

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchDailyLunchData();
  }

  void _loadUserData() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email ?? "Pengguna";
      });
    } else {
      setState(() {
        _userName = "Tamu";
      });
    }
  }

  Future<void> _fetchDailyLunchData() async {
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      siswaMakanHariIni = "150 Siswa";
      menuHariIni = "Nasi Goreng Ayam";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF283547),
      appBar: AppBar(
        title: const Text(
          'Freen Lunch App',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1C2533),
        iconTheme: const IconThemeData(color: Colors.white),
        // Tidak ada actions di sini
      ),
      drawer: const AppDrawerGuru(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, $_userName !',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    context,
                    icon: Icons.group,
                    title: 'Siswa Makan Hari Ini',
                    value: siswaMakanHariIni,
                    valueColor: Colors.amberAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoCard(
                    context,
                    icon: Icons.fastfood,
                    title: 'Menu Hari Ini',
                    value: menuHariIni,
                    valueColor: Colors.lightBlueAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Center(
              child: Text(
                'Informasi Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Card(
      elevation: 5,
      color: const Color(0xFF3B4D61),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Colors.white70),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF283547),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
