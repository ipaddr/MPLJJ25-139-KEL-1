import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:freeluchapp/guru/tambah_jadwal_menu_guru.dart'; // Import halaman tambah
import 'package:freeluchapp/app_drawer_guru.dart'; // Import AppDrawerGuru

class JadwalMenuGuruPage extends StatefulWidget {
  const JadwalMenuGuruPage({super.key});

  @override
  State<JadwalMenuGuruPage> createState() => _JadwalMenuGuruPageState();
}

class _JadwalMenuGuruPageState extends State<JadwalMenuGuruPage> {
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

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat(
      'EEEE, d MMMM yyyy', // Format tanggal lebih lengkap, pastikan 'yyyy'
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
        // Hapus actions di sini
        // actions: const [
        //   Padding(
        //     padding: EdgeInsets.only(right: 16),
        //     child: Icon(Icons.account_circle, color: Colors.black),
        //   ),
        // ],
      ),
      drawer: const AppDrawerGuru(), // Tambahkan drawer di sini
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
                  onPressed: () async {
                    final newEntry = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TambahJadwalMenuGuruPage(),
                      ),
                    );
                    if (newEntry != null && newEntry is Map<String, String>) {
                      setState(() {
                        jadwal.add(newEntry);
                      });
                    }
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
            Expanded(
              child: ListView(
                children: [
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
                          decoration: const BoxDecoration(
                            color: Color(0xFF1C355E),
                          ),
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
          ],
        ),
      ),
    );
  }
}
