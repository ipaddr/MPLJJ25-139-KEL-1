import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Misal HomePageGuru sudah dibuat dan di-import
import 'home_page_guru.dart'; // Ganti sesuai path sebenarnya

class JadwalMenuGuru extends StatefulWidget {
  const JadwalMenuGuru({Key? key}) : super(key: key);

  @override
  State<JadwalMenuGuru> createState() => _JadwalMenuGuruState();
}

class _JadwalMenuGuruState extends State<JadwalMenuGuru> {
  DateTime selectedDate = DateTime.now();

  final List<Map<String, String>> jadwal = [
    {"waktu": "10:00", "menu": "Makan Siang"},
    {"waktu": "10:30", "menu": "Makan Siang"},
    {"waktu": "11:00", "menu": "Soto Ayam, Tahu"},
    {"waktu": "11:30", "menu": "Sayur Lodeh, Tempe"},
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _konfirmasiLogout() async {
    bool? keluar = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Konfirmasi Logout'),
            content: const Text('Apakah Anda yakin ingin keluar?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Logout'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (keluar == true) {
      // Logout logic, misal Firebase sign out
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF1C355E),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBEAFF),
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Lihat Jadwal & Menu Harian',
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.account_circle, color: Colors.black),
          ),
        ],
      ),
      drawer: _buildSidebar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                    ),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(color: Colors.black),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Aksi tombol Tambah
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDBEAFF),
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Tambah'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.white),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(4),
              },
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Color(0xFF1C355E)),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Waktu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Menu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                for (var item in jadwal)
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFF1C355E)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item['waktu']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item['menu']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Drawer _buildSidebar() {
    return Drawer(
      backgroundColor: const Color(0xFFF5F5F5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFFDDEEFF)),
            child: Column(
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.jpg'),
                  radius: 30,
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nama Guru",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    elevation: 0,
                  ),
                  child: const Text(
                    "Online",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(Icons.dashboard, "Dashboard", () {
            Navigator.pop(context); // tutup drawer dulu
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePageGuru()),
            );
          }),
          _drawerItem(Icons.restaurant, "Jadwal & Menu", () {
            Navigator.pop(context);
            // Sudah di halaman ini, tidak perlu navigasi
          }),
          _drawerItem(Icons.bar_chart, "Laporan Riwayat Makan", () {
            Navigator.pop(context);
            // Navigasi ke halaman laporan riwayat makan
          }),
          _drawerItem(Icons.check_circle, "Konfirmasi Makan", () {
            Navigator.pop(context);
            // Navigasi ke halaman konfirmasi makan
          }),
          _drawerItem(Icons.logout, "Log Out", () {
            Navigator.pop(context);
            _konfirmasiLogout();
          }),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title),
      onTap: onTap,
    );
  }
}
