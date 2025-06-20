import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freeluchapp/login.dart';
import 'package:freeluchapp/guru/home_page_guru.dart';
import 'package:freeluchapp/guru/jadwal_menu_guru.dart';
import 'package:freeluchapp/guru/laporan_riwayat_siswa.dart';
import 'package:freeluchapp/guru/konfirmasi_makan_siswa.dart'; // Untuk halaman konfirmasi harian
import 'package:freeluchapp/guru/tambah_siswa.dart'; // <<< Import halaman Tambah Siswa Baru

class AppDrawerGuru extends StatefulWidget {
  const AppDrawerGuru({super.key});

  @override
  State<AppDrawerGuru> createState() => _AppDrawerGuruState();
}

class _AppDrawerGuruState extends State<AppDrawerGuru> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  void _confirmLogout() async {
    // Pastikan context masih valid sebelum menampilkan dialog
    if (!mounted) {
      print('DEBUG: _confirmLogout dipanggil tapi widget tidak lagi mounted.');
      return;
    }

    print('DEBUG: _confirmLogout dipanggil. Menampilkan dialog konfirmasi...');
    final logoutConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () {
                print('DEBUG: Tombol Batal diklik.');
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                print('DEBUG: Tombol Logout diklik.');
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (logoutConfirmed ?? false) {
      print(
        'DEBUG: Konfirmasi Logout diterima. Mencoba signOut dari Firebase...',
      );
      try {
        await FirebaseAuth.instance.signOut();
        print(
          'DEBUG: Firebase signOut berhasil! Navigasi manual ke halaman login.',
        );
        // *** PENTING: MENGGUNAKAN NAVIGATOR.PUSHREPLACEMENT UNTUK KONSISTENSI DENGAN ADMIN DRAWER ***
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SimpleLoginPage()),
        );
      } catch (e) {
        print('ERROR: Firebase signOut gagal: ${e.toString()}');
        // Tampilkan pesan error ke pengguna
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: ${e.toString()}')),
          );
        }
        return; // Hentikan eksekusi jika signOut gagal
      }

      print('DEBUG: Proses _confirmLogout selesai. Navigasi telah dilakukan.');
    } else {
      print('DEBUG: Logout dibatalkan oleh pengguna.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: const Color(0xFF1F355D),
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue[700]),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.email ?? 'Guru Tamu',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Online',
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Navigasi internal ke halaman-halaman guru
          _buildDrawerItem(Icons.dashboard, 'Dashboard', () {
            // Tutup drawer sebelum navigasi
            Navigator.of(context).pop();
            // Gunakan pushReplacement agar tidak menumpuk halaman yang sama
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomePageGuru()),
            );
          }),
          _buildDrawerItem(Icons.calendar_today, 'Jadwal & Menu', () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const JadwalMenuGuruPage()),
            );
          }),
          _buildDrawerItem(Icons.history, 'Laporan Riwayat Makan', () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LaporanRiwayatSiswa()),
            );
          }),
          _buildDrawerItem(Icons.check_circle_outline, 'Konfirmasi Makan', () {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const KonfirmasiMakanSiswa()),
            );
          }),
          // <<< ITEM MENU BARU UNTUK TAMBAH SISWA >>>
          _buildDrawerItem(Icons.person_add, 'Tambah Siswa', () async {
            Navigator.of(context).pop(); // Tutup drawer

            // Ambil schoolId dari profil guru yang login untuk diteruskan
            // Ini memerlukan Firestore, jadi pastikan sudah diinisialisasi
            String? schoolId;
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              try {
                DocumentSnapshot userDoc = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser.uid)
                    .get();
                if (userDoc.exists && userDoc.data() != null) {
                  schoolId = userDoc.get('schoolId') ?? '';
                }
              } catch (e) {
                print("Error getting schoolId for Tambah Siswa: $e");
                // Tampilkan pesan error ke pengguna jika schoolId tidak bisa diambil
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Gagal memuat ID sekolah untuk menambah siswa: $e')),
                );
                return; // Hentikan navigasi
              }
            }

            if (schoolId != null && schoolId.isNotEmpty) {
              Navigator.push(
                // Gunakan push, bukan pushReplacement, agar bisa kembali ke drawer
                context,
                MaterialPageRoute(
                    builder: (_) => TambahSiswaPage(schoolId: schoolId!)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text(
                        'Anda tidak terhubung ke sekolah mana pun untuk menambah siswa.')),
              );
            }
          }),
          // <<< AKHIR ITEM MENU BARU >>>
          const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),

          // Bagian Logout
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

  // Helper method to build drawer items with consistent styling
  Widget _buildDrawerItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
