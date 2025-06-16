import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freeluchapp/admin/sekolah_page.dart';
import 'package:freeluchapp/admin/laporan_makan_siang_page.dart';
import 'package:freeluchapp/login.dart';
import 'package:freeluchapp/admin/statistik_page.dart';
import 'package:freeluchapp/admin/dashboard_page.dart';

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

  void _confirmLogout() async {
    // Pastikan context masih valid sebelum menampilkan dialog
    if (!mounted) return;

    final logoutConfirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout'),
              ),
            ],
          ),
    );

    if (logoutConfirmed ?? false) {
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
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // MULAI DARI SINI PERUBAHAN UNTUK HEADER DRAWER
          Container(
            // Menggunakan warna background body dashboard untuk kohesivitas
            color: const Color(0xFF1F355D),
            // Padding atas dan bawah agar ada ruang
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              // Menengahkan semua konten di dalam Column secara horizontal
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      Colors.white, // Background putih untuk avatar
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue[700], // Warna icon yang serasi
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Guest User', // Email pengguna atau default
                  textAlign: TextAlign.center, // Pastikan teks juga rata tengah
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white, // Warna teks putih agar kontras
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    // Warna hijau cerah untuk indikator online
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ), // Teks hitam untuk kontras
                  ),
                ),
              ],
            ),
          ),
          // AKHIR PERUBAHAN UNTUK HEADER DRAWER

          // Drawer Items (sisanya sama, sudah bagus)
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }),
          _buildDrawerItem(Icons.school, 'Schools', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SekolahPage()),
            );
          }),
          _buildDrawerItem(Icons.receipt_long, 'Student Meal Report', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LaporanMakanSiangPage()),
            );
          }),
          _buildDrawerItem(Icons.bar_chart, 'Statistics', () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const StatistikPage()),
            );
          }),
          const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
          _buildDrawerItem(
            Icons.logout,
            'Log Out',
            _confirmLogout,
            isLogout: true,
          ),
        ],
      ),
    );
  }

  // Helper method to build drawer items with consistent styling (tidak ada perubahan di sini)
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (!isLogout) {
            Navigator.of(context).pop();
            await Future.delayed(const Duration(milliseconds: 250));
          }
          onTap();
        },
        hoverColor: isLogout ? Colors.red.shade100 : Colors.blue.shade50,
        splashColor: isLogout ? Colors.red.shade200 : Colors.blue.shade100,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: isLogout ? Colors.red[600] : Colors.blue[700]),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isLogout ? Colors.red[600] : Colors.black87,
                  fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
