import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru (pastikan path ini benar)

class KonfirmasiMakanSiswa extends StatefulWidget {
  const KonfirmasiMakanSiswa({super.key});

  @override
  State<KonfirmasiMakanSiswa> createState() => _KonfirmasiMakanSiswaState();
}

class _KonfirmasiMakanSiswaState extends State<KonfirmasiMakanSiswa> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _userSchoolId = '';
  DateTime _selectedDate =
      DateTime.now(); // Tanggal yang dipilih untuk melihat konfirmasi
  Stream<QuerySnapshot>?
      _mealConfirmationsStream; // Stream untuk data konfirmasi makan

  bool _isLoadingInitialData = true; // Untuk memuat schoolId dan stream awal
  final Map<String, String> _studentNamesCache = {}; // Cache untuk nama siswa

  final TextEditingController _searchController =
      TextEditingController(); // Controller untuk search bar

  @override
  void initState() {
    super.initState();
    _loadUserSchoolIdAndInitialStream();
    // Tidak perlu addListener di sini jika onChanged TextField digunakan
    // _searchController.addListener(_onSearchChanged); // Hapus ini jika _onSearchChanged menerima parameter
  }

  @override
  void dispose() {
    // _searchController.removeListener(_onSearchChanged); // Hapus ini
    _searchController.dispose();
    super.dispose();
  }

  // Dipanggil saat teks pencarian berubah - SEKARANG MENERIMA PARAMETER STRING
  void _onSearchChanged(String query) {
    // <<< PERBAIKAN DI SINI: tambahkan parameter 'query'
    if (mounted) {
      setState(() {
        // Tidak perlu menggunakan 'query' secara langsung di sini karena
        // `_searchController.text` sudah merepresentasikan nilai terbaru.
        // setState() cukup untuk memicu rebuild dan filter di StreamBuilder.
      });
    }
  }

  // Memuat ID sekolah guru dan menginisialisasi stream konfirmasi makan
  Future<void> _loadUserSchoolIdAndInitialStream() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      print("Tidak ada pengguna yang login.");
      if (mounted) {
        setState(() {
          _isLoadingInitialData = false;
        });
      }
      return;
    }

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
          _updateMealConfirmationStream(
              _selectedDate); // Inisialisasi stream untuk tanggal hari ini
        } else {
          if (mounted) {
            setState(() {
              _isLoadingInitialData = false;
            });
          }
          print("Guru tidak terhubung ke sekolah mana pun.");
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoadingInitialData = false;
          });
        }
        print(
            "Dokumen user tidak ditemukan di Firestore untuk UID: ${currentUser.uid}");
      }
    } catch (e) {
      print("Error memuat ID sekolah pengguna: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data awal: $e')),
        );
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  // Memperbarui stream konfirmasi makan berdasarkan tanggal yang dipilih
  void _updateMealConfirmationStream(DateTime date) {
    if (_userSchoolId.isEmpty) {
      if (mounted) {
        setState(() {
          _mealConfirmationsStream = null;
          _isLoadingInitialData = false;
        });
      }
      return;
    }

    // Atur tanggal ke awal hari dan akhir hari untuk kueri yang akurat
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    if (mounted) {
      setState(() {
        _isLoadingInitialData =
            true; // Set loading saat mengubah tanggal atau memuat ulang
      });
    }

    try {
      Query query = _firestore
          .collection('meal_confirmations')
          .where('schoolId', isEqualTo: _userSchoolId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay);
      // Tambahan: jika perlu filter status tertentu, tambahkan .where('status', isEqualTo: 'Pending')
      // Firestore tidak mendukung orderBy pada field yang berbeda dengan where
      // Tanpa indeks yang sangat spesifik, orderBy di sini mungkin tidak efisien atau memerlukan indeks lain.
      // Untuk kasus ini, kita akan asumsikan data akan diurutkan di klien jika diperlukan.

      _mealConfirmationsStream = query.snapshots();

      // Listener untuk mengetahui kapan data pertama kali datang
      _mealConfirmationsStream!.listen((snapshot) {
        if (mounted) {
          setState(() {
            _isLoadingInitialData = false;
          });
        }
      }).onError((error) {
        print("Error di stream konfirmasi makan: $error");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat konfirmasi makan: $error')),
          );
          setState(() {
            _isLoadingInitialData = false;
          });
        }
      });
    } catch (e) {
      print("Error mengatur stream konfirmasi makan: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat konfirmasi makan: $e')),
        );
        setState(() {
          _isLoadingInitialData = false;
        });
      }
    }
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _selectedDate) {
      if (mounted) {
        setState(() {
          _selectedDate = picked;
        });
      }
      _updateMealConfirmationStream(
          _selectedDate); // Muat ulang konfirmasi untuk tanggal baru
    }
  }

  // Fungsi helper untuk mendapatkan nama siswa dari cache atau Firestore
  Future<String> _getStudentName(String studentId) async {
    if (_studentNamesCache.containsKey(studentId)) {
      return _studentNamesCache[studentId]!;
    }
    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(studentId).get();
      String name = studentDoc.exists
          ? studentDoc.get('name') ?? 'Nama Tidak Ditemukan'
          : 'Siswa Tidak Ditemukan';
      _studentNamesCache[studentId] = name; // Simpan ke cache
      return name;
    } catch (e) {
      print("Error fetching student name for $studentId: $e");
      return 'Error Memuat Nama';
    }
  }

  // Fungsi untuk mengubah status makan siswa
  Future<void> _updateMealStatus(String docId, String newStatus) async {
    final String currentUserId = _auth.currentUser?.uid ?? 'unknown';
    try {
      await _firestore.collection('meal_confirmations').doc(docId).update({
        'status': newStatus,
        'confirmedBy': currentUserId,
        'confirmedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Status makan berhasil diubah menjadi "$newStatus"!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah status: $e')),
        );
      }
      print('Error updating meal status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // PERBAIKAN DI SINI: Ubah format tanggal menjadi 'EEEE, dd MMMM yyyy'
    String formattedDate =
        DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF1F365D),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF),
        title: const Text(
          'Konfirmasi Makan Siswa',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: const AppDrawerGuru(), // Tambahkan drawer di sini
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged, // <<< PERBAIKAN DI SINI
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: 'Cari Siswa',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date Filter
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal: $formattedDate',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.blueGrey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16), // Spasi setelah date filter

            Expanded(
              child: _isLoadingInitialData
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : _userSchoolId.isEmpty
                      ? const Center(
                          child: Text(
                              'Guru tidak terhubung ke sekolah mana pun.',
                              style: TextStyle(color: Colors.white)))
                      : StreamBuilder<QuerySnapshot>(
                          stream: _mealConfirmationsStream,
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
                                      style:
                                          const TextStyle(color: Colors.red)));
                            }
                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                  child: Text(
                                      'Tidak ada catatan makan siswa untuk tanggal ini. Pastikan jadwal menu telah dibuat dan catatan makan otomatis telah digenerate (jika ada).',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Colors.white.withOpacity(0.8))));
                            }

                            // Filter data di sisi klien berdasarkan pencarian nama siswa
                            List<DocumentSnapshot> filteredDocs =
                                snapshot.data!.docs.where((doc) {
                              String studentId = doc.get('studentId') ?? '';
                              // Ambil nama siswa dari cache, atau tampilkan "Memuat..." jika belum di-cache
                              String studentName = _studentNamesCache[studentId]
                                      ?.toLowerCase() ??
                                  '';

                              // Jika nama belum di-cache, panggil _getStudentName untuk memuatnya
                              if (studentName.isEmpty &&
                                  !_studentNamesCache.containsKey(studentId)) {
                                _getStudentName(studentId).then((name) {
                                  if (mounted)
                                    setState(
                                        () {}); // Trigger rebuild once name is fetched
                                });
                              }

                              // Filter berdasarkan nama siswa dan teks pencarian
                              return studentName.contains(
                                  _searchController.text.trim().toLowerCase());
                            }).toList();

                            if (filteredDocs.isEmpty) {
                              return const Center(
                                  child: Text(
                                      'Tidak ada siswa yang cocok dengan pencarian Anda.',
                                      style: TextStyle(color: Colors.white)));
                            }

                            return ListView.builder(
                              itemCount: filteredDocs.length,
                              itemBuilder: (context, index) {
                                DocumentSnapshot doc = filteredDocs[index];
                                Map<String, dynamic> data =
                                    doc.data() as Map<String, dynamic>;

                                String studentId = data['studentId'] ?? '';
                                String menu = (data['menuDetails'] != null &&
                                        data['menuDetails']['foodName'] != null)
                                    ? data['menuDetails']['foodName']
                                    : 'Menu Tidak Tersedia';
                                String mealTime = (data['menuDetails'] !=
                                            null &&
                                        (data['menuDetails']['time'] != null ||
                                            data['menuDetails']['mealType'] !=
                                                null))
                                    ? "${data['menuDetails']['time'] ?? ''} (${data['menuDetails']['mealType'] ?? ''})"
                                        .trim()
                                    : 'Waktu/Jenis Makan Tidak Tersedia';
                                String status = data['status'] ?? 'Pending';

                                // Menentukan warna chip berdasarkan status
                                Color statusBackgroundColor;
                                Color statusTextColor;
                                switch (status) {
                                  case 'Confirmed':
                                    statusBackgroundColor =
                                        Colors.green.shade200;
                                    statusTextColor = Colors.green.shade800;
                                    break;
                                  case 'Cancelled':
                                    statusBackgroundColor = Colors.red.shade200;
                                    statusTextColor = Colors.red.shade800;
                                    break;
                                  case 'Pending':
                                  default:
                                    statusBackgroundColor =
                                        Colors.orange.shade200;
                                    statusTextColor = Colors.orange.shade800;
                                    break;
                                }

                                return FutureBuilder<String>(
                                  future: _getStudentName(studentId),
                                  builder: (context, studentNameSnapshot) {
                                    String studentName =
                                        studentNameSnapshot.data ??
                                            'Memuat Nama...';
                                    // Tampilkan status loading nama jika masih loading
                                    if (studentNameSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      studentName = 'Memuat Nama...';
                                    } else if (studentNameSnapshot.hasError) {
                                      studentName = 'Nama Error';
                                    }

                                    return Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      color: const Color(0xFF2C4A7A),
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Menu: $menu $mealTime',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white
                                                      .withOpacity(0.8)),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Chip(
                                                  label: Text(status),
                                                  backgroundColor:
                                                      statusBackgroundColor,
                                                  labelStyle: TextStyle(
                                                      color: statusTextColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Row(
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: status ==
                                                              'Confirmed'
                                                          ? null // Disable jika sudah Confirmed
                                                          : () =>
                                                              _updateMealStatus(
                                                                  doc.id,
                                                                  'Confirmed'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8),
                                                      ),
                                                      child: const Text(
                                                          'Konfirmasi'),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton(
                                                      onPressed: status ==
                                                              'Cancelled'
                                                          ? null // Disable jika sudah Cancelled
                                                          : () =>
                                                              _updateMealStatus(
                                                                  doc.id,
                                                                  'Cancelled'),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8)),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 8),
                                                      ),
                                                      child: const Text(
                                                          'Batalkan'),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
