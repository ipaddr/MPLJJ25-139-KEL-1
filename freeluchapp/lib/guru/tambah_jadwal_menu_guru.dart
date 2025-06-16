import 'package:flutter/material.dart';

class TambahJadwalMenuGuruPage extends StatefulWidget {
  // Nama kelas diperbarui
  const TambahJadwalMenuGuruPage({
    super.key,
  }); // Perbaikan warning 'use_super_parameters'

  @override
  State<TambahJadwalMenuGuruPage> createState() =>
      _TambahJadwalMenuGuruPageState(); // Nama state diperbarui
}

class _TambahJadwalMenuGuruPageState extends State<TambahJadwalMenuGuruPage> {
  // Nama state diperbarui
  final TextEditingController waktuController =
      TextEditingController(); // Controller untuk input waktu
  final TextEditingController menuController =
      TextEditingController(); // Controller untuk input menu

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF), // Warna AppBar
        title: const Text(
          'Tambah Jadwal & Menu Harian', // Judul AppBar yang lebih sesuai
          style: TextStyle(color: Colors.black), // Gaya teks judul
        ),
        iconTheme: const IconThemeData(
          color: Colors.black,
        ), // Warna ikon di AppBar
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(
              Icons.account_circle,
              color: Colors.black,
            ), // Ikon profil
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F365D), // Warna latar belakang halaman
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding di sekitar konten
        child: Column(
          children: [
            // Input Waktu
            TextField(
              controller: waktuController,
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
            ),
            const SizedBox(height: 20), // Spasi vertikal
            // Input Menu
            TextField(
              controller: menuController,
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
            ),
            const SizedBox(height: 20), // Spasi vertikal
            // Tombol Tambah
            ElevatedButton(
              onPressed: () {
                final waktu =
                    waktuController.text
                        .trim(); // Ambil teks waktu, hapus spasi
                final menu =
                    menuController.text.trim(); // Ambil teks menu, hapus spasi

                if (waktu.isNotEmpty && menu.isNotEmpty) {
                  // Mengembalikan data ke halaman sebelumnya (JadwalMenuGuruPage)
                  Navigator.pop(context, {'waktu': waktu, 'menu': menu});
                } else {
                  // Tampilkan snackbar jika input kosong
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Waktu dan Menu tidak boleh kosong!'),
                    ),
                  );
                }
              },
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
    );
  }
}
