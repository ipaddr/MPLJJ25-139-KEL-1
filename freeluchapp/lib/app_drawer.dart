import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'home_page.dart';
import 'sekolah_page.dart';
import 'laporan_makan_siang_page.dart';
import 'login.dart';
import 'statistik_page.dart';
import 'dashboard_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _konfirmasiLogout() async {
    final keluar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah yakin ingin keluar?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (keluar ?? false) {
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
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFDDEEFF)),
            child: Column(
              children: [
                const CircleAvatar(radius: 30),
                const SizedBox(height: 8),
                Text(
                  user?.email ?? 'Pengguna',
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
                    'Online',
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
          _drawerItem(Icons.school, 'Sekolah', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SekolahPage()),
            );
          }),
          _drawerItem(Icons.receipt_long, 'Laporan Makan Siswa', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LaporanMakanSiangPage()),
            );
          }),
          _drawerItem(Icons.bar_chart, 'Statistik', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StatistikPage()),
            );
          }),
          _drawerItem(Icons.logout, 'Log Out', _konfirmasiLogout),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: () async {
        Navigator.of(context).pop(); // Tutup drawer dulu
        await Future.delayed(
          const Duration(milliseconds: 200),
        ); // Tunggu animasi drawer
        onTap(); // Baru navigasi
      },
    );
  }
}
