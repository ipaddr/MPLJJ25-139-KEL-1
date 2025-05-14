import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  bool isEditingName = false;
  String status = "Online";

  void _saveName() {
    setState(() {
      isEditingName = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2D4873),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, size: 48, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                "Sukses",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Nama Akun berhasil dibuat",
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: const Text("OK", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F355D),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDEEFF),
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.account_circle, size: 100, color: Colors.black),
            const SizedBox(height: 24),

            // Nama Akun
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    readOnly: !isEditingName,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "Nama Akun",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      isEditingName = !isEditingName;
                    });
                    if (!isEditingName) _saveName();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Email
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: user?.email ?? "Tidak ada email",
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: status,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
