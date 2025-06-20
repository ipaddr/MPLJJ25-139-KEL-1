import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart';
import 'package:freeluchapp/guru/tambah_jadwal_menu_guru.dart'; // Import halaman tambah
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru (path disesuaikan)

class JadwalMenuGuruPage extends StatefulWidget {
  const JadwalMenuGuruPage({super.key});

  @override
  State<JadwalMenuGuruPage> createState() => _JadwalMenuGuruPageState();
}

class _JadwalMenuGuruPageState extends State<JadwalMenuGuruPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime
      .now(); // Ubah nama variabel menjadi _selectedDate untuk konsistensi
  String _userSchoolId = ''; // Menyimpan ID sekolah guru
  List<Map<String, dynamic>> _menuItems =
      []; // Mengganti 'jadwal' dengan _menuItems
  bool _isLoading = true; // State untuk loading data

  @override
  void initState() {
    super.initState();
    _loadUserSchoolId().then((_) {
      if (_userSchoolId.isNotEmpty) {
        _fetchDailyMenu(
            _selectedDate); // Ambil menu untuk tanggal dan sekolah saat ini
      } else {
        setState(() {
          _isLoading = false; // Selesai loading jika schoolId tidak ditemukan
        });
      }
    });
  }

  // Fungsi untuk memuat ID sekolah guru yang sedang login
  Future<void> _loadUserSchoolId() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          if (mounted) {
            setState(() {
              _userSchoolId = userDoc.get('schoolId') ?? '';
            });
          }
        } else {
          print(
              "Dokumen user tidak ditemukan di Firestore untuk UID: ${currentUser.uid}");
        }
      } catch (e) {
        print("Error memuat ID sekolah pengguna: $e");
      }
    } else {
      print("Tidak ada pengguna yang login.");
    }
  }

  // Fungsi untuk mengambil menu harian berdasarkan tanggal dan schoolId
  Future<void> _fetchDailyMenu(DateTime date) async {
    if (_userSchoolId.isEmpty) {
      if (mounted) {
        setState(() {
          _menuItems = [];
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true; // Mulai loading saat fetching
      });
    }

    // Atur tanggal ke awal hari dan akhir hari untuk kueri yang akurat
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      QuerySnapshot menuSnapshot = await _firestore
          .collection('daily_menus')
          .where('schoolId', isEqualTo: _userSchoolId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .limit(1) // Harusnya hanya ada 1 dokumen menu per sekolah per hari
          .get();

      if (mounted) {
        setState(() {
          _menuItems = []; // Reset menu items
          if (menuSnapshot.docs.isNotEmpty) {
            List<dynamic>? items = menuSnapshot.docs.first.get('menuItems');
            if (items != null) {
              _menuItems =
                  items.map((item) => item as Map<String, dynamic>).toList();
            }
          }
          _isLoading = false; // Selesai loading
        });
      }
    } catch (e) {
      print("Error fetching daily menu: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat menu harian: $e')),
        );
        setState(() {
          _isLoading = false; // Selesai loading meski ada error
        });
      }
    }
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
      _fetchDailyMenu(_selectedDate); // Muat menu untuk tanggal yang dipilih
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy', // Format tanggal lebih lengkap, pastikan 'yyyy'
      'id_ID',
    ).format(_selectedDate); // Menggunakan _selectedDate yang baru

    return Scaffold(
      backgroundColor: const Color(0xFF1C355E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBEAFF),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Lihat Jadwal & Menu Harian',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: const AppDrawerGuru(), // Tambahkan drawer di sini
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  // Tombol 'Tambah' akan dinonaktifkan jika schoolId belum dimuat
                  onPressed: _userSchoolId.isEmpty
                      ? null
                      : () async {
                          // Navigasi ke halaman tambah jadwal menu
                          // Meneruskan tanggal yang dipilih dan schoolId
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TambahJadwalMenuGuruPage(
                                selectedDate:
                                    _selectedDate, // Gunakan _selectedDate
                                schoolId: _userSchoolId, // Teruskan schoolId
                              ),
                            ),
                          );
                          // Setelah kembali dari halaman tambah, muat ulang menu untuk tanggal yang sama
                          _fetchDailyMenu(_selectedDate);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBEAFF),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white)) // Tampilkan loading indicator
                  : _menuItems.isEmpty
                      ? Center(
                          child: Text(
                            _userSchoolId.isEmpty
                                ? 'Memuat ID sekolah...' // Pesan saat schoolId belum dimuat
                                : 'Tidak ada menu untuk tanggal ini.', // Pesan jika tidak ada menu
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        )
                      : ListView(
                          children: [
                            Table(
                              border: TableBorder.all(color: Colors.white),
                              columnWidths: const {
                                0: FlexColumnWidth(2),
                                1: FlexColumnWidth(4),
                              },
                              children: [
                                const TableRow(
                                  decoration:
                                      BoxDecoration(color: Color(0xFF1C355E)),
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Waktu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'Menu',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                for (var item
                                    in _menuItems) // Menggunakan _menuItems
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1C355E),
                                    ),
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item['time'] ??
                                              '-', // Menggunakan 'time' field
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          item['foodName'] ??
                                              '-', // Menggunakan 'foodName' field
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
