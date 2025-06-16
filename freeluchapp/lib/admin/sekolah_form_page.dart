import 'package:flutter/material.dart';
import 'package:freeluchapp/app_drawer.dart';

class SekolahFormPage extends StatefulWidget {
  final String? nama;
  final String? alamat;

  const SekolahFormPage({super.key, this.nama, this.alamat});

  @override
  State<SekolahFormPage> createState() => _SekolahFormPageState();
}

class _SekolahFormPageState extends State<SekolahFormPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.nama ?? '';
    _alamatController.text = widget.alamat ?? '';
  }

  void _simpanSekolah() {
    if (_namaController.text.isEmpty || _alamatController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Alamat harus diisi')),
      );
      return;
    }
    Navigator.pop(context, {
      'nama': _namaController.text,
      'alamat': _alamatController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // pasang drawer yang sama
      appBar: AppBar(
        title: const Text("Sekolah"),
        backgroundColor: const Color(0xFFDDEEFF),
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20),
        automaticallyImplyLeading: true,
      ),
      backgroundColor: const Color(0xFF1F355D),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                hintText: 'Nama Sekolah',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                hintText: 'Alamat',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _simpanSekolah,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27496D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.nama == null ? "Tambah" : "Simpan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
