import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:freeluchapp/app_drawer_guru.dart'; // Drawer untuk navigasi guru

class HomePageGuru extends StatefulWidget {
  const HomePageGuru({super.key});

  @override
  State<HomePageGuru> createState() => _HomePageGuruState();
}

class _HomePageGuruState extends State<HomePageGuru> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userName = 'Pengguna';
  String _userSchoolId = '';
  int _confirmedStudentsToday = 0;
  String _menuToday = 'Memuat menu...'; // Ubah initial state
  bool _isLoading = true; // State untuk loading dashboard

  @override
  void initState() {
    super.initState();
    _loadUserDataAndDashboard();
  }

  // Fungsi untuk memuat data pengguna dan data dashboard
  Future<void> _loadUserDataAndDashboard() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Handle jika tidak ada user login, mungkin redirect ke login page
      print("Tidak ada pengguna yang login.");
      // Tambahkan logika navigasi ke halaman login jika user tidak login
      return;
    }

    try {
      // 1. Ambil data user dari Firestore untuk mendapatkan nama dan schoolId
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _userName = userDoc.get('name') ?? currentUser.email ?? 'Pengguna';
          _userSchoolId = userDoc.get('schoolId') ?? '';
        });

        if (_userSchoolId.isNotEmpty) {
          await _fetchDashboardData(
              _userSchoolId); // Ambil data dashboard jika schoolId ditemukan
        } else {
          setState(() {
            _menuToday = 'Anda belum terhubung ke sekolah mana pun.';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _userName = currentUser.email ?? 'Pengguna';
          _menuToday = 'Data profil Anda tidak ditemukan.';
          _isLoading = false;
        });
        print(
            "Dokumen user tidak ditemukan di Firestore untuk UID: ${currentUser.uid}");
      }
    } catch (e) {
      print("Error memuat data pengguna atau dashboard: $e");
      if (mounted) {
        setState(() {
          _userName = currentUser.email ?? 'Pengguna';
          _menuToday = 'Gagal memuat data dashboard.';
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi untuk mengambil data dashboard (jumlah siswa makan dan menu hari ini)
  Future<void> _fetchDashboardData(String schoolId) async {
    DateTime now = DateTime.now();
    // Atur tanggal ke awal hari ini untuk kueri yang akurat
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    try {
      // Ambil jumlah siswa makan hari ini (status Confirmed)
      QuerySnapshot confirmedMeals = await _firestore
          .collection('meal_confirmations')
          .where('schoolId', isEqualTo: schoolId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .where('status', isEqualTo: 'Confirmed')
          .get();

      // Ambil menu hari ini
      QuerySnapshot dailyMenu = await _firestore
          .collection('daily_menus')
          .where('schoolId', isEqualTo: schoolId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .limit(1) // Harusnya hanya ada 1 dokumen menu per sekolah per hari
          .get();

      if (mounted) {
        setState(() {
          _confirmedStudentsToday = confirmedMeals.docs.length;
          if (dailyMenu.docs.isNotEmpty) {
            List<dynamic> menuItems = dailyMenu.docs.first.get('menuItems');
            if (menuItems.isNotEmpty) {
              // Gabungkan nama-nama makanan dari menuItems
              _menuToday = menuItems
                  .map((item) => item['foodName']?.toString() ?? '')
                  .join(', ');
              if (_menuToday.isEmpty) {
                _menuToday =
                    'Menu belum tersedia.'; // Jika foodName kosong semua
              }
            } else {
              _menuToday = 'Menu belum tersedia.';
            }
          } else {
            _menuToday = 'Menu belum tersedia.';
          }
          _isLoading = false; // Selesai loading
        });
      }
    } catch (e) {
      print("Error mengambil data dashboard: $e");
      if (mounted) {
        setState(() {
          _confirmedStudentsToday = 0;
          _menuToday = 'Gagal memuat menu atau jumlah siswa.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Lunch App'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: const AppDrawerGuru(), // Menggunakan drawer untuk navigasi guru
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Tampilkan loading indicator
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, $_userName !',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.blue[100],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.people,
                                    size: 40, color: Colors.blue),
                                const SizedBox(height: 10),
                                const Text('Siswa Makan Hari Ini',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text('$_confirmedStudentsToday Siswa',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Colors.lightGreen[100],
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.restaurant_menu,
                                    size: 40, color: Colors.lightGreen),
                                const SizedBox(height: 10),
                                const Text('Menu Hari Ini',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 5),
                                Text(_menuToday,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.lightGreen)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Anda bisa menambahkan 'Informasi Terkini' di sini
                  // Misalnya: daftar siswa yang baru dikonfirmasi atau notifikasi penting
                  const Text(
                    'Informasi Terkini:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Center(
                        child: Text(
                            'Tidak ada informasi terkini yang tersedia.',
                            style: TextStyle(color: Colors.grey[600]))),
                  ),
                ],
              ),
            ),
    );
  }
}
