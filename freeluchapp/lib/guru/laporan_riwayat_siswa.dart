import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru (pastikan path ini benar)
import 'package:freeluchapp/guru/tambah_menu_siswa.dart'; // <<< PASTIKAN INI ADA DAN BENAR (nama file baru)

class LaporanRiwayatSiswa extends StatefulWidget {
  const LaporanRiwayatSiswa({Key? key}) : super(key: key);

  @override
  State<LaporanRiwayatSiswa> createState() => _LaporanRiwayatSiswaState();
}

class _LaporanRiwayatSiswaState extends State<LaporanRiwayatSiswa> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userSchoolId = '';
  List<Map<String, dynamic>> _students = [];
  String? _selectedStudentId; // UID siswa yang dipilih di dropdown
  Stream<QuerySnapshot>? _mealHistoryStream; // Stream untuk riwayat makan
  bool _isLoadingStudents = true; // State loading untuk daftar siswa
  final Map<String, String> _studentNamesCache = {}; // Cache nama siswa

  @override
  void initState() {
    super.initState();
    _loadUserSchoolIdAndStudents();
  }

  // Mengambil ID sekolah guru dan daftar siswa di sekolah tersebut
  Future<void> _loadUserSchoolIdAndStudents() async {
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
          if (_userSchoolId.isNotEmpty) {
            await _fetchStudents(_userSchoolId);
          } else {
            if (mounted) {
              setState(() {
                _isLoadingStudents = false;
              });
            }
            print("Guru tidak terhubung ke sekolah mana pun.");
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoadingStudents = false;
            });
          }
          print(
              "Dokumen user tidak ditemukan di Firestore untuk UID: ${currentUser.uid}");
        }
      } catch (e) {
        print("Error memuat ID sekolah pengguna atau siswa: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data awal: $e')),
          );
          setState(() {
            _isLoadingStudents = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
        });
      }
      print("Tidak ada pengguna yang login.");
      // Mungkin redirect ke halaman login
    }
  }

  // Mengambil daftar siswa untuk dropdown
  Future<void> _fetchStudents(String schoolId) async {
    try {
      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('schoolId', isEqualTo: schoolId)
          .orderBy('name')
          .get();

      if (mounted) {
        setState(() {
          _students = studentSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final studentName = data['name'] ?? 'Nama Tidak Tersedia';
            _studentNamesCache[doc.id] = studentName; // Cache nama siswa
            return {
              'id': doc.id,
              'name': studentName,
            };
          }).toList();

          // Atur siswa pertama sebagai default jika ada
          if (_students.isNotEmpty) {
            _selectedStudentId = _students.first['id'];
            _updateMealHistoryStream(); // Muat riwayat untuk siswa pertama
          }
          _isLoadingStudents = false; // Selesai loading siswa
        });
      }
    } catch (e) {
      print("Error fetching students: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar siswa: $e')),
        );
        setState(() {
          _isLoadingStudents = false;
        });
      }
    }
  }

  // Memperbarui stream riwayat makan berdasarkan siswa yang dipilih
  void _updateMealHistoryStream() {
    if (_selectedStudentId != null && _userSchoolId.isNotEmpty) {
      if (mounted) {
        setState(() {
          _mealHistoryStream = _firestore
              .collection('meal_confirmations')
              .where('studentId', isEqualTo: _selectedStudentId)
              .where('schoolId', isEqualTo: _userSchoolId)
              .orderBy('date', descending: true) // Urutkan dari tanggal terbaru
              .snapshots();
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _mealHistoryStream = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kondisi untuk menonaktifkan tombol tambah konfirmasi makan siswa
    final bool isAddConfirmationButtonDisabled = _userSchoolId.isEmpty ||
        _selectedStudentId ==
            null; // Tombol juga disabled jika belum ada siswa yang dipilih
    final String addConfirmationButtonTooltip = isAddConfirmationButtonDisabled
        ? 'Pilih siswa dan pastikan Anda terhubung dengan sekolah untuk menambah konfirmasi makan.'
        : 'Tambah Konfirmasi Makan untuk Siswa Terpilih';

    return Scaffold(
      backgroundColor: const Color(0xFF1C355E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBEAFF),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Laporan Riwayat Siswa',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: const AppDrawerGuru(), // Menggunakan AppDrawerGuru
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown Siswa
            _isLoadingStudents
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _students.isEmpty
                    ? const Center(
                        child: Text(
                            'Tidak ada siswa yang terdaftar di sekolah Anda.',
                            style: TextStyle(color: Colors.white)))
                    : Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStudentId,
                            icon: const Icon(Icons.arrow_drop_down),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedStudentId = newValue;
                              });
                              _updateMealHistoryStream(); // Muat ulang riwayat saat siswa berubah
                            },
                            items: _students.map((student) {
                              return DropdownMenuItem<String>(
                                value: student['id'] as String,
                                child: Text(student['name']! as String),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
            const SizedBox(height: 16),
            // Tabel data riwayat makan
            Expanded(
              child: _mealHistoryStream == null
                  ? const Center(
                      child: Text('Pilih siswa untuk melihat riwayat.',
                          style: TextStyle(color: Colors.white)))
                  : StreamBuilder<QuerySnapshot>(
                      stream: _mealHistoryStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white));
                        }
                        if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}',
                                  style: const TextStyle(color: Colors.red)));
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text(
                                  'Tidak ada riwayat makan untuk siswa ini.',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.8))));
                        }

                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            Map<String, dynamic> data =
                                doc.data() as Map<String, dynamic>;

                            String menu = (data['menuDetails'] != null &&
                                    data['menuDetails']['foodName'] != null)
                                ? data['menuDetails']['foodName']
                                : 'Menu Tidak Tersedia';
                            String jadwal = (data['menuDetails'] != null &&
                                    data['menuDetails']['mealType'] != null)
                                ? data['menuDetails']['mealType']
                                : 'Jadwal Tidak Tersedia';
                            String status = data['status'] ?? 'N/A';
                            Timestamp? dateTimestamp =
                                data['date'] as Timestamp?;
                            String formattedDate = dateTimestamp != null
                                ? DateFormat('dd MMMM (dd/MM/yyyy)')
                                    .format(dateTimestamp.toDate())
                                : 'Tanggal Tidak Tersedia';

                            // Menentukan warna chip berdasarkan status
                            Color statusBackgroundColor;
                            Color statusTextColor;
                            switch (status) {
                              case 'Confirmed':
                                statusBackgroundColor = Colors.green.shade200;
                                statusTextColor = Colors.green.shade800;
                                break;
                              case 'Cancelled':
                                statusBackgroundColor = Colors.red.shade200;
                                statusTextColor = Colors.red.shade800;
                                break;
                              case 'Pending':
                              default:
                                statusBackgroundColor = Colors.orange.shade200;
                                statusTextColor = Colors.orange.shade800;
                                break;
                            }

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              color: const Color(
                                  0xFF2C4A7A), // Warna card lebih terang dari background
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      formattedDate,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Jadwal: $jadwal',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8)),
                                    ),
                                    Text(
                                      'Menu: $menu',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8)),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: Chip(
                                        label: Text(status),
                                        backgroundColor: statusBackgroundColor,
                                        labelStyle: TextStyle(
                                            color: statusTextColor,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Tombol FloatingActionButton untuk menambah konfirmasi makan siswa
      floatingActionButton: Tooltip(
        message: addConfirmationButtonTooltip,
        child: FloatingActionButton(
          onPressed: isAddConfirmationButtonDisabled
              ? null
              : () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TambahMenuSiswa(
                        // Mengarahkan ke form yang baru
                        schoolId: _userSchoolId,
                        initialStudentId:
                            _selectedStudentId, // Teruskan siswa yang dipilih
                        initialDate: DateTime
                            .now(), // Teruskan tanggal hari ini (opsional: bisa juga tanggal dari filter jika ada)
                      ),
                    ),
                  );
                  // Setelah kembali dari Tambah Konfirmasi Makan Siswa,
                  // refresh riwayat makan siswa yang sedang dipilih
                  _updateMealHistoryStream();
                },
          backgroundColor:
              isAddConfirmationButtonDisabled ? Colors.grey : Colors.blueAccent,
          child: Icon(Icons.add_task,
              color: isAddConfirmationButtonDisabled
                  ? Colors.grey.shade300
                  : Colors.white),
        ),
      ),
    );
  }
}
