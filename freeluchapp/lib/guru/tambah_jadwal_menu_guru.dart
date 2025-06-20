import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:intl/intl.dart'; // Untuk format tanggal

class TambahJadwalMenuGuruPage extends StatefulWidget {
  final DateTime selectedDate; // Tambahkan parameter untuk tanggal yang dipilih
  final String schoolId; // Tambahkan parameter untuk ID sekolah

  const TambahJadwalMenuGuruPage({
    super.key,
    required this.selectedDate, // Jadikan parameter ini wajib
    required this.schoolId, // Jadikan parameter ini wajib
  });

  @override
  State<TambahJadwalMenuGuruPage> createState() =>
      _TambahJadwalMenuGuruPageState();
}

class _TambahJadwalMenuGuruPageState extends State<TambahJadwalMenuGuruPage> {
  final _formKey = GlobalKey<FormState>(); // Kunci untuk validasi form
  final TextEditingController _timeController =
      TextEditingController(); // Controller untuk input waktu
  final TextEditingController _menuController =
      TextEditingController(); // Controller untuk input menu (foodName)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false; // State untuk indikator loading

  @override
  void dispose() {
    _timeController.dispose();
    _menuController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambahkan item menu baru ke Firestore
  Future<void> _addMenuItem() async {
    if (_formKey.currentState!.validate()) {
      // Validasi form
      setState(() {
        _isLoading = true; // Aktifkan loading
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk menambahkan menu.')),
          );
          setState(() {
            _isLoading = false;
          }); // Nonaktifkan loading
        }
        return;
      }

      final String currentUserUid = currentUser.uid;
      // Format tanggal untuk digunakan sebagai bagian dari Document ID
      final String formattedDate =
          DateFormat('yyyy-MM-dd').format(widget.selectedDate);
      final String docId =
          '${widget.schoolId}-$formattedDate'; // ID Dokumen: schoolId-YYYY-MM-DD

      // Data item menu baru
      final newMenuItem = {
        'time': _timeController.text.trim(), // Waktu dari input
        'foodName': _menuController.text.trim(), // Nama menu dari input
        'mealType':
            'Makan Siang', // Asumsi default 'Makan Siang', bisa jadi pilihan dinamis
        'description':
            '', // Field opsional, bisa ditambahkan input di UI jika diperlukan
        'imageUrl':
            '', // Field opsional, bisa ditambahkan input di UI jika diperlukan
      };

      try {
        DocumentReference docRef =
            _firestore.collection('daily_menus').doc(docId);
        DocumentSnapshot doc = await docRef.get();

        if (doc.exists) {
          // Jika dokumen untuk tanggal dan sekolah ini sudah ada, update array menuItems
          await docRef.update({
            'menuItems': FieldValue.arrayUnion(
                [newMenuItem]), // Tambahkan item baru ke array
            'updatedAt': Timestamp.now(), // Perbarui timestamp update
            'createdBy':
                currentUserUid, // Perbarui siapa yang terakhir mengubah
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Menu berhasil ditambahkan ke jadwal ini!')),
            );
          }
        } else {
          // Jika dokumen belum ada, buat dokumen baru dengan item menu ini
          await docRef.set({
            'schoolId': widget.schoolId,
            'date': Timestamp.fromDate(
                widget.selectedDate), // Simpan tanggal sebagai Timestamp
            'menuItems': [
              newMenuItem
            ], // Inisialisasi array dengan item menu baru
            'createdAt': Timestamp.now(), // Tambahkan timestamp pembuatan
            'updatedAt': Timestamp.now(), // Tambahkan timestamp update
            'createdBy': currentUserUid,
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Jadwal dan menu baru berhasil dibuat!')),
            );
          }
        }
        if (mounted) {
          Navigator.pop(
              context); // Kembali ke halaman sebelumnya setelah sukses
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan menu: $e')),
          );
        }
        print('Error adding menu item: $e'); // Log error untuk debugging
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Nonaktifkan loading terlepas dari hasil
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF), // Warna AppBar
        title: Text(
          'Tambah Jadwal & Menu Harian (${DateFormat('dd MMMM yyyy', 'id_ID').format(widget.selectedDate)})', // Judul AppBar dengan tanggal
          style: const TextStyle(color: Colors.black), // Gaya teks judul
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Warna ikon di AppBar
        // Hapus actions ikon profil karena biasanya tidak ada di halaman form
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 12.0),
        //     child: Icon(
        //       Icons.account_circle,
        //       color: Colors.black,
        //     ), // Ikon profil
        //   ),
        // ],
      ),
      backgroundColor: const Color(0xFF1F365D), // Warna latar belakang halaman
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding di sekitar konten
        child: Form(
          key: _formKey, // Pasang GlobalKey ke Form
          child: Column(
            children: [
              // Input Waktu
              TextFormField(
                controller: _timeController, // Gunakan _timeController
                style: const TextStyle(color: Colors.black), // Gaya teks input
                decoration: InputDecoration(
                  labelText: 'Waktu (contoh: 10:00)', // Label dan contoh
                  labelStyle: const TextStyle(color: Colors.grey), // Gaya label
                  filled: true,
                  fillColor: Colors.white, // Warna latar belakang input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Border dengan sudut melengkung
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Waktu tidak boleh kosong';
                  }
                  // Opsional: tambahkan validasi format waktu (misal: regex HH:MM)
                  if (!RegExp(r'^(?:2[0-3]|[01]?[0-9]):(?:[0-5]?[0-9])$')
                      .hasMatch(value)) {
                    return 'Format waktu harus HH:MM (contoh: 10:00)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Spasi vertikal
              // Input Menu
              TextFormField(
                controller: _menuController, // Gunakan _menuController
                style: const TextStyle(color: Colors.black), // Gaya teks input
                decoration: InputDecoration(
                  labelText:
                      'Menu (contoh: Nasi Goreng Ayam)', // Label dan contoh
                  labelStyle: const TextStyle(color: Colors.grey), // Gaya label
                  filled: true,
                  fillColor: Colors.white, // Warna latar belakang input
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      8,
                    ), // Border dengan sudut melengkung
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama menu tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20), // Spasi vertikal
              // Tombol Tambah
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: Colors.white)) // Tampilkan loading
                  : ElevatedButton(
                      onPressed: _addMenuItem, // Panggil fungsi _addMenuItem
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFDBEAFF,
                        ), // Warna latar belakang tombol
                        foregroundColor: Colors.black, // Warna teks tombol
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ), // Ukuran padding tombol
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ), // Bentuk tombol
                      ),
                      child: const Text(
                        'Tambah',
                        style: TextStyle(fontSize: 16),
                      ), // Teks tombol
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
