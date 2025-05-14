import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_page.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fungsi konfirmasi dan logout
  void _konfirmasiLogout() async {
    bool? keluar = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Logout'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (keluar == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SimpleLoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSidebar(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFF),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: const Text(
          'Freen Lunch App',
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFF1F355D),
        child: GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _menuCard(Icons.dashboard, "Dashboard"),
            _menuCard(Icons.school, "Sekolah"),
            _menuCard(Icons.receipt_long, "Laporan Makan Siswa"),
            _menuCard(Icons.bar_chart, "Statistik"),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFDDEEFF),
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.logout), label: 'Log out'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else if (index == 2) {
            _konfirmasiLogout();
          }
        },
      ),
    );
  }

  Widget _menuCard(IconData icon, String label) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman masing-masing
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.black),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFDDEEFF)),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
                  radius: 30,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nama Akun",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                  ),
                  child: const Text(
                    "Online",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, "Dashboard", () {}),
          _drawerItem(Icons.school, "Sekolah", () {}),
          _drawerItem(Icons.receipt_long, "Laporan Makan Siswa", () {}),
          _drawerItem(Icons.bar_chart, "Statistik", () {}),
          _drawerItem(Icons.person, "Profil", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          }),
          _drawerItem(Icons.logout, "Log Out", _konfirmasiLogout),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Tutup drawer dulu
        onTap();
      },
    );
  }
}
