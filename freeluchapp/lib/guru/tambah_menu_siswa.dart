import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Mengganti nama kelas widget agar lebih mencerminkan fungsinya
class TambahMenuSiswa extends StatefulWidget {
  final String schoolId;
  final String?
      initialStudentId; // Siswa yang sudah dipilih dari halaman sebelumnya (opsional)
  final DateTime?
      initialDate; // Tanggal yang sudah dipilih dari halaman sebelumnya (opsional)

  const TambahMenuSiswa({
    super.key,
    required this.schoolId,
    this.initialStudentId,
    this.initialDate,
  });

  @override
  State<TambahMenuSiswa> createState() => _TambahMenuSiswaState();
}

class _TambahMenuSiswaState extends State<TambahMenuSiswa> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now(); // Default ke tanggal hari ini
  List<Map<String, dynamic>> _students = [];
  String? _selectedStudentId; // ID siswa yang dipilih
  String _selectedStudentName =
      ''; // Untuk menampilkan nama siswa jika initialStudentId diberikan

  List<Map<String, dynamic>> _availableMenus =
      []; // Menu yang tersedia untuk tanggal tsb
  String?
      _selectedMenuItemString; // String representasi menu yang dipilih (misal: "Nasi Goreng (Makan Siang 12:00)")
  Map<String, dynamic>?
      _selectedMenuItemDetails; // Detail lengkap menu yang dipilih

  bool _isLoading = true; // Untuk memuat data awal (siswa, menu)
  bool _isSaving = false; // Untuk menyimpan konfirmasi

  @override
  void initState() {
    super.initState();
    // Inisialisasi dari parameter jika diberikan
    _selectedStudentId = widget.initialStudentId;
    _selectedDate = widget.initialDate ??
        DateTime.now(); // Jika initialDate null, gunakan hari ini

    _initializePageData();
  }

  Future<void> _initializePageData() async {
    // Jika initialStudentId diberikan, langsung ambil nama siswa tersebut
    if (widget.initialStudentId != null) {
      await _fetchStudentName(widget.initialStudentId!);
    } else {
      // Jika tidak, ambil daftar siswa untuk dropdown
      await _fetchStudents();
    }
    await _fetchAvailableMenus(
        _selectedDate); // Fetch menu untuk tanggal yang sudah ditentukan
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mengambil daftar siswa untuk dropdown (hanya jika tidak ada initialStudentId)
  Future<void> _fetchStudents() async {
    try {
      QuerySnapshot studentSnapshot = await _firestore
          .collection('students')
          .where('schoolId', isEqualTo: widget.schoolId)
          .orderBy('name')
          .get();

      if (mounted) {
        setState(() {
          _students = studentSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'name': data['name'] ?? 'Nama Tidak Tersedia',
            };
          }).toList();

          // Atur siswa pertama sebagai default jika belum ada yang dipilih
          if (_students.isNotEmpty && _selectedStudentId == null) {
            _selectedStudentId = _students.first['id'];
          }
        });
      }
    } catch (e) {
      print("Error fetching students: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar siswa: $e')),
        );
      }
    }
  }

  // Mengambil nama siswa tunggal (jika initialStudentId diberikan)
  Future<void> _fetchStudentName(String studentId) async {
    try {
      DocumentSnapshot studentDoc =
          await _firestore.collection('students').doc(studentId).get();
      if (studentDoc.exists && studentDoc.data() != null) {
        if (mounted) {
          setState(() {
            _selectedStudentName =
                studentDoc.get('name') ?? 'Siswa Tidak Ditemukan';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _selectedStudentName = 'Siswa Tidak Ditemukan';
          });
        }
        print("Dokumen siswa tidak ditemukan untuk ID: $studentId");
      }
    } catch (e) {
      print("Error fetching student name: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat nama siswa: $e')),
        );
      }
    }
  }

  // Mengambil menu yang tersedia untuk tanggal dan sekolah ini
  Future<void> _fetchAvailableMenus(DateTime date) async {
    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    try {
      QuerySnapshot menuSnapshot = await _firestore
          .collection('daily_menus')
          .where('schoolId', isEqualTo: widget.schoolId)
          .where('date', isGreaterThanOrEqualTo: startOfDay)
          .where('date', isLessThanOrEqualTo: endOfDay)
          .limit(1)
          .get();

      if (mounted) {
        setState(() {
          _availableMenus = [];
          _selectedMenuItemString = null;
          _selectedMenuItemDetails = null;

          if (menuSnapshot.docs.isNotEmpty) {
            List<dynamic>? items = menuSnapshot.docs.first.get('menuItems');
            if (items != null) {
              _availableMenus = items.map((item) {
                return item as Map<String, dynamic>;
              }).toList();
            }
            // Set menu pertama sebagai default jika ada
            if (_availableMenus.isNotEmpty) {
              _selectedMenuItemDetails = _availableMenus.first;
              _selectedMenuItemString =
                  "${_availableMenus.first['foodName']} (${_availableMenus.first['time'] ?? _availableMenus.first['mealType']})";
            }
          }
        });
      }
    } catch (e) {
      print("Error fetching available menus: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar menu: $e')),
        );
      }
    }
  }

  // Fungsi untuk menampilkan date picker (hanya jika initialDate tidak diberikan)
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
          _isLoading = true; // Set loading saat fetch menu baru
        });
      }
      await _fetchAvailableMenus(
          _selectedDate); // Fetch menu untuk tanggal baru
      if (mounted) {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  // Fungsi untuk menambahkan catatan makan siswa
  Future<void> _addMealConfirmation() async {
    if (_formKey.currentState!.validate()) {
      // Pastikan siswa dan menu telah dipilih
      if (_selectedStudentId == null || _selectedMenuItemDetails == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mohon pilih siswa dan menu.')),
          );
        }
        return;
      }

      setState(() {
        _isSaving = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk mencatat makan.')),
          );
          setState(() {
            _isSaving = false;
          });
        }
        return;
      }

      // --- DEBUGGING: Cetak nilai-nilai kunci sebelum operasi Firestore ---
      print('DEBUGGING SAVE:');
      print('  User UID (confirmedBy): ${currentUser.uid}');
      print(
          '  Guru School ID (widget.schoolId - dari param): ${widget.schoolId}');
      print('  Selected Student ID: $_selectedStudentId');
      print('  Selected Date: $_selectedDate');
      print('  Selected Menu: $_selectedMenuItemDetails');
      print('  Status akan diset: Pending');
      // --- END DEBUGGING ---

      DateTime startOfDay =
          DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      DateTime endOfDay = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, 23, 59, 59);

      try {
        // Query untuk mencari entri yang sudah ada untuk siswa, sekolah, dan tanggal yang sama
        QuerySnapshot existingConfirmations = await _firestore
            .collection('meal_confirmations')
            .where('studentId', isEqualTo: _selectedStudentId)
            .where('schoolId',
                isEqualTo: widget
                    .schoolId) // Penting: harus cocok dengan schoolId guru
            .where('date', isGreaterThanOrEqualTo: startOfDay)
            .where('date', isLessThanOrEqualTo: endOfDay)
            .limit(1)
            .get();

        if (existingConfirmations.docs.isNotEmpty) {
          // Jika sudah ada catatan makan untuk siswa ini pada tanggal ini, perbarui
          String existingDocId = existingConfirmations.docs.first.id;
          await _firestore
              .collection('meal_confirmations')
              .doc(existingDocId)
              .update({
            'menuDetails':
                _selectedMenuItemDetails, // Perbarui detail menu jika diubah
            'status':
                'Pending', // Status diset ke 'Pending' jika diperbarui dari sini
            'confirmedBy': currentUser.uid,
            'confirmedAt': Timestamp
                .now(), // Gunakan ini sebagai waktu catatan dibuat/diperbarui
            'updatedAt': Timestamp.now(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Catatan makan siswa berhasil diperbarui!')),
            );
            Navigator.pop(context,
                true); // Kembali ke halaman sebelumnya dengan hasil true
          }
        } else {
          // Jika belum ada catatan, tambahkan yang baru
          await _firestore.collection('meal_confirmations').add({
            'studentId': _selectedStudentId,
            'schoolId':
                widget.schoolId, // Penting: harus cocok dengan schoolId guru
            'date': Timestamp.fromDate(_selectedDate),
            'menuDetails': _selectedMenuItemDetails,
            'status': 'Pending', // Status awal diset ke 'Pending'
            'notes':
                '', // Field opsional, bisa ditambahkan input catatan di UI jika diperlukan
            'confirmedBy': currentUser.uid,
            'confirmedAt': Timestamp.now(),
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Catatan makan siswa berhasil ditambahkan!')),
            );
            Navigator.pop(context,
                true); // Kembali ke halaman sebelumnya dengan hasil true
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan catatan makan: $e')),
          );
        }
        print('Error saving meal confirmation: $e'); // Print error
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF),
        title: const Text(
          'Tambah Menu Siswa', // Judul AppBar diubah
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFF1F365D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Tampilan Nama Siswa atau Dropdown (tergantung parameter)
                    widget.initialStudentId != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'Siswa: $_selectedStudentName',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButtonFormField<String>(
                              value: _selectedStudentId,
                              hint: const Text("Pilih Siswa",
                                  style: TextStyle(color: Colors.grey)),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                              items: _students.map((student) {
                                return DropdownMenuItem<String>(
                                  value: student['id'],
                                  child: Text(student['name']!),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStudentId = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Mohon pilih siswa';
                                }
                                return null;
                              },
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Tampilan Tanggal atau Date Picker (tergantung parameter)
                    widget.initialDate != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}', // Format tanggal disesuaikan
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black),
                            ),
                          )
                        : GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade400),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate)}', // Format tanggal disesuaikan
                                    style: const TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                  const Icon(Icons.calendar_today,
                                      color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                    const SizedBox(height: 20),

                    // Dropdown Pilih Menu
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: DropdownButtonFormField<String>(
                        value: _selectedMenuItemString,
                        hint: const Text("Pilih Menu",
                            style: TextStyle(color: Colors.grey)),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        items: _availableMenus.map((menuItem) {
                          String displayString =
                              "${menuItem['foodName']} (${menuItem['time'] ?? menuItem['mealType']})";
                          return DropdownMenuItem<String>(
                            value: displayString,
                            child: Text(displayString),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedMenuItemString = newValue;
                            Map<String, dynamic>? foundItem;
                            for (var item in _availableMenus) {
                              if ("${item['foodName']} (${item['time'] ?? item['mealType']})" ==
                                  newValue) {
                                foundItem = item;
                                break;
                              }
                            }
                            _selectedMenuItemDetails = foundItem;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Mohon pilih menu';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    _isSaving
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : ElevatedButton(
                            onPressed: _addMealConfirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDBEAFF),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              'Tambahkan Catatan Makan', // Teks tombol diubah
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}
