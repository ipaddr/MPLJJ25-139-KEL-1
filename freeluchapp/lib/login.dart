import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <<< PASTIKAN INI ADA
import 'package:flutter/material.dart';
import 'package:freeluchapp/admin/dashboard_page.dart';
import 'package:freeluchapp/guru/home_page_guru.dart';

class SimpleLoginPage extends StatefulWidget {
  const SimpleLoginPage({super.key});

  @override
  SimpleLoginPageState createState() => SimpleLoginPageState();
}

class SimpleLoginPageState extends State<SimpleLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _message = '';
  String? _selectedRole; // Role yang dipilih di dropdown UI
  String? _actualUserRole; // Role yang diambil dari Firestore setelah login

  final List<String> _roles = ['Admin', 'Guru'];

  // Fungsi untuk menangani proses login
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasi input awal (email, password, dan role tidak boleh kosong)
    if (email.isEmpty || password.isEmpty || _selectedRole == null) {
      if (mounted) {
        setState(() {
          _message = 'Email, password, dan role harus diisi.';
        });
      }
      return;
    }

    // Reset pesan kesalahan saat mencoba login kembali
    if (mounted) {
      setState(() {
        _message = 'Sedang memproses...'; // Pesan loading
      });
    }

    try {
      // 1. Lakukan autentikasi dengan Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Pastikan ada user yang login setelah autentikasi
      if (userCredential.user == null) {
        throw FirebaseAuthException(
            code: 'no-user-after-auth',
            message: 'User tidak ditemukan setelah autentikasi berhasil.');
      }

      // 2. Dapatkan UID dari user yang BARU SAJA LOGIN
      // UID ini akan diambil dari object userCredential.user!
      final String uid = userCredential.user!.uid;

      // --- DEBUGGING ---
      print('AUTH_WRAPPER_DEBUG: Pengguna LOGIN: ${email} dengan UID: $uid');
      // --- END DEBUGGING ---

      // 3. Ambil data profil user dari koleksi 'users' di Firestore menggunakan UID yang BARU LOGIN
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      // --- DEBUGGING ---
      print('AUTH_WRAPPER_DEBUG: Mencari dokumen untuk UID: $uid');
      // --- END DEBUGGING ---

      if (!userDoc.exists) {
        // Jika dokumen user tidak ditemukan di Firestore, ini berarti data profil user belum ada.
        // Sangat penting: Logout user dari Auth karena kita tidak bisa memverifikasi rolenya.
        await FirebaseAuth.instance.signOut();
        // --- DEBUGGING ---
        print(
            'AUTH_WRAPPER_DEBUG: Dokumen user tidak ditemukan untuk UID: $uid');
        // --- END DEBUGGING ---
        throw FirebaseAuthException(
            code: 'user-data-not-found',
            message:
                'Data profil pengguna tidak ditemukan di database. Hubungi administrator.');
      }

      // 4. Dapatkan peran user dari data Firestore
      // Pastikan 'role' adalah field yang ada di dokumen user Anda di Firestore
      _actualUserRole = userDoc.get('role'); // Ambil role dari Firestore
      // --- DEBUGGING ---
      print(
          'AUTH_WRAPPER_DEBUG: Peran sebenarnya dari Firestore: $_actualUserRole');
      // --- END DEBUGGING ---

      // 5. Validasi peran yang dipilih di UI dengan peran sebenarnya dari Firestore
      // Pastikan _selectedRole (dari dropdown) sama dengan _actualUserRole (dari Firestore)
      if (_selectedRole?.toLowerCase() == _actualUserRole?.toLowerCase()) {
        // Bandingkan dalam lowercase untuk fleksibilitas
        if (mounted) {
          setState(() {
            _message = 'Login berhasil!';
          });
          // Navigasi ke halaman yang sesuai berdasarkan peran yang sebenarnya (dari Firestore)
          if (_actualUserRole?.toLowerCase() == 'admin') {
            // Gunakan lowercase sesuai field database
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardPage(),
              ),
            );
          } else if (_actualUserRole?.toLowerCase() == 'guru') {
            // Gunakan lowercase
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePageGuru()),
            );
          } else {
            // Jika role tidak dikenal atau null
            await FirebaseAuth.instance.signOut();
            if (mounted) {
              setState(() {
                _message = 'Peran tidak dikenal. Hubungi administrator.';
              });
            }
          }
        }
      } else {
        // Jika peran yang dipilih di UI tidak cocok dengan peran di Firestore
        await FirebaseAuth.instance.signOut(); // Logout user dari Firebase Auth
        if (mounted) {
          setState(() {
            _message =
                'Peran yang Anda pilih tidak sesuai dengan akun ini. Mohon pilih peran yang benar.';
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          if (e.code == 'user-not-found' ||
              e.code == 'wrong-password' ||
              e.code == 'invalid-credential' ||
              e.code == 'no-user-after-auth') {
            _message = 'Email atau kata sandi salah. Silakan coba lagi.';
          } else if (e.code == 'invalid-email') {
            _message = 'Format email tidak valid.';
          } else if (e.code == 'user-data-not-found') {
            _message = e
                .message!; // Tampilkan pesan yang lebih spesifik dari throw di atas
          } else {
            _message =
                'Terjadi kesalahan autentikasi: ${e.message ?? 'Unknown error'}';
            print(
                'Firebase Auth Error Code: ${e.code}'); // Log error code untuk debugging
          }
        });
      }
    } catch (e) {
      // Menangani kesalahan umum lainnya (misalnya error koneksi, data malformed, dll.)
      if (mounted) {
        setState(() {
          _message = 'Terjadi kesalahan: $e';
        });
        print('General Error login: $e'); // Log error untuk debugging
      }
    } finally {
      if (mounted && _message.isEmpty) {
        // Jika tidak ada pesan error yang diset, hapus pesan loading
        setState(() {
          _message = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDDEEFF),
      body: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu_book, color: Colors.blue, size: 32),
                  SizedBox(width: 8),
                  Text(
                    "Free\nLunch App",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                hint: const Text("Pilih Role"),
                isExpanded: true,
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBFD8EC),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "Log in",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _message,
                style: TextStyle(
                  color:
                      _message.contains('berhasil') ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "2025 Free Lunch App",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
