import 'package:flutter/material.dart';

class TambahJadwalMenuGuru extends StatefulWidget {
  const TambahJadwalMenuGuru({super.key});

  @override
  State<TambahJadwalMenuGuru> createState() => _TambahJadwalMenuGuruState();
}

class _TambahJadwalMenuGuruState extends State<TambahJadwalMenuGuru> {
  final TextEditingController waktuController = TextEditingController();
  final TextEditingController menuController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCCE6FF),
        title: const Text(
          'Lihat Jadwal & Menu Harian',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF1F365D),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Input Waktu
            TextField(
              controller: waktuController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Waktu',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Input Menu
            TextField(
              controller: menuController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Menu',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Tombol Tambah
            ElevatedButton(
              onPressed: () {
                final waktu = waktuController.text.trim();
                final menu = menuController.text.trim();

                if (waktu.isNotEmpty && menu.isNotEmpty) {
                  Navigator.pop(context, {'waktu': waktu, 'menu': menu});
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
              ),
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }
}
