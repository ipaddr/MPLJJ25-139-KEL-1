import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TambahSiswaPage extends StatefulWidget {
  // schoolId ini akan diteruskan dari halaman sebelumnya (tambah_jadwal_menu_guru.dart)
  // agar siswa yang ditambahkan otomatis terkait dengan sekolah guru
  final String schoolId;

  const TambahSiswaPage({super.key, required this.schoolId});

  @override
  State<TambahSiswaPage> createState() => _TambahSiswaPageState();
}

class _TambahSiswaPageState extends State<TambahSiswaPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _nisnController =
      TextEditingController(); // Opsional
  String? _genderValue; // Untuk dropdown gender

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  @override
  void dispose() {
    _nameController.dispose();
    _classController.dispose();
    _nisnController.dispose();
    super.dispose();
  }

  // Fungsi untuk menambahkan siswa ke Firestore
  Future<void> _addStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Anda harus login untuk menambahkan siswa.')),
          );
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }

      final studentData = {
        'name': _nameController.text.trim(),
        'class': _classController.text.trim(),
        'schoolId': widget.schoolId, // schoolId dari guru yang login
        'nisn': _nisnController.text.trim().isNotEmpty
            ? _nisnController.text.trim()
            : null, // Opsional
        'gender': _genderValue, // Opsional
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'addedByUid': currentUser.uid, // UID guru yang menambahkan siswa
      };

      try {
        await _firestore.collection('students').add(studentData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Siswa berhasil ditambahkan!')),
          );
          Navigator.pop(context,
              true); // Kembali dan beri tahu halaman sebelumnya bahwa siswa ditambahkan
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menambahkan siswa: $e')),
          );
        }
        print('Error adding student: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
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
          'Tambah Siswa Baru',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFF1F365D),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Nama Siswa',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama siswa tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _classController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Kelas (contoh: 5A, Kelas 3)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kelas tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nisnController,
                style: const TextStyle(color: Colors.black),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'NISN (Nomor Induk Siswa Nasional, opsional)',
                  labelStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: DropdownButtonFormField<String>(
                  value: _genderValue,
                  hint: const Text("Jenis Kelamin (opsional)",
                      style: TextStyle(color: Colors.grey)),
                  decoration: const InputDecoration(
                    border: InputBorder
                        .none, // Hapus border bawaan DropdownButtonFormField
                    contentPadding: EdgeInsets.zero,
                  ),
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _genderValue = newValue;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : ElevatedButton(
                      onPressed: _addStudent,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDBEAFF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        'Tambah Siswa',
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
