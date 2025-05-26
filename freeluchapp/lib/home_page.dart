import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'sekolah_page.dart';
import 'laporan_makan_siang_page.dart';
import 'statistik_page.dart';
import 'dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

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
          'Free Lunch App',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        color: const Color(0xFF1F355D),
        child: GridView.count(
          padding: const EdgeInsets.all(24),
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _menuCard(Icons.dashboard, "Dashboard", () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            }),
            _menuCard(Icons.school, "Sekolah", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SekolahPage()),
              );
            }),
            _menuCard(Icons.receipt_long, "Laporan Makan Siswa", () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LaporanMakanSiangPage(),
                ),
              );
            }),
            _menuCard(Icons.bar_chart, "Statistik", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatistikPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String label, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
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
                Text(
                  user?.email ?? "Pengguna",
                  style: const TextStyle(fontWeight: FontWeight.bold),
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
          _drawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }),

          _drawerItem(Icons.school, "Sekolah", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SekolahPage()),
            );
          }),
          _drawerItem(Icons.receipt_long, "Laporan Makan Siswa", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LaporanMakanSiangPage()),
            );
          }),
          _drawerItem(Icons.bar_chart, "Statistik", () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatistikPage()),
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
        Navigator.pop(context); // Menutup drawer
        onTap();
      },
    );
  }
}
